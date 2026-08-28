USE RecipeDB;
GO

-- Full recipe view - shows each recipe with its category, like a cookbook table of contents
CREATE VIEW vw_RecipeOverview AS
SELECT
    r.RecipeID,
    c.CategoryName,
    r.RecipeName,
    r.PrepTime,
    r.CookTime,
    r.RestTime,
    r.Servings,
    r.Difficulty,
    r.Source,
    r.Rating,
    r.IsFavorite,
    r.LastMadeOn,
    r.DateAdded,
    (SELECT COUNT(*) FROM RecipeIngredients ri WHERE ri.RecipeID = r.RecipeID) AS IngredientCount,
    (SELECT COUNT(*) FROM RecipeDirections rd WHERE rd.RecipeID = r.RecipeID) AS DirectionCount,
    CASE WHEN r.Notes IS NOT NULL THEN 1 ELSE 0 END AS HasNotes,
    CASE WHEN n.NutritionID IS NOT NULL THEN 1 ELSE 0 END AS HasNutrition
FROM Recipes r
JOIN Categories c ON r.CategoryID = c.CategoryID
LEFT JOIN RecipeNutrition n ON r.RecipeID = n.RecipeID;
GO

-- Full recipe detail - one row per recipe with ingredients and directions combined into text
CREATE VIEW vw_RecipeDetail AS
SELECT
    r.RecipeID,
    c.CategoryName,
    r.RecipeName,
    r.PrepTime,
    r.CookTime,
    r.RestTime,
    r.Servings,
    r.Difficulty,
    r.Source,
    r.Notes,
    r.Rating,
    r.IsFavorite,
    r.LastMadeOn,
    (SELECT STRING_AGG(
        CASE WHEN ri.IngredientGroup IS NOT NULL
             THEN '  [' + ri.IngredientGroup + '] ' + ri.Description
             ELSE '  ' + ri.Description
        END, CHAR(13) + CHAR(10))
     WITHIN GROUP (ORDER BY ri.SortOrder)
     FROM RecipeIngredients ri WHERE ri.RecipeID = r.RecipeID
    ) AS Ingredients,
    (SELECT STRING_AGG(
        CASE WHEN rd.DirectionGroup IS NOT NULL
             THEN '  [' + rd.DirectionGroup + '] ' + CAST(rd.StepNumber AS VARCHAR) + '. ' + rd.Instruction
             ELSE '  ' + CAST(rd.StepNumber AS VARCHAR) + '. ' + rd.Instruction
        END, CHAR(13) + CHAR(10))
     WITHIN GROUP (ORDER BY rd.StepNumber)
     FROM RecipeDirections rd WHERE rd.RecipeID = r.RecipeID
    ) AS Directions,
    n.CaloriesPerServing,
    n.TotalFatGrams,
    n.ProteinGrams,
    n.TotalCarbsGrams
FROM Recipes r
JOIN Categories c ON r.CategoryID = c.CategoryID
LEFT JOIN RecipeNutrition n ON r.RecipeID = n.RecipeID;
GO

-- Category summary view
CREATE VIEW vw_CategorySummary AS
SELECT
    c.CategoryID,
    c.CategoryName,
    COUNT(r.RecipeID) AS RecipeCount,
    SUM(CASE WHEN r.IsFavorite = 1 THEN 1 ELSE 0 END) AS FavoriteCount
FROM Categories c
LEFT JOIN Recipes r ON c.CategoryID = r.CategoryID
GROUP BY c.CategoryID, c.CategoryName;
GO

-- Recipe search view - flattened for easy searching by ingredient or tag
CREATE VIEW vw_RecipeSearch AS
SELECT
    r.RecipeID,
    c.CategoryName,
    r.RecipeName,
    r.Servings,
    r.PrepTime,
    r.CookTime,
    ri.Description AS Ingredient,
    t.TagName
FROM Recipes r
JOIN Categories c ON r.CategoryID = c.CategoryID
LEFT JOIN RecipeIngredients ri ON r.RecipeID = ri.RecipeID
LEFT JOIN RecipeTags t ON r.RecipeID = t.RecipeID;
GO
