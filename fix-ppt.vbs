Set pp = CreateObject("PowerPoint.Application")
pp.Visible = True

desktop = CreateObject("WScript.Shell").SpecialFolders("Desktop")

' Open the FINAL version
pptFile = desktop & "\EightClaw-Tsinghua-FINAL.pptx"
WScript.Echo "Opening: " & pptFile
Set pres = pp.Presentations.Open(pptFile, 0, 0, 1)

WScript.Echo "Slides: " & pres.Slides.Count
WScript.Echo ""

' ============ Fix Slide 1 (Cover) ============
WScript.Echo "[Fix 1] Adjusting cover slide fonts..."
Set slide1 = pres.Slides(1)

For Each shape In slide1.Shapes
    On Error Resume Next
    If shape.HasTextFrame Then
        If shape.TextFrame.HasText Then
            ' Keep original font, just ensure readability
            shape.TextFrame.TextRange.Font.Bold = -1
            ' Add shadow for better visibility
            shape.Shadow.Visible = -1
            shape.Shadow.Blur = 3
        End If
    End If
    On Error GoTo 0
Next

' ============ Fix overlapping issues ============
WScript.Echo "[Fix 2] Fixing overlapping issues..."

For i = 2 To pres.Slides.Count
    WScript.Echo "  Processing slide " & i
    
    Set slide = pres.Slides(i)
    slideHeight = pres.PageSetup.SlideHeight
    slideWidth = pres.PageSetup.SlideWidth
    
    For Each shape In slide.Shapes
        On Error Resume Next
        
        ' Fix title shapes that overlap with top elements
        If shape.PlaceholderFormat.Type = 1 Then ' Title
            shapeTop = shape.Top
            shapeHeight = shape.Height
            
            ' If title is too close to top (within 100px), move it down
            If shapeTop < 100 Then
                shape.Top = 120
                WScript.Echo "    Moved title down on slide " & i
            End If
            
            ' Ensure font is readable
            shape.TextFrame.TextRange.Font.Bold = -1
            shape.Shadow.Visible = -1
        End If
        
        ' Fix subtitle shapes
        If shape.PlaceholderFormat.Type = 2 Then ' Subtitle
            shapeTop = shape.Top
            ' If subtitle is too close to top, move it down
            If shapeTop < 150 Then
                shape.Top = 170
            End If
        End If
        
        ' Fix pictures that overlap with bottom elements
        If shape.Type = 13 Then ' msoPicture
            shapeBottom = shape.Top + shape.Height
            ' If picture is too close to bottom (within 80px of bottom), move it up
            If shapeBottom > slideHeight - 80 Then
                shape.Top = shape.Top - (shapeBottom - slideHeight + 80)
                WScript.Echo "    Moved picture up on slide " & i
            End If
            
            ' Add shadow for better layering
            shape.Shadow.Visible = -1
            shape.Shadow.Blur = 5
        End If
        
        ' Fix text boxes that overlap with bottom
        If shape.Type = 17 Then ' msoTextBox
            shapeBottom = shape.Top + shape.Height
            If shapeBottom > slideHeight - 60 Then
                ' Reduce height or move up
                shape.Height = shape.Height - 20
                WScript.Echo "    Adjusted textbox on slide " & i
            End If
        End If
        
        On Error GoTo 0
    Next
    
    ' Ensure background follows master
    slide.FollowMasterBackground = -1
Next

WScript.Echo ""
WScript.Echo "[Fix 3] Saving..."

' Save as new version
outputFile = desktop & "\EightClaw-Tsinghua-FIXED.pptx"
pres.SaveAs outputFile

WScript.Echo "Saved: " & outputFile

' Cleanup
pres.Close
pp.Quit

WScript.Echo ""
WScript.Echo "=== FIX COMPLETE ==="
WScript.Echo "Files:"
WScript.Echo "  Original: EightClaw-Tsinghua-FINAL.pptx"
WScript.Echo "  Backup: EightClaw-Tsinghua-FINAL-backup.pptx"
WScript.Echo "  Optimized (unused): EightClaw-Tsinghua-OPTIMIZED.pptx"
WScript.Echo "  FIXED (new): EightClaw-Tsinghua-FIXED.pptx"
