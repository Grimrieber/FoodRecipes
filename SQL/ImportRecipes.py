import os
import re
import pyodbc
from docx import Document

CONN_STR = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=(localdb)\MSSQLLocalDB;"
    "DATABASE=RecipeDB;"
    "Trusted_Connection=Yes;"
    "TrustServerCertificate=Yes;"
)

# Folder of .docx recipe files to import. Override with RECIPE_PATH.
BASE_PATH = os.environ.get("RECIPE_PATH", os.path.join(os.path.dirname(__file__), "..", "Recipes"))

# Map folder names to categories
CATEGORIES = [
    "Appetizers",
    "Beef",
    "Breakfast",
    "Chicken",
    "Desserts",
    "Dinner",
    "Sauces",
    "Seafood",
    "Soup",
    "Vegetables and Sides",
]


def get_paragraphs(filepath):
    """Extract all paragraph text from a docx file."""
    doc = Document(filepath)
    return [p.text.strip() for p in doc.paragraphs]


def parse_time_field(text):
    """Extract prep time, cook time, and rest time from a line."""
    prep = cook = rest = None
    # Look for patterns like "Prep time 10 min" or "Prep Time  5 min"
    m = re.search(r'[Pp]rep\s*[Tt]ime\s*([\d]+\s*(?:min|hr|hour|minutes|hours)[\w\s]*)', text)
    if m:
        prep = m.group(1).strip()
    m = re.search(r'[Cc]ook\s*[Tt]ime\s*([\d]+\s*(?:min|hr|hour|minutes|hours)[\w\s]*)', text)
    if m:
        cook = m.group(1).strip()
    m = re.search(r'[Rr]est\s*[Tt]ime\s*([\d]+\s*(?:min|hr|hour|minutes|hours)[\w\s]*)', text)
    if m:
        rest = m.group(1).strip()
    return prep, cook, rest


def parse_recipe(filepath):
    """Parse a recipe docx file into structured data."""
    paragraphs = get_paragraphs(filepath)

    # Filter out empty lines
    lines = [l for l in paragraphs if l]

    if not lines:
        return None

    recipe = {
        'name': '',
        'prep_time': None,
        'cook_time': None,
        'rest_time': None,
        'servings': None,
        'notes': None,
        'ingredients': [],  # list of (sort_order, group, description)
        'directions': [],   # list of (step_number, group, instruction)
    }

    # First non-empty line is typically the recipe name
    recipe['name'] = lines[0].strip().rstrip('\t')

    # Find sections
    section = 'header'  # header, ingredients, directions, notes
    ingredient_group = None
    direction_group = None
    ing_order = 0
    step_num = 0
    time_found = False

    for i, line in enumerate(lines[1:], 1):
        line_lower = line.lower().strip()

        # Check for time line
        if not time_found and ('prep time' in line_lower or 'cook time' in line_lower or 'prep' in line_lower and 'min' in line_lower):
            prep, cook, rest = parse_time_field(line)
            if prep:
                recipe['prep_time'] = prep
            if cook:
                recipe['cook_time'] = cook
            if rest:
                recipe['rest_time'] = rest
            time_found = True
            continue

        # Check for rest time on its own line
        if not recipe['rest_time'] and 'rest time' in line_lower:
            _, _, rest = parse_time_field(line)
            if rest:
                recipe['rest_time'] = rest
            continue

        # Check for servings
        if section == 'header' and ('serving' in line_lower or 'dozen' in line_lower or 'makes' in line_lower):
            recipe['servings'] = line.strip()
            continue

        # Detect section transitions
        if line_lower in ('ingredients', 'ingredient'):
            section = 'ingredients'
            ingredient_group = None
            continue

        if line_lower in ('directions', 'direction', 'instructions', 'preparation'):
            section = 'directions'
            direction_group = None
            continue

        if line_lower in ('notes', 'note'):
            section = 'notes'
            continue

        # Process based on current section
        if section == 'header':
            # Could be servings or time info we missed
            if re.match(r'^\d+\s+[Ss]erving', line):
                recipe['servings'] = line.strip()
            elif 'approximately' in line_lower:
                recipe['servings'] = line.strip()
            continue

        if section == 'ingredients':
            # Check if this is a sub-group header like "For the sauce"
            if line_lower.startswith('for the ') or line_lower.startswith('for rest') or line_lower.startswith('for the rest'):
                ingredient_group = line.strip()
                continue

            # Check for ingredient group headers (lines that are labels, not ingredients)
            # These are typically short, capitalized lines without quantities
            if (line.strip().endswith(':') or
                (len(line.strip().split()) <= 4 and not re.match(r'^[\d½¼¾⅓⅔⅛(]', line.strip()) and
                 line.strip() not in ('', ) and
                 not any(unit in line_lower for unit in ['cup', 'tbsp', 'tsp', 'oz', 'lb', 'can', 'pkg', 'bag']))):
                # Could be a group header like "Taco Seasoning"
                # But be careful - some ingredients don't start with numbers
                # Only treat as group if it looks like a header
                if (line.strip().endswith(':') or
                    (i + 1 < len(lines) and re.match(r'^[\d½¼¾⅓⅔⅛(]', lines[min(i+1, len(lines)-1)].strip()))):
                    ingredient_group = line.strip().rstrip(':')
                    continue

            ing_order += 1
            recipe['ingredients'].append((ing_order, ingredient_group, line.strip()))

        elif section == 'directions':
            # Check for direction sub-groups like "Optional"
            if line_lower in ('optional', 'optional:'):
                direction_group = 'Optional'
                continue

            # Strip leading step numbers like "1." or "1)"
            instruction = re.sub(r'^\d+[\.\)]\s*', '', line.strip())

            if instruction:
                step_num += 1
                recipe['directions'].append((step_num, direction_group, instruction))

        elif section == 'notes':
            if recipe['notes']:
                recipe['notes'] += '\n' + line.strip()
            else:
                recipe['notes'] = line.strip()

    return recipe


