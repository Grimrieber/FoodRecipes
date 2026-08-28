USE RecipeDB;
GO

CREATE PROCEDURE sp_GetRecipe
    @SearchText NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RecipeID INT;

    -- Try exact match first, then partial match
    SELECT TOP 1 @RecipeID = RecipeID
    FROM Recipes
    WHERE RecipeName = @SearchText;

    IF @RecipeID IS NULL
        SELECT TOP 1 @RecipeID = RecipeID
        FROM Recipes
        WHERE RecipeName LIKE '%' + @SearchText + '%'
        ORDER BY LEN(RecipeName);

    IF @RecipeID IS NULL
    BEGIN
        -- No match found, show suggestions
        PRINT 'No recipe found. Did you mean one of these?';
        PRINT '';
        SELECT RecipeName, c.CategoryName
        FROM Recipes r
        JOIN Categories c ON r.CategoryID = c.CategoryID
        WHERE RecipeName LIKE '%' + @SearchText + '%'
        ORDER BY RecipeName;
        RETURN;
    END

    -- Recipe header
    SELECT
        r.RecipeName,
        c.CategoryName AS Category,
        r.PrepTime,
        r.CookTime,
        r.RestTime,
        r.Servings,
        r.Difficulty,
        r.Source,
        r.Rating,
        CASE WHEN r.IsFavorite = 1 THEN 'Yes' ELSE 'No' END AS Favorite,
        r.LastMadeOn
    FROM Recipes r
    JOIN Categories c ON r.CategoryID = c.CategoryID
    WHERE r.RecipeID = @RecipeID;

    -- Ingredients
    SELECT
        CASE
            WHEN IngredientGroup IS NOT NULL THEN '  [' + IngredientGroup + ']'
            ELSE ''
        END AS [Group],
        Description AS Ingredient
    FROM RecipeIngredients
    WHERE RecipeID = @RecipeID
    ORDER BY SortOrder;

    -- Directions
    SELECT
        StepNumber AS Step,
        CASE
            WHEN DirectionGroup IS NOT NULL THEN '[' + DirectionGroup + '] '
            ELSE ''
        END + Instruction AS Direction
    FROM RecipeDirections
    WHERE RecipeID = @RecipeID
    ORDER BY StepNumber;

    -- Notes
    SELECT Notes
    FROM Recipes
    WHERE RecipeID = @RecipeID
    AND Notes IS NOT NULL;

    -- Nutrition (if available)
    SELECT
        CaloriesPerServing AS Calories,
        TotalFatGrams AS [Fat (g)],
        SaturatedFatGrams AS [Sat Fat (g)],
        CholesterolMg AS [Cholesterol (mg)],
        SodiumMg AS [Sodium (mg)],
        TotalCarbsGrams AS [Carbs (g)],
        FiberGrams AS [Fiber (g)],
        SugarGrams AS [Sugar (g)],
        ProteinGrams AS [Protein (g)],
        ServingSizeNote AS [Serving Size]
    FROM RecipeNutrition
    WHERE RecipeID = @RecipeID;
END
GO
