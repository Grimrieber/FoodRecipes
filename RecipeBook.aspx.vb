Imports System.Data
Imports System.Data.SqlClient
Imports System.Configuration
Imports System.Text

Partial Class RecipeBook
    Inherits System.Web.UI.Page

    Private ReadOnly Property ConnStr As String
        Get
            Return ConfigurationManager.ConnectionStrings("RecipeDB").ConnectionString
        End Get
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            LoadCategories()
            LoadRecipes("", 0)
        End If
    End Sub

    Private Sub LoadCategories()
        Using conn As New SqlConnection(ConnStr)
            Dim cmd As New SqlCommand("SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryName", conn)
            conn.Open()
            rptCategories.DataSource = cmd.ExecuteReader()
            rptCategories.DataBind()
        End Using
    End Sub

    Private Sub LoadRecipes(searchText As String, categoryID As Integer)
        Using conn As New SqlConnection(ConnStr)
            Dim sql As String = "
                SELECT r.RecipeID, r.RecipeName, r.PrepTime, r.CookTime, r.Servings, c.CategoryName
                FROM Recipes r
                JOIN Categories c ON r.CategoryID = c.CategoryID
                WHERE 1=1"

            Dim cmd As New SqlCommand()

            If Not String.IsNullOrWhiteSpace(searchText) Then
                sql &= " AND (r.RecipeName LIKE @Search
                         OR EXISTS (SELECT 1 FROM RecipeIngredients ri WHERE ri.RecipeID = r.RecipeID AND ri.Description LIKE @Search))"
                cmd.Parameters.AddWithValue("@Search", "%" & searchText & "%")
            End If

            If categoryID > 0 Then
                sql &= " AND r.CategoryID = @CatID"
                cmd.Parameters.AddWithValue("@CatID", categoryID)
            End If

            sql &= " ORDER BY c.CategoryName, r.RecipeName"

            cmd.CommandText = sql
            cmd.Connection = conn
            conn.Open()

            Dim dt As New DataTable()
            dt.Load(cmd.ExecuteReader())

            rptRecipes.DataSource = dt
            rptRecipes.DataBind()

            lblResultCount.Text = dt.Rows.Count & " recipe" & If(dt.Rows.Count <> 1, "s", "") & " found"
            lblNoResults.Visible = (dt.Rows.Count = 0)
        End Using
    End Sub

    Protected Sub btnSearch_Click(sender As Object, e As EventArgs)
        pnlSearch.Visible = True
        pnlRecipe.Visible = False
        LoadRecipes(txtSearch.Text.Trim(), 0)

        ' Reset category highlight
        lnkAll.CssClass = If(String.IsNullOrWhiteSpace(txtSearch.Text), "active", "")
    End Sub

    Protected Sub lnkCategory_Click(sender As Object, e As EventArgs)
        Dim btn = CType(sender, LinkButton)
        Dim catID = CInt(btn.CommandArgument)

        pnlSearch.Visible = True
        pnlRecipe.Visible = False
        txtSearch.Text = ""

        LoadRecipes("", catID)

        ' Highlight active category
        lnkAll.CssClass = If(catID = 0, "active", "")
    End Sub

    Protected Sub rptRecipes_ItemCommand(sender As Object, e As RepeaterCommandEventArgs)
        If e.CommandName = "View" Then
            Dim recipeID = CInt(e.CommandArgument)
            ShowRecipe(recipeID)
        End If
    End Sub

    Private Sub ShowRecipe(recipeID As Integer)
        pnlSearch.Visible = False
        pnlRecipe.Visible = True

        Using conn As New SqlConnection(ConnStr)
            conn.Open()

            ' Load recipe header
            Dim cmdRecipe As New SqlCommand("
                SELECT r.RecipeName, c.CategoryName, r.PrepTime, r.CookTime, r.RestTime,
                       r.Servings, r.Source, r.Notes
                FROM Recipes r
                JOIN Categories c ON r.CategoryID = c.CategoryID
                WHERE r.RecipeID = @ID", conn)
            cmdRecipe.Parameters.AddWithValue("@ID", recipeID)

            Using dr = cmdRecipe.ExecuteReader()
                If dr.Read() Then
                    litRecipeName.Text = Server.HtmlEncode(dr("RecipeName").ToString())
                    litCategory.Text = Server.HtmlEncode(dr("CategoryName").ToString())

                    If IsDBNull(dr("PrepTime")) OrElse String.IsNullOrWhiteSpace(dr("PrepTime").ToString()) Then
                        pnlPrep.Visible = False
                    Else
                        pnlPrep.Visible = True
                        litPrepTime.Text = Server.HtmlEncode(dr("PrepTime").ToString())
                    End If

                    If IsDBNull(dr("CookTime")) OrElse String.IsNullOrWhiteSpace(dr("CookTime").ToString()) Then
                        pnlCook.Visible = False
                    Else
                        pnlCook.Visible = True
                        litCookTime.Text = Server.HtmlEncode(dr("CookTime").ToString())
                    End If

                    If IsDBNull(dr("RestTime")) OrElse String.IsNullOrWhiteSpace(dr("RestTime").ToString()) Then
                        pnlRest.Visible = False
                    Else
                        pnlRest.Visible = True
                        litRestTime.Text = Server.HtmlEncode(dr("RestTime").ToString())
                    End If

                    If IsDBNull(dr("Servings")) OrElse String.IsNullOrWhiteSpace(dr("Servings").ToString()) Then
                        pnlServings.Visible = False
                    Else
                        pnlServings.Visible = True
                        litServings.Text = Server.HtmlEncode(dr("Servings").ToString())
                    End If

                    If IsDBNull(dr("Source")) OrElse String.IsNullOrWhiteSpace(dr("Source").ToString()) Then
                        pnlSource.Visible = False
                    Else
                        pnlSource.Visible = True
                        litSource.Text = Server.HtmlEncode(dr("Source").ToString())
                    End If

                    If IsDBNull(dr("Notes")) OrElse String.IsNullOrWhiteSpace(dr("Notes").ToString()) Then
                        pnlNotes.Visible = False
                    Else
                        pnlNotes.Visible = True
                        litNotes.Text = Server.HtmlEncode(dr("Notes").ToString()).Replace(vbCrLf, "<br/>").Replace(vbLf, "<br/>")
                    End If
                End If
            End Using

            ' Load ingredients
            Dim cmdIng As New SqlCommand("
                SELECT SortOrder, IngredientGroup, Description
                FROM RecipeIngredients
                WHERE RecipeID = @ID
                ORDER BY SortOrder", conn)
            cmdIng.Parameters.AddWithValue("@ID", recipeID)

            Dim sbIng As New StringBuilder()
            Dim currentGroup As String = Nothing

            Using dr = cmdIng.ExecuteReader()
                sbIng.Append("<ul class='ingredients-list'>")
                While dr.Read()
                    Dim grp = If(IsDBNull(dr("IngredientGroup")), Nothing, dr("IngredientGroup").ToString())

                    If grp <> currentGroup Then
                        If currentGroup IsNot Nothing Then
                            ' Close previous group
                        End If
                        If grp IsNot Nothing Then
                            sbIng.Append("</ul>")
                            sbIng.Append("<div class='ingredient-group-label'>")
                            sbIng.Append(Server.HtmlEncode(grp))
                            sbIng.Append("</div>")
                            sbIng.Append("<ul class='ingredients-list'>")
                        End If
                        currentGroup = grp
                    End If

                    sbIng.Append("<li>")
                    sbIng.Append(Server.HtmlEncode(dr("Description").ToString()))
                    sbIng.Append("</li>")
                End While
                sbIng.Append("</ul>")
            End Using

            litIngredients.Text = sbIng.ToString()

            ' Load directions
            Dim cmdDir As New SqlCommand("
                SELECT StepNumber, DirectionGroup, Instruction
                FROM RecipeDirections
                WHERE RecipeID = @ID
                ORDER BY StepNumber", conn)
            cmdDir.Parameters.AddWithValue("@ID", recipeID)

            Dim sbDir As New StringBuilder()
            Dim currentDirGroup As String = Nothing

            Using dr = cmdDir.ExecuteReader()
                sbDir.Append("<ol class='directions-list'>")
                While dr.Read()
                    Dim grp = If(IsDBNull(dr("DirectionGroup")), Nothing, dr("DirectionGroup").ToString())

                    If grp <> currentDirGroup Then
                        If currentDirGroup IsNot Nothing Then
                            sbDir.Append("</ol>")
                        End If
                        If grp IsNot Nothing Then
                            sbDir.Append("</ol>")
                            sbDir.Append("<div class='direction-group-label'>")
                            sbDir.Append(Server.HtmlEncode(grp))
                            sbDir.Append("</div>")
                            sbDir.Append("<ol class='directions-list'>")
                        End If
                        currentDirGroup = grp
                    End If

                    sbDir.Append("<li>")
                    sbDir.Append(Server.HtmlEncode(dr("Instruction").ToString()))
                    sbDir.Append("</li>")
                End While
                sbDir.Append("</ol>")
            End Using

            litDirections.Text = sbDir.ToString()

            ' Load nutrition
            Dim cmdNut As New SqlCommand("
                SELECT CaloriesPerServing, TotalFatGrams, SaturatedFatGrams, CholesterolMg,
                       SodiumMg, TotalCarbsGrams, FiberGrams, SugarGrams, ProteinGrams, ServingSizeNote
                FROM RecipeNutrition
                WHERE RecipeID = @ID", conn)
            cmdNut.Parameters.AddWithValue("@ID", recipeID)

            Using dr = cmdNut.ExecuteReader()
                If dr.Read() AndAlso Not IsDBNull(dr("CaloriesPerServing")) Then
                    pnlNutrition.Visible = True
                    litCalories.Text = dr("CaloriesPerServing").ToString()
                    litFat.Text = CDec(dr("TotalFatGrams")).ToString("0.#")
                    litSatFat.Text = CDec(dr("SaturatedFatGrams")).ToString("0.#")
                    litCholesterol.Text = CDec(dr("CholesterolMg")).ToString("0")
                    litSodium.Text = CDec(dr("SodiumMg")).ToString("0")
                    litCarbs.Text = CDec(dr("TotalCarbsGrams")).ToString("0.#")
                    litFiber.Text = CDec(dr("FiberGrams")).ToString("0.#")
                    litSugar.Text = CDec(dr("SugarGrams")).ToString("0.#")
                    litProtein.Text = CDec(dr("ProteinGrams")).ToString("0.#")
                    litServingNote.Text = If(IsDBNull(dr("ServingSizeNote")), "", Server.HtmlEncode(dr("ServingSizeNote").ToString()))
                Else
                    pnlNutrition.Visible = False
                End If
            End Using

        End Using
    End Sub

    Protected Sub lnkBack_Click(sender As Object, e As EventArgs)
        pnlSearch.Visible = True
        pnlRecipe.Visible = False
        LoadRecipes(txtSearch.Text.Trim(), 0)
    End Sub

End Class
