USE RecipeDB;
GO

-- Categories table
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    CategoryImage VARBINARY(MAX) NULL
);
GO

-- Recipes table
CREATE TABLE Recipes (
    RecipeID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    RecipeName NVARCHAR(200) NOT NULL,
    PrepTime NVARCHAR(50) NULL,
    CookTime NVARCHAR(50) NULL,
    RestTime NVARCHAR(50) NULL,
    Servings NVARCHAR(50) NULL,
    Difficulty NVARCHAR(20) NULL,
    Source NVARCHAR(200) NULL,
    Notes NVARCHAR(MAX) NULL,
    RecipeImage VARBINARY(MAX) NULL,
    DateAdded DATETIME NOT NULL DEFAULT GETDATE(),
    LastMadeOn DATE NULL,
    Rating INT NULL,
    IsFavorite BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Recipes_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT CK_Recipes_Rating CHECK (Rating IS NULL OR (Rating >= 1 AND Rating <= 5))
);
GO

-- Recipe Ingredients table
CREATE TABLE RecipeIngredients (
    IngredientID INT IDENTITY(1,1) PRIMARY KEY,
    RecipeID INT NOT NULL,
    SortOrder INT NOT NULL,
    IngredientGroup NVARCHAR(100) NULL,
    Description NVARCHAR(500) NOT NULL,
    CONSTRAINT FK_RecipeIngredients_Recipes FOREIGN KEY (RecipeID) REFERENCES Recipes(RecipeID) ON DELETE CASCADE
);
GO

-- Recipe Directions table
CREATE TABLE RecipeDirections (
    DirectionID INT IDENTITY(1,1) PRIMARY KEY,
    RecipeID INT NOT NULL,
    StepNumber INT NOT NULL,
    DirectionGroup NVARCHAR(100) NULL,
    Instruction NVARCHAR(MAX) NOT NULL,
    CONSTRAINT FK_RecipeDirections_Recipes FOREIGN KEY (RecipeID) REFERENCES Recipes(RecipeID) ON DELETE CASCADE
);
GO

-- Recipe Nutrition table
CREATE TABLE RecipeNutrition (
    NutritionID INT IDENTITY(1,1) PRIMARY KEY,
    RecipeID INT NOT NULL,
    CaloriesPerServing INT NULL,
    TotalFatGrams DECIMAL(6,1) NULL,
    SaturatedFatGrams DECIMAL(6,1) NULL,
    CholesterolMg DECIMAL(6,1) NULL,
    SodiumMg DECIMAL(6,1) NULL,
    TotalCarbsGrams DECIMAL(6,1) NULL,
    FiberGrams DECIMAL(6,1) NULL,
    SugarGrams DECIMAL(6,1) NULL,
    ProteinGrams DECIMAL(6,1) NULL,
    ServingSizeNote NVARCHAR(200) NULL,
    CONSTRAINT FK_RecipeNutrition_Recipes FOREIGN KEY (RecipeID) REFERENCES Recipes(RecipeID) ON DELETE CASCADE,
    CONSTRAINT UQ_RecipeNutrition_RecipeID UNIQUE (RecipeID)
);
GO

-- Recipe Tags table
CREATE TABLE RecipeTags (
    TagID INT IDENTITY(1,1) PRIMARY KEY,
    RecipeID INT NOT NULL,
    TagName NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_RecipeTags_Recipes FOREIGN KEY (RecipeID) REFERENCES Recipes(RecipeID) ON DELETE CASCADE
);
GO

-- Indexes for common queries
CREATE INDEX IX_Recipes_CategoryID ON Recipes(CategoryID);
CREATE INDEX IX_Recipes_RecipeName ON Recipes(RecipeName);
CREATE INDEX IX_Recipes_IsFavorite ON Recipes(IsFavorite);
CREATE INDEX IX_RecipeIngredients_RecipeID ON RecipeIngredients(RecipeID);
CREATE INDEX IX_RecipeDirections_RecipeID ON RecipeDirections(RecipeID);
CREATE INDEX IX_RecipeTags_RecipeID ON RecipeTags(RecipeID);
CREATE INDEX IX_RecipeTags_TagName ON RecipeTags(TagName);
GO
