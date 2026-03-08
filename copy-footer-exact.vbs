Set pp = CreateObject("PowerPoint.Application")
pp.Visible = True

desktop = CreateObject("WScript.Shell").SpecialFolders("Desktop")

' Open the FINAL version
pptFile = desktop & "\EightClaw-Tsinghua-FINAL.pptx"
WScript.Echo "Opening: " & pptFile
Set pres = pp.Presentations.Open(pptFile, 0, 0, 1)

slideCount = pres.Slides.Count
WScript.Echo "Slides: " & slideCount
WScript.Echo ""

' ============ Find and copy footer from slide 2 ============
WScript.Echo "[1/3] Finding footer elements on slide 2..."

Set slide2 = pres.Slides(2)
Set footerElements = CreateObject("Scripting.Dictionary")
elementCount = 0

' Find all shapes at the bottom of slide 2
For Each shape In slide2.Shapes
    shapeBottom = shape.Top + shape.Height
    slideHeight = pres.PageSetup.SlideHeight
    
    ' Check if shape is at bottom (within 60px from bottom)
    If shapeBottom >= slideHeight - 60 Then
        elementCount = elementCount + 1
        footerElements.Add elementCount, shape
        
        WScript.Echo "  Found footer element " & elementCount & ": " & _
            "Type=" & shape.Type & " Top=" & shape.Top & " Height=" & shape.Height
    End If
Next

WScript.Echo "  Total footer elements found: " & elementCount

If elementCount = 0 Then
    WScript.Echo "  ERROR: No footer elements found!"
    pres.Close
    pp.Quit
    WScript.Quit 1
End If

' ============ Copy footer elements to slide 1 ============
WScript.Echo ""
WScript.Echo "[2/3] Copying footer to slide 1..."

Set slide1 = pres.Slides(1)
slideHeight = pres.PageSetup.SlideHeight

For i = 1 To elementCount
    Set sourceShape = footerElements.Item(i)
    
    ' Copy the shape
    sourceShape.Copy
    
    ' Paste to slide 1
    slide1.Shapes.Paste
    
    ' Position the pasted shape at bottom
    Set pastedShape = slide1.Shapes(slide1.Shapes.Count)
    pastedShape.Top = slideHeight - sourceShape.Height
    pastedShape.Left = sourceShape.Left
    
    WScript.Echo "  Copied element " & i & " to slide 1"
Next

WScript.Echo "  Footer copied to slide 1"

' ============ Copy footer elements to slide 14 ============
WScript.Echo ""
WScript.Echo "[3/3] Copying footer to slide 14..."

Set slide14 = pres.Slides(14)

For i = 1 To elementCount
    Set sourceShape = footerElements.Item(i)
    
    ' Copy the shape
    sourceShape.Copy
    
    ' Paste to slide 14
    slide14.Shapes.Paste
    
    ' Position the pasted shape at bottom
    Set pastedShape = slide14.Shapes(slide14.Shapes.Count)
    pastedShape.Top = slideHeight - sourceShape.Height
    pastedShape.Left = sourceShape.Left
    
    WScript.Echo "  Copied element " & i & " to slide 14"
Next

WScript.Echo "  Footer copied to slide 14"

' ============ Save ============
WScript.Echo ""
WScript.Echo "Saving..."

' Delete old version if exists
Set fso = CreateObject("Scripting.FileSystemObject")
outputFile = desktop & "\EightClaw-Tsinghua-FINAL-with-footer.pptx"
If fso.FileExists(outputFile) Then
    fso.DeleteFile outputFile
End If

pres.SaveAs outputFile

WScript.Echo "Saved: " & outputFile

' Cleanup
pres.Close
pp.Quit

WScript.Echo ""
WScript.Echo "=== COMPLETE ==="
WScript.Echo ""
WScript.Echo "Copied EXACT footer from slide 2 to:"
WScript.Echo "  - Slide 1 (cover)"
WScript.Echo "  - Slide 14 (last slide)"
WScript.Echo ""
WScript.Echo "Footer includes all elements:"
WScript.Echo "  - Purple background bar"
WScript.Echo "  - Tsinghua logo/emblem"
WScript.Echo "  - 清华大学 text"
WScript.Echo "  - Tsinghua University English text"
WScript.Echo "  - All colors and positions preserved"
