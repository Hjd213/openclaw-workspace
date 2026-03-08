Set pp = CreateObject("PowerPoint.Application")
pp.Visible = True

desktop = CreateObject("WScript.Shell").SpecialFolders("Desktop")

' Open the new PPT
pptFile = desktop & "\EightClaw-Tsinghua-FINAL.pptx"
WScript.Echo "Opening: " & pptFile
Set pres = pp.Presentations.Open(pptFile, 0, 0, 1)

WScript.Echo "Slides: " & pres.Slides.Count
WScript.Echo ""

' Optimize each slide
WScript.Echo "Optimizing slides..."

For i = 1 To pres.Slides.Count
    WScript.Echo "  Slide " & i & "/" & pres.Slides.Count
    
    Set slide = pres.Slides(i)
    
    ' Fix background - make sure it follows master
    slide.FollowMasterBackground = -1 ' msoTrue
    
    ' Optimize each shape on the slide
    For Each shape In slide.Shapes
        On Error Resume Next
        
        ' Fix text formatting
        If shape.HasTextFrame Then
            If shape.TextFrame.HasText Then
                ' Set font to Microsoft YaHei (common Chinese font)
                shape.TextFrame.TextRange.Font.Name = "Microsoft YaHei"
                shape.TextFrame.TextRange.Font.NameFarEast = "Microsoft YaHei"
                
                ' Increase contrast for better readability
                shape.TextFrame.TextRange.Font.Bold = -1 ' msoTrue
                
                ' Fix text color for better visibility
                If shape.TextFrame.TextRange.Font.Color.RGB = RGB(255, 255, 255) Then
                    shape.TextFrame.TextRange.Font.Color.RGB = RGB(0, 0, 0)
                End If
            End If
        End If
        
        ' Add shadow to shapes for better visibility against background
        If shape.Type = 1 Or shape.Type = 17 Then ' msoPicture or msoLinkedPicture
            shape.Shadow.Visible = -1 ' msoTrue
            shape.Shadow.Blur = 5
            shape.Shadow.OffsetX = 2
            shape.Shadow.OffsetY = 2
        End If
        
        ' Fix title placeholder
        If shape.PlaceholderFormat.Type = 1 Then ' ppPlaceholderTitle
            shape.TextFrame.TextRange.Font.Size = 32
            shape.TextFrame.TextRange.Font.Bold = -1
        End If
        
        ' Fix subtitle placeholder
        If shape.PlaceholderFormat.Type = 2 Then ' ppPlaceholderSubtitle
            shape.TextFrame.TextRange.Font.Size = 18
            shape.TextFrame.TextRange.Font.Color.RGB = RGB(50, 50, 50)
        End If
        
        On Error GoTo 0
    Next
    
    ' Fix slide layout - apply master layout
    On Error Resume Next
    slide.Layout = 1 ' ppLayoutTitle
    On Error GoTo 0
Next

WScript.Echo ""
WScript.Echo "Saving optimized version..."

' Save as new version
outputFile = desktop & "\EightClaw-Tsinghua-OPTIMIZED.pptx"
pres.SaveAs outputFile

WScript.Echo "Saved: " & outputFile

' Cleanup
pres.Close
pp.Quit

WScript.Echo ""
WScript.Echo "=== OPTIMIZATION COMPLETE ==="
WScript.Echo "Original: EightClaw-Tsinghua-FINAL.pptx"
WScript.Echo "Backup: EightClaw-Tsinghua-FINAL-backup.pptx"
WScript.Echo "Optimized: EightClaw-Tsinghua-OPTIMIZED.pptx"
