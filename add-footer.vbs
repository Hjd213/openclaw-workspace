Set pp = CreateObject("PowerPoint.Application")
pp.Visible = True

desktop = CreateObject("WScript.Shell").SpecialFolders("Desktop")

' Open the FINAL version
pptFile = desktop & "\EightClaw-Tsinghua-FINAL.pptx"
WScript.Echo "Opening: " & pptFile
Set pres = pp.Presentations.Open(pptFile, 0, 0, 1)

WScript.Echo "Slides: " & pres.Slides.Count
WScript.Echo ""

slideCount = pres.Slides.Count

' ============ Find footer from middle slides ============
WScript.Echo "[1/3] Finding footer element from middle slides..."

Set footerShape = Nothing
footerType = ""

' Look for footer in slides 2-5
For i = 2 To 5
    Set slide = pres.Slides(i)
    For Each shape In slide.Shapes
        ' Look for shapes at the bottom of the slide
        shapeBottom = shape.Top + shape.Height
        slideHeight = pres.PageSetup.SlideHeight
        
        If shapeBottom >= slideHeight - 50 Then
            ' Found a bottom element
            If shape.Type = 13 Then ' msoPicture
                Set footerShape = shape
                footerType = "Picture"
                WScript.Echo "  Found footer picture on slide " & i
                Exit For
            ElseIf shape.Type = 17 Or shape.Type = 1 Then ' TextBox or Title
                If InStr(shape.TextFrame.TextRange.Text, "清华") > 0 Or _
                   InStr(shape.TextFrame.TextRange.Text, "Tsinghua") > 0 Then
                    Set footerShape = shape
                    footerType = "TextBox"
                    WScript.Echo "  Found footer text on slide " & i
                    Exit For
                End If
            End If
        End If
    Next
    If Not footerShape Is Nothing Then Exit For
Next

If footerShape Is Nothing Then
    WScript.Echo "  Footer not found! Trying to create one..."
End If

' ============ Add footer to first slide ============
WScript.Echo ""
WScript.Echo "[2/3] Adding footer to first slide..."

Set slide1 = pres.Slides(1)

If Not footerShape Is Nothing Then
    ' Copy footer from middle slide
    footerShape.Copy
    slide1.Shapes.Paste
    
    ' Position at bottom
    Set newShape = slide1.Shapes(slide1.Shapes.Count)
    slideHeight = pres.PageSetup.SlideHeight
    newShape.Top = slideHeight - newShape.Height - 20
    newShape.Left = (pres.PageSetup.SlideWidth - newShape.Width) / 2
    
    WScript.Echo "  Footer added to slide 1"
Else
    ' Create a simple text footer
    slideHeight = pres.PageSetup.SlideHeight
    slideWidth = pres.PageSetup.SlideWidth
    
    Set newShape = slide1.Shapes.AddTextbox(1, slideWidth * 0.1, slideHeight - 40, slideWidth * 0.8, 30)
    With newShape.TextFrame.TextRange
        .Text = "清华大学"
        .Font.Name = "Microsoft YaHei"
        .Font.Size = 14
        .Font.Bold = -1
        .ParagraphFormat.Alignment = 3 ' ppAlignCenter
    End With
    newShape.Fill.Visible = 0 ' No fill
    newShape.Line.Visible = 0 ' No line
    
    WScript.Echo "  Created text footer on slide 1"
End If

' ============ Add footer to last slide ============
WScript.Echo ""
WScript.Echo "[3/3] Adding footer to last slide..."

Set slideLast = pres.Slides(slideCount)

If Not footerShape Is Nothing Then
    ' Copy footer from middle slide
    footerShape.Copy
    slideLast.Shapes.Paste
    
    ' Position at bottom
    Set newShape = slideLast.Shapes(slideLast.Shapes.Count)
    slideHeight = pres.PageSetup.SlideHeight
    newShape.Top = slideHeight - newShape.Height - 20
    newShape.Left = (pres.PageSetup.SlideWidth - newShape.Width) / 2
    
    WScript.Echo "  Footer added to slide " & slideCount
Else
    ' Create a simple text footer
    slideHeight = pres.PageSetup.SlideHeight
    slideWidth = pres.PageSetup.SlideWidth
    
    Set newShape = slideLast.Shapes.AddTextbox(1, slideWidth * 0.1, slideHeight - 40, slideWidth * 0.8, 30)
    With newShape.TextFrame.TextRange
        .Text = "清华大学"
        .Font.Name = "Microsoft YaHei"
        .Font.Size = 14
        .Font.Bold = -1
        .ParagraphFormat.Alignment = 3 ' ppAlignCenter
    End With
    newShape.Fill.Visible = 0
    newShape.Line.Visible = 0
    
    WScript.Echo "  Created text footer on slide " & slideCount
End If

' ============ Save ============
WScript.Echo ""
WScript.Echo "Saving..."

outputFile = desktop & "\EightClaw-Tsinghua-FINAL-with-footer.pptx"
pres.SaveAs outputFile

WScript.Echo "Saved: " & outputFile

' Cleanup
pres.Close
pp.Quit

WScript.Echo ""
WScript.Echo "=== COMPLETE ==="
WScript.Echo "Files:"
WScript.Echo "  EightClaw-Tsinghua-FINAL.pptx (original)"
WScript.Echo "  EightClaw-Tsinghua-FINAL-with-footer.pptx (NEW - with footer on first and last slides)"
