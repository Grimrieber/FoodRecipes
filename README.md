# FoodRecipes

A recipe manager with nutrition data — recipes are stored with ingredients and quantities, and
nutrition is calculated from a reference nutrient database.

**Stack** — VB.NET · ASP.NET · SQL Server

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
