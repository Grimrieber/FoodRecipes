<%@ Page Language="VB" AutoEventWireup="true" CodeFile="RecipeBook.aspx.vb" Inherits="RecipeBook" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Tried &amp; True Recipe Book</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Lora:wght@400;700&family=Source+Sans+Pro:wght@300;400;600&display=swap');

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Source Sans Pro', sans-serif;
            background: #f5f0eb;
            color: #3a3a3a;
        }

        /* Header */
        .site-header {
            background: #2c1810;
            color: #f5f0eb;
            padding: 30px 0;
            text-align: center;
            border-bottom: 4px solid #8b4513;
        }
        .site-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.8em;
            font-weight: 700;
            letter-spacing: 2px;
        }
        .site-header p {
            font-family: 'Lora', serif;
            font-style: italic;
            font-size: 1.1em;
            margin-top: 5px;
            color: #d4b896;
        }

        /* Search Area */
        .search-section {
            max-width: 900px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .search-bar {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
        }
        .search-bar input[type="text"] {
            flex: 1;
            padding: 14px 20px;
            font-size: 1.1em;
            font-family: 'Source Sans Pro', sans-serif;
            border: 2px solid #c9b99a;
            border-radius: 8px;
            background: #fff;
            outline: none;
            transition: border-color 0.2s;
        }
        .search-bar input[type="text"]:focus {
            border-color: #8b4513;
        }
        .search-bar button, .btn {
            padding: 14px 28px;
            font-size: 1em;
            font-family: 'Source Sans Pro', sans-serif;
            font-weight: 600;
            background: #8b4513;
            color: #fff;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: background 0.2s;
        }
        .search-bar button:hover, .btn:hover {
            background: #6d3610;
        }

        /* Category Filter */
        .category-filter {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 20px;
        }
        .category-filter a {
            padding: 6px 16px;
            background: #fff;
            border: 1px solid #c9b99a;
            border-radius: 20px;
            text-decoration: none;
            color: #5a4a3a;
            font-size: 0.9em;
            transition: all 0.2s;
        }
        .category-filter a:hover, .category-filter a.active {
            background: #8b4513;
            color: #fff;
            border-color: #8b4513;
        }

        /* Recipe List (Search Results) */
        .recipe-list {
            max-width: 900px;
            margin: 0 auto;
            padding: 0 20px;
        }
        .recipe-list-item {
            background: #fff;
            border-radius: 10px;
            padding: 18px 24px;
            margin-bottom: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
            border: 1px solid #e8e0d5;
            transition: all 0.2s;
        }
        .recipe-list-item:hover {
            border-color: #8b4513;
            box-shadow: 0 2px 12px rgba(139,69,19,0.12);
        }
        .recipe-list-item .recipe-info h3 {
            font-family: 'Lora', serif;
            font-size: 1.2em;
            color: #2c1810;
        }
        .recipe-list-item .recipe-info .meta {
            font-size: 0.9em;
            color: #8a7a6a;
            margin-top: 4px;
        }
        .recipe-list-item .category-badge {
            padding: 4px 14px;
            background: #f5f0eb;
            border-radius: 15px;
            font-size: 0.8em;
            color: #8b4513;
            font-weight: 600;
            white-space: nowrap;
        }

        /* Cookbook Recipe Detail Page */
        .recipe-page {
            max-width: 800px;
            margin: 30px auto;
            background: #fffdf8;
            border-radius: 12px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.08);
            border: 1px solid #e8e0d5;
            overflow: hidden;
        }

        .recipe-page-header {
            background: linear-gradient(135deg, #2c1810, #4a2c1a);
            padding: 35px 40px;
            color: #fff;
        }
        .recipe-page-header h2 {
            font-family: 'Playfair Display', serif;
            font-size: 2.2em;
            margin-bottom: 6px;
        }
        .recipe-page-header .category-label {
            font-family: 'Lora', serif;
            font-style: italic;
            color: #d4b896;
            font-size: 1.05em;
        }

        .recipe-meta-bar {
            display: flex;
            flex-wrap: wrap;
            gap: 24px;
            padding: 20px 40px;
            background: #f9f5f0;
            border-bottom: 1px solid #e8e0d5;
        }
        .meta-item {
            text-align: center;
        }
        .meta-item .label {
            font-size: 0.75em;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #8a7a6a;
            font-weight: 600;
        }
        .meta-item .value {
            font-size: 1.1em;
            font-weight: 600;
            color: #2c1810;
            margin-top: 2px;
        }

        .recipe-body {
            padding: 30px 40px;
        }

        .recipe-body h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.4em;
            color: #2c1810;
            margin-bottom: 15px;
            padding-bottom: 8px;
            border-bottom: 2px solid #e8e0d5;
        }

        .ingredients-section {
            margin-bottom: 35px;
        }
        .ingredient-group-label {
            font-family: 'Lora', serif;
            font-style: italic;
            font-weight: 700;
            color: #8b4513;
            margin: 14px 0 6px 0;
            font-size: 1em;
        }
        .ingredients-list {
            list-style: none;
            padding: 0;
        }
        .ingredients-list li {
            padding: 7px 0;
            border-bottom: 1px dotted #e0d8ce;
            font-size: 1.05em;
            line-height: 1.4;
        }
        .ingredients-list li:last-child {
            border-bottom: none;
        }

        .directions-section {
            margin-bottom: 35px;
        }
        .direction-group-label {
            font-family: 'Lora', serif;
            font-style: italic;
            font-weight: 700;
            color: #8b4513;
            margin: 18px 0 8px 0;
            font-size: 1em;
        }
        .directions-list {
            list-style: none;
            padding: 0;
            counter-reset: step-counter;
        }
        .directions-list li {
            padding: 12px 0 12px 48px;
            position: relative;
            font-size: 1.05em;
            line-height: 1.6;
            border-bottom: 1px solid #f0ebe5;
        }
        .directions-list li:last-child {
            border-bottom: none;
        }
        .directions-list li::before {
            counter-increment: step-counter;
            content: counter(step-counter);
            position: absolute;
            left: 0;
            top: 12px;
            width: 32px;
            height: 32px;
            background: #8b4513;
            color: #fff;
            border-radius: 50%;
            text-align: center;
            line-height: 32px;
            font-weight: 700;
            font-size: 0.85em;
        }

        .notes-section {
            margin-bottom: 35px;
            background: #fdf8f0;
            border-left: 4px solid #d4b896;
            padding: 20px 24px;
            border-radius: 0 8px 8px 0;
        }
        .notes-section h3 {
            border-bottom: none;
            padding-bottom: 0;
            margin-bottom: 10px;
        }
        .notes-section p {
            font-size: 1em;
            line-height: 1.6;
            color: #5a4a3a;
        }

        /* Nutrition Card */
        .nutrition-section {
            margin-bottom: 30px;
        }
        .nutrition-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 10px;
        }
        .nutrition-item {
            background: #f9f5f0;
            border-radius: 8px;
            padding: 12px;
            text-align: center;
            border: 1px solid #e8e0d5;
        }
        .nutrition-item .nut-value {
            font-size: 1.3em;
            font-weight: 700;
            color: #2c1810;
        }
        .nutrition-item .nut-label {
            font-size: 0.78em;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #8a7a6a;
            margin-top: 2px;
        }
        .nutrition-note {
            text-align: center;
            font-size: 0.8em;
            color: #aaa;
            margin-top: 10px;
            font-style: italic;
        }

        .back-link {
            display: inline-block;
            margin: 20px 0 0 0;
            padding: 10px 24px;
            background: #8b4513;
            color: #fff;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            transition: background 0.2s;
        }
        .back-link:hover { background: #6d3610; }

        .no-results {
            text-align: center;
            padding: 40px;
            color: #8a7a6a;
            font-size: 1.1em;
            font-style: italic;
        }

        .result-count {
            color: #8a7a6a;
            font-size: 0.9em;
            margin-bottom: 15px;
        }

        @media (max-width: 600px) {
            .recipe-page-header { padding: 25px 20px; }
            .recipe-meta-bar { padding: 15px 20px; gap: 16px; }
            .recipe-body { padding: 20px; }
            .recipe-page-header h2 { font-size: 1.6em; }
            .search-bar { flex-direction: column; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <div class="site-header">
            <h1>Tried &amp; True Recipes</h1>
            <p>Our Family Cookbook</p>
        </div>

        <!-- SEARCH / BROWSE VIEW -->
        <asp:Panel ID="pnlSearch" runat="server">
            <div class="search-section">
                <div class="search-bar">
                    <asp:TextBox ID="txtSearch" runat="server" placeholder="Search recipes or ingredients..." />
                    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" />
                </div>
                <div class="category-filter">
                    <asp:LinkButton ID="lnkAll" runat="server" Text="All" CssClass="active" OnClick="lnkCategory_Click" CommandArgument="0" />
                    <asp:Repeater ID="rptCategories" runat="server">
                        <ItemTemplate>
                            <asp:LinkButton runat="server"
                                Text='<%# Eval("CategoryName") %>'
                                CommandArgument='<%# Eval("CategoryID") %>'
                                OnClick="lnkCategory_Click" />
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <div class="recipe-list">
                <asp:Label ID="lblResultCount" runat="server" CssClass="result-count" />
                <asp:Repeater ID="rptRecipes" runat="server" OnItemCommand="rptRecipes_ItemCommand">
                    <ItemTemplate>
                        <asp:LinkButton runat="server" CommandName="View" CommandArgument='<%# Eval("RecipeID") %>'
                            CssClass="recipe-list-item-link" style="text-decoration:none;color:inherit;display:block;">
                            <div class="recipe-list-item">
                                <div class="recipe-info">
                                    <h3><%# Server.HtmlEncode(Eval("RecipeName").ToString()) %></h3>
                                    <span class="meta">
                                        <%# If(Eval("PrepTime") IsNot DBNull.Value, "Prep: " & Eval("PrepTime").ToString() & " &bull; ", "") %>
                                        <%# If(Eval("CookTime") IsNot DBNull.Value, "Cook: " & Eval("CookTime").ToString() & " &bull; ", "") %>
                                        <%# If(Eval("Servings") IsNot DBNull.Value, Eval("Servings").ToString(), "") %>
                                    </span>
                                </div>
                                <span class="category-badge"><%# Server.HtmlEncode(Eval("CategoryName").ToString()) %></span>
                            </div>
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoResults" runat="server" CssClass="no-results" Visible="false"
                    Text="No recipes found. Try a different search term." />
            </div>
        </asp:Panel>

        <!-- RECIPE DETAIL VIEW -->
        <asp:Panel ID="pnlRecipe" runat="server" Visible="false">
            <div class="search-section">
                <asp:LinkButton ID="lnkBack" runat="server" CssClass="back-link" OnClick="lnkBack_Click"
                    Text="&larr; Back to Recipes" />
            </div>

            <div class="recipe-page">
                <div class="recipe-page-header">
                    <h2><asp:Literal ID="litRecipeName" runat="server" /></h2>
                    <span class="category-label"><asp:Literal ID="litCategory" runat="server" /></span>
                </div>

                <div class="recipe-meta-bar">
                    <asp:Panel ID="pnlPrep" runat="server" CssClass="meta-item">
                        <div class="label">Prep Time</div>
                        <div class="value"><asp:Literal ID="litPrepTime" runat="server" /></div>
                    </asp:Panel>
                    <asp:Panel ID="pnlCook" runat="server" CssClass="meta-item">
                        <div class="label">Cook Time</div>
                        <div class="value"><asp:Literal ID="litCookTime" runat="server" /></div>
                    </asp:Panel>
                    <asp:Panel ID="pnlRest" runat="server" CssClass="meta-item" Visible="false">
                        <div class="label">Rest Time</div>
                        <div class="value"><asp:Literal ID="litRestTime" runat="server" /></div>
                    </asp:Panel>
                    <asp:Panel ID="pnlServings" runat="server" CssClass="meta-item">
                        <div class="label">Servings</div>
                        <div class="value"><asp:Literal ID="litServings" runat="server" /></div>
                    </asp:Panel>
                    <asp:Panel ID="pnlSource" runat="server" CssClass="meta-item" Visible="false">
                        <div class="label">Source</div>
                        <div class="value"><asp:Literal ID="litSource" runat="server" /></div>
                    </asp:Panel>
                </div>

                <div class="recipe-body">
                    <!-- Ingredients -->
                    <div class="ingredients-section">
                        <h3>Ingredients</h3>
                        <asp:Literal ID="litIngredients" runat="server" />
                    </div>

                    <!-- Directions -->
                    <div class="directions-section">
                        <h3>Directions</h3>
                        <asp:Literal ID="litDirections" runat="server" />
                    </div>

                    <!-- Notes -->
                    <asp:Panel ID="pnlNotes" runat="server" CssClass="notes-section" Visible="false">
                        <h3>Notes</h3>
                        <p><asp:Literal ID="litNotes" runat="server" /></p>
                    </asp:Panel>

                    <!-- Nutrition -->
                    <asp:Panel ID="pnlNutrition" runat="server" CssClass="nutrition-section" Visible="false">
                        <h3>Nutrition Per Serving</h3>
                        <div class="nutrition-grid">
                            <div class="nutrition-item">
                                <div class="nut-value"><asp:Literal ID="litCalories" runat="server" /></div>
                                <div class="nut-label">Calories</div>
                            </div>
                            <div class="nutrition-item">
                                <div class="nut-value"><asp:Literal ID="litFat" runat="server" />g</div>
                                <div class="nut-label">Total Fat</div>
                            </div>
                            <div class="nutrition-item">
                                <div class="nut-value"><asp:Literal ID="litSatFat" runat="server" />g</div>
                                <div class="nut-label">Sat. Fat</div>
                            </div>
                            <div class="nutrition-item">
                                <div class="nut-value"><asp:Literal ID="litCholesterol" runat="server" />mg</div>
                                <div class="nut-label">Cholesterol</div>
                            </div>
                            <div class="nutrition-item">
                                <div class="nut-value"><asp:Literal ID="litSodium" runat="server" />mg</div>
                                <div class="nut-label">Sodium</div>
                            </div>
                            <div class="nutrition-item">
                                <div class="nut-value"><asp:Literal ID="litCarbs" runat="server" />g</div>
                                <div class="nut-label">Carbs</div>
                            </div>
                            <div class="nutrition-item">
                                <div class="nut-value"><asp:Literal ID="litFiber" runat="server" />g</div>
                                <div class="nut-label">Fiber</div>
                            </div>
                            <div class="nutrition-item">
                                <div class="nut-value"><asp:Literal ID="litSugar" runat="server" />g</div>
                                <div class="nut-label">Sugar</div>
                            </div>
                            <div class="nutrition-item">
                                <div class="nut-value"><asp:Literal ID="litProtein" runat="server" />g</div>
                                <div class="nut-label">Protein</div>
                            </div>
                        </div>
                        <div class="nutrition-note">
                            <asp:Literal ID="litServingNote" runat="server" /> &mdash; Estimated values
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </asp:Panel>

    </form>
</body>
</html>
