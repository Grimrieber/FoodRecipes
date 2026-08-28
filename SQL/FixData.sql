USE RecipeDB;
GO

-- Fix Lasagna name (had time info in the name due to being on same line in docx)
UPDATE Recipes SET
    RecipeName = 'Better Homes & Gardens Lasagna (1953 Classic)',
    PrepTime = '1 hr 10 min',
    CookTime = '30 min',
    RestTime = '15 min'
WHERE RecipeID = 83;

-- Fix Outback Steakhouse recipe (parsed as "Chef John Politte")
UPDATE Recipes SET
    RecipeName = 'Outback Steakhouse Blooming Onion Sauce',
    PrepTime = '1 min',
    Source = 'Chef John Politte'
WHERE RecipeID = 110;

-- Insert ingredients for Outback Steakhouse recipe
INSERT INTO RecipeIngredients (RecipeID, SortOrder, IngredientGroup, Description) VALUES
(110, 1, NULL, N'½ cup mayo'),
(110, 2, NULL, N'¼ cup creamy horseradish'),
(110, 3, NULL, N'1 Tablespoon ketchup'),
(110, 4, NULL, N'⅓ teaspoon paprika'),
(110, 5, NULL, N'⅓ teaspoon cayenne'),
(110, 6, NULL, N'⅛ dried oregano'),
(110, 7, NULL, N'little salt and pepper');

-- Insert directions for Outback Steakhouse recipe
INSERT INTO RecipeDirections (RecipeID, StepNumber, DirectionGroup, Instruction) VALUES
(110, 1, NULL, 'Mix all the ingredients in a bowl until well combined.'),
(110, 2, NULL, 'Refrigerate for up to one hour.'),
(110, 3, NULL, 'Use as a dip for French fries, onion rings or chicken tenders.'),
(110, 4, NULL, 'Store in an airtight container for up to 2 weeks in the refrigerator.');

-- Fix Wolfgang Puck recipe name
UPDATE Recipes SET RecipeName = N'Wolfgang Puck''s Spaghetti Sauce'
WHERE RecipeID = 117;

-- Fix Cheesy Taco Pasta - directions were missed because header said "Directions for Prep"
DELETE FROM RecipeDirections WHERE RecipeID = 5;
INSERT INTO RecipeDirections (RecipeID, StepNumber, DirectionGroup, Instruction) VALUES
(5, 1, NULL, 'Cook the pasta according to the directions on the box and drain.'),
(5, 2, NULL, 'Add the ground beef to the pan and cook for 4 to 5 minutes or until meat is brown and cooked through.'),
(5, 3, NULL, 'Add the onion and cook for an additional 3 to 4 minutes or until onion is translucent.'),
(5, 4, NULL, 'Drain the fat.'),
(5, 5, NULL, N'Add the taco seasoning and ¼ cup of water, stir and cook until water is gone.'),
(5, 6, NULL, 'Stir in salsa, cheese and pasta.'),
(5, 7, NULL, 'Serve immediately, preferably with crunchy tortilla chips and sour cream (optional) on top.');

-- Fix Brown Sugar Garlic Chicken - directions were missed (used "Oven" / "Stove Top" as headers)
DELETE FROM RecipeDirections WHERE RecipeID = 39;
INSERT INTO RecipeDirections (RecipeID, StepNumber, DirectionGroup, Instruction) VALUES
(39, 1, 'Oven', 'Pre-heat oven to 425 degrees.'),
(39, 2, 'Oven', 'Mix all the ingredients, except the chicken, together in a large bowl.'),
(39, 3, 'Oven', 'Place the chicken into an oven safe cooking dish, pouring the sauce over the chicken in the pan.'),
(39, 4, 'Oven', N'Bake, uncovered, for 20-25 minutes (if the sauce gets a bit dry or thick, remove chicken when done, add ¼ cup water and whisk to loosen sauce, then pour over baked chicken).'),
(39, 5, 'Stove Top', 'In a skillet over medium high heat, sear the chicken for 5-7 minutes, then flip and cook an additional 5 minutes.'),
(39, 6, 'Stove Top', 'Mix all the sauce ingredients together in a large bowl and add to chicken.'),
(39, 7, 'Stove Top', 'Lower the temperature to medium low and let cook until the sauce thickens and coats the chicken, about 8-10 minutes.'),
(39, 8, 'Stove Top', 'Spoon the sauce over the chicken to serve.');