def import_recipes():
    conn = pyodbc.connect(CONN_STR)
    cursor = conn.cursor()

    # Insert categories
    category_ids = {}
    for cat_name in CATEGORIES:
        cursor.execute("INSERT INTO Categories (CategoryName) OUTPUT INSERTED.CategoryID VALUES (?)", cat_name)
        category_ids[cat_name] = int(cursor.fetchone()[0])

    conn.commit()
    print(f"Inserted {len(category_ids)} categories")

    total_recipes = 0
    total_ingredients = 0
    total_directions = 0
    errors = []

    # Process each category folder
    for cat_name in CATEGORIES:
        cat_path = os.path.join(BASE_PATH, cat_name)
        if not os.path.isdir(cat_path):
            print(f"  Skipping missing folder: {cat_name}")
            continue

        cat_id = category_ids[cat_name]

        for filename in sorted(os.listdir(cat_path)):
            if not filename.endswith('.docx'):
                continue

            filepath = os.path.join(cat_path, filename)
            try:
                recipe = parse_recipe(filepath)
                if not recipe:
                    errors.append(f"Empty recipe: {filepath}")
                    continue

                # Insert recipe
                cursor.execute("""
                    INSERT INTO Recipes (CategoryID, RecipeName, PrepTime, CookTime, RestTime, Servings, Notes)
                    OUTPUT INSERTED.RecipeID
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                """, cat_id, recipe['name'], recipe['prep_time'], recipe['cook_time'],
                     recipe['rest_time'], recipe['servings'], recipe['notes'])
                recipe_id = int(cursor.fetchone()[0])
                total_recipes += 1

                # Insert ingredients
                for sort_order, group, desc in recipe['ingredients']:
                    cursor.execute("""
                        INSERT INTO RecipeIngredients (RecipeID, SortOrder, IngredientGroup, Description)
                        VALUES (?, ?, ?, ?)
                    """, recipe_id, sort_order, group, desc)
                    total_ingredients += 1

                # Insert directions
                for step_num, group, instruction in recipe['directions']:
                    cursor.execute("""
                        INSERT INTO RecipeDirections (RecipeID, StepNumber, DirectionGroup, Instruction)
                        VALUES (?, ?, ?, ?)
                    """, recipe_id, step_num, group, instruction)
                    total_directions += 1

                print(f"  Imported: {recipe['name']} ({len(recipe['ingredients'])} ingredients, {len(recipe['directions'])} steps)")

            except Exception as e:
                errors.append(f"Error with {filepath}: {str(e)}")
                print(f"  ERROR: {filename} - {str(e)}")

    # Handle loose files in the root of Tried and True Recipes
    for filename in sorted(os.listdir(BASE_PATH)):
        filepath = os.path.join(BASE_PATH, filename)
        if not filename.endswith('.docx') or os.path.isdir(filepath):
            continue

        try:
            recipe = parse_recipe(filepath)
            if not recipe:
                continue

            # Guess category from name
            name_lower = recipe['name'].lower()
            if 'chicken' in name_lower:
                cat_id = category_ids['Chicken']
            elif 'beef' in name_lower:
                cat_id = category_ids['Beef']
            else:
                cat_id = category_ids['Dinner']  # default

            cursor.execute("""
                INSERT INTO Recipes (CategoryID, RecipeName, PrepTime, CookTime, RestTime, Servings, Notes)
                OUTPUT INSERTED.RecipeID
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, cat_id, recipe['name'], recipe['prep_time'], recipe['cook_time'],
                 recipe['rest_time'], recipe['servings'], recipe['notes'])
            recipe_id = int(cursor.fetchone()[0])
            total_recipes += 1

            for sort_order, group, desc in recipe['ingredients']:
                cursor.execute("""
                    INSERT INTO RecipeIngredients (RecipeID, SortOrder, IngredientGroup, Description)
                    VALUES (?, ?, ?, ?)
                """, recipe_id, sort_order, group, desc)
                total_ingredients += 1

            for step_num, group, instruction in recipe['directions']:
                cursor.execute("""
                    INSERT INTO RecipeDirections (RecipeID, StepNumber, DirectionGroup, Instruction)
                    VALUES (?, ?, ?, ?)
                """, recipe_id, step_num, group, instruction)
                total_directions += 1

            print(f"  Imported (loose): {recipe['name']}")

        except Exception as e:
            errors.append(f"Error with {filepath}: {str(e)}")

    conn.commit()
    conn.close()

    print(f"\n{'='*50}")
    print(f"IMPORT COMPLETE")
    print(f"{'='*50}")
    print(f"Recipes:      {total_recipes}")
    print(f"Ingredients:  {total_ingredients}")
    print(f"Directions:   {total_directions}")

    if errors:
        print(f"\nErrors ({len(errors)}):")
        for e in errors:
            print(f"  - {e}")


if __name__ == '__main__':
    import_recipes()
