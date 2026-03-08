Set pp = CreateObject("PowerPoint.Application")
pp.Visible = True

desktop = CreateObject("WScript.Shell").SpecialFolders("Desktop")

' Open template PPT (government report with Tsinghua template)
templateFile = desktop & "\2026 年宁夏回族自治区政府工作报告.pptx"
WScript.Echo "Opening template: " & templateFile
Set templatePres = pp.Presentations.Open(templateFile, 0, 0, 0)

' Open target PPT
targetFile = desktop & "\EightClaw-Tsinghua-FINAL.pptx"
WScript.Echo "Opening target: " & targetFile
Set targetPres = pp.Presentations.Open(targetFile, 0, 0, 1)

WScript.Echo ""
WScript.Echo "Template slides: " & templatePres.Slides.Count
WScript.Echo "Target slides: " & targetPres.Slides.Count
WScript.Echo ""

' ============ Find footer in template ============
WScript.Echo "[1/3] Finding footer in template (slide 1)..."

Set templateSlide1 = templatePres.Slides(1)
Set footerElements = CreateObject("Scripting.Dictionary")
elementCount = 0
slideHeight = templatePres.PageSetup.SlideHeight

' Find all shapes at the bottom of template slide 1
For Each shape In templateSlide1.Shapes
    shapeBottom = shape.Top + shape.Height
    
    ' Check if shape is at bottom (within 80px from bottom)
    If shapeBottom >= slideHeight - 80 Then
        elementCount = elementCount + 1
        footerElements.Add elementCount, shape
        
        WScript.Echo "  Found footer element " & elementCount & ":" & _
            " Type=" & shape.Type & _
            " Top=" & Round(shape.Top, 1) & _
            " Height=" & Round(shape.Height, 1) & _
            " Left=" & Round(shape.Left, 1) & _
            " Width=" & Round(shape.Width, 1)
    End If
Next

WScript.Echo "  Total footer elements: " & elementCount

If elementCount = 0 Then
    WScript.Echo "  ERROR: No footer found in template!"
    templatePres.Close
    targetPres.Close
    pp.Quit
    WScript.Quit 1
End If

' ============ Copy footer to target slide 1 ============
WScript.Echo ""
WScript.Echo "[2/3] Copying footer to target slide 1..."

Set targetSlide1 = targetPres.Slides(1)
targetHeight = targetPres.PageSetup.SlideHeight

For i = 1 To elementCount
    Set sourceShape = footerElements.Item(i)
    
    ' Copy from template
    sourceShape.Copy
    
    ' Paste to target slide 1
    targetSlide1.Shapes.Paste
    
    ' Position at bottom
    Set pastedShape = targetSlide1.Shapes(targetSlide1.Shapes.Count)
    pastedShape.Top = targetHeight - sourceShape.Height
    pastedShape.Left = sourceShape.Left
    
    WScript.Echo "  Copied element " & i & " to slide 1"
Next

WScript.Echo "  Footer copied to slide 1"

' ============ Copy footer to target slide 14 ============
WScript.Echo ""
WScript.Echo "[3/3] Copying footer to target slide 14..."

Set targetSlide14 = targetPres.Slides(14)

For i = 1 To elementCount
    Set sourceShape = footerElements.Item(i)
    
    ' Copy from template
    sourceShape.Copy
    
    ' Paste to target slide 14
    targetSlide14.Shapes.Paste
    
    ' Position at bottom
    Set pastedShape = targetSlide14.Shapes(targetSlide14.Shapes.Count)
    pastedShape.Top = targetHeight - sourceShape.Height
    pastedShape.Left = sourceShape.Left
    
    WScript.Echo "  Copied element " & i & " to slide 14"
Next

WScript.Echo "  Footer copied to slide 14"

' ============ Save ============
WScript.Echo ""
WScript.Echo "Saving..."

Set fso = CreateObject("Scripting.FileSystemObject")
outputFile = desktop & "\EightClaw-Tsinghua-FINAL-with-footer.pptx"

' Delete old version
If fso.FileExists(outputFile) Then
    fso.DeleteFile outputFile
    WScript.Echo "  Deleted old version"
End If

targetPres.SaveAs outputFile

WScript.Echo "Saved: " & outputFile

' Cleanup
targetPres.Close
templatePres.Close
pp.Quit

WScript.Echo ""
WScript.Echo "=== COMPLETE ==="
WScript.Echo ""
WScript.Echo "Copied footer from TEMPLATE (政府工作报告.pptx) to:"
WScript.Echo "  - EightClaw Slide 1 (cover)"
WScript.Echo "  - EightClaw Slide 14 (last slide)"
WScript.Echo ""
WScript.Echo "Footer elements copied:"
For i = 1 To elementCount
    Set s = footerElements.Item(i)
    WScript.Echo "  " & i & ". Type=" & s.Type & " Size=" & Round(s.Width,0) & "x" & Round(s.Height,0)
Next