-- Fix Sweet and Sour Meatballs - directions were missed (used "Meatball Directions" as header)
DELETE FROM RecipeDirections WHERE RecipeID = 19;
INSERT INTO RecipeDirections (RecipeID, StepNumber, DirectionGroup, Instruction) VALUES
(19, 1, 'Meatballs', 'Preheat the broiler. Line a sheet pan with foil and coat the foil with cooking spray.'),
(19, 2, 'Meatballs', 'Place the ground beef, eggs, breadcrumbs, onion, salt, pepper and garlic powder in a large bowl. Stir until thoroughly combined.'),
(19, 3, 'Meatballs', 'Shape the meat mixture into 1 inch meatballs and place on the prepared pan.'),
(19, 4, 'Meatballs', 'Broil for 8-10 minutes or until golden brown.'),
(19, 5, 'Meatballs', 'While the meatballs are cooking, prepare the sauce.'),
(19, 6, 'Sauce', 'Melt the grape jelly by microwaving it for 30 second increments or melting it in a saucepan over medium heat.'),
(19, 7, 'Sauce', 'After the jelly has melted, whisk in the chili sauce.'),
(19, 8, 'Stove Top', 'Simmer for about 20 minutes on the stove top, or until your meatballs are cooked through.'),
(19, 9, 'Oven', 'Cook in a covered container at 350 degrees F for 30 minutes, then uncover and bake for another 10-15 minutes.'),
(19, 10, 'Slow Cooker', 'Coat a slow cooker with cooking spray. Add the meatballs, then pour the sauce over the top. Toss to coat.'),
(19, 11, 'Slow Cooker', 'Cook for 3 hours on low. Sprinkle with parsley.');

-- Fix Sweet and Sour Meatballs ingredients - "Sauce" group items were lumped in wrong
-- The parser grabbed Sauce sub-items as regular ingredients. Let's fix the groups.
UPDATE RecipeIngredients SET IngredientGroup = 'Sauce'
WHERE RecipeID = 19 AND Description LIKE '%chili sauce%';
UPDATE RecipeIngredients SET IngredientGroup = 'Sauce'
WHERE RecipeID = 19 AND Description LIKE '%grape jelly%';
UPDATE RecipeIngredients SET IngredientGroup = 'Sauce'
WHERE RecipeID = 19 AND Description LIKE '%parsley%';

-- Fix Scrambled Egg Muffins - ingredients missed due to "Ingredients - Yield: 6 muffins" header
DELETE FROM RecipeIngredients WHERE RecipeID = 26;
INSERT INTO RecipeIngredients (RecipeID, SortOrder, IngredientGroup, Description) VALUES
(26, 1, 'Yield: 6 muffins', '1/6 lb (3 Tbsp) turkey sausage (jimmy dean already cooked in red pouch)'),
(26, 2, 'Yield: 6 muffins', N'2 eggs and ¼ cup egg whites'),
(26, 3, 'Yield: 6 muffins', '1/6 cup (3 Tbsp) chopped onion'),
(26, 4, 'Yield: 6 muffins', 'Chopped green pepper'),
(26, 5, 'Yield: 6 muffins', 'Dash salt'),
(26, 6, 'Yield: 6 muffins', 'Dash garlic powder'),
(26, 7, 'Yield: 6 muffins', 'Dash pepper'),
(26, 8, 'Yield: 6 muffins', '3 Tbsp shredded cheddar cheese'),
(26, 9, 'Yield: 12 muffins', '6 oz turkey sausage (jimmy dean already cooked in red pouch)'),
(26, 10, 'Yield: 12 muffins', N'4 eggs and ¼ cup egg whites'),
(26, 11, 'Yield: 12 muffins', '1/3 cup chopped onion'),
(26, 12, 'Yield: 12 muffins', 'Chopped green pepper'),
(26, 13, 'Yield: 12 muffins', N'½ teaspoon salt'),
(26, 14, 'Yield: 12 muffins', N'½ teaspoon garlic powder'),
(26, 15, 'Yield: 12 muffins', N'½ teaspoon pepper'),
(26, 16, 'Yield: 12 muffins', N'½ cup shredded cheddar cheese'),
(26, 17, 'Yield: 18 muffins', '1 package (9oz) turkey sausage (jimmy dean already cooked in red pouch)'),
(26, 18, 'Yield: 18 muffins', N'6 eggs and ¾ cups egg whites'),
(26, 19, 'Yield: 18 muffins', N'½ cup chopped onion'),
(26, 20, 'Yield: 18 muffins', 'Chopped green pepper'),
(26, 21, 'Yield: 18 muffins', N'¾ teaspoon salt'),
(26, 22, 'Yield: 18 muffins', N'¾ teaspoon garlic powder'),
(26, 23, 'Yield: 18 muffins', N'¾ teaspoon pepper'),
(26, 24, 'Yield: 18 muffins', N'¾ cup shredded cheddar cheese');

-- Update Scrambled Egg Muffins servings
UPDATE Recipes SET Servings = '6, 12, or 18 muffins' WHERE RecipeID = 26;

-- Fix Brown Sugar Garlic Chicken prep/cook times (had non-breaking spaces)
UPDATE Recipes SET PrepTime = '5 min', CookTime = '25 min' WHERE RecipeID = 39;

-- Fix Cheesy Taco Pasta prep/cook times
UPDATE Recipes SET PrepTime = '5 min', CookTime = '20 min' WHERE RecipeID = 5;

GO
