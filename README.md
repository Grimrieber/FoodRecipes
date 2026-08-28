# FoodRecipes

A recipe manager with nutrition data — recipes are stored with ingredients and quantities, and
nutrition is calculated from a reference nutrient database.

**Stack** — VB.NET · ASP.NET · SQL Server


## Status

*Verified 28 Aug 2026 — builds with 0 errors; `RecipeBook.aspx` served HTTP 200 under IIS Express
after building the database from the scripts in `SQL/`, which applied with no errors.*

**Working**
- **`RecipeBook.aspx` is the entry point** — there is no `Default.aspx`, so browsing the site root
  returns 404. Go to `/RecipeBook.aspx` directly.
- Recipe browse, category filter, search, and recipe detail with ingredients, directions, timings,
  and a nutrition breakdown
- `SQL/CreateTables.sql`, `CreateViews.sql`, and `CreateProcs.sql` all apply cleanly — 6 tables,
  4 views, 1 stored procedure

**Needs setup**
- Recipes are loaded by `SQL/ImportRecipes.py`, which reads `.docx` files from a folder you point
  it at with the `RECIPE_PATH` environment variable. Without that step the book is empty.

**Not built**
- No add/edit UI — recipes come in through the import script only
- Nutrition figures come from reference data loaded by `InsertNutrition.sql`; there is no
  per-ingredient calculation at runtime

The database work is the point here: views and stored procedures written by hand, not generated.

## Database

This project keeps its full schema in source: `SQL/CreateTables.sql`, `SQL/CreateViews.sql`, and
`SQL/CreateProcs.sql`, with reference data in `SQL/InsertNutrition.sql`. `ImportRecipes.py` loads
recipe data into the schema.

Build it with:
```
sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "CREATE DATABASE RecipeDB"
sqlcmd -S "(localdb)\MSSQLLocalDB" -d RecipeDB -I -i SQL/CreateTables.sql
sqlcmd -S "(localdb)\MSSQLLocalDB" -d RecipeDB -I -i SQL/CreateViews.sql
sqlcmd -S "(localdb)\MSSQLLocalDB" -d RecipeDB -I -i SQL/CreateProcs.sql
sqlcmd -S "(localdb)\MSSQLLocalDB" -d RecipeDB -I -i SQL/InsertNutrition.sql
```
