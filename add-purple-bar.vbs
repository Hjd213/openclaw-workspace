Set pp = CreateObject("PowerPoint.Application")
pp.Visible = True

desktop = CreateObject("WScript.Shell").SpecialFolders("Desktop")

' Open the FINAL version
pptFile = desktop & "\EightClaw-Tsinghua-FINAL.pptx"
WScript.Echo "Opening: " & pptFile
Set pres = pp.Presentations.Open(pptFile, 0, 0, 1)

slideCount = pres.Slides.Count
slideHeight = pres.PageSetup.SlideHeight
slideWidth = pres.PageSetup.SlideWidth

WScript.Echo "Slides: " & slideCount
WScript.Echo "Size: " & slideWidth & " x " & slideHeight
WScript.Echo ""

' ============ Add purple bar to slide 1 ============
WScript.Echo "[1/2] Adding footer to slide 1..."

Set slide1 = pres.Slides(1)

' Create purple rectangle at bottom
barHeight = 30
Set bar1 = slide1.Shapes.AddShape(1, 0, slideHeight - barHeight, slideWidth, barHeight)
bar1.Fill.ForeColor.RGB = RGB(80, 26, 87)  ' Tsinghua purple
bar1.Line.Visible = 0

' Add text
Set text1 = bar1.TextFrame.TextRange
text1.Text = "清华大学"
text1.Font.Name = "Microsoft YaHei"
text1.Font.Size = 16
text1.Font.Bold = -1
text1.Font.Color.RGB = RGB(255, 255, 255)  ' White text
text1.ParagraphFormat.Alignment = 3  ' Center

WScript.Echo "  Footer added to slide 1"

' ============ Add purple bar to slide 14 ============
WScript.Echo ""
WScript.Echo "[2/2] Adding footer to slide 14..."

Set slide14 = pres.Slides(14)

' Create purple rectangle at bottom
Set bar14 = slide14.Shapes.AddShape(1, 0, slideHeight - barHeight, slideWidth, barHeight)
bar14.Fill.ForeColor.RGB = RGB(80, 26, 87)  ' Tsinghua purple
bar14.Line.Visible = 0

' Add text
Set text14 = bar14.TextFrame.TextRange
text14.Text = "清华大学"
text14.Font.Name = "Microsoft YaHei"
text14.Font.Size = 16
text14.Font.Bold = -1
text14.Font.Color.RGB = RGB(255, 255, 255)  ' White text
text14.ParagraphFormat.Alignment = 3  ' Center

WScript.Echo "  Footer added to slide 14"

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
WScript.Echo ""
WScript.Echo "Added purple footer bars with '清华大学' text to:"
WScript.Echo "  - Slide 1 (cover)"
WScript.Echo "  - Slide 14 (last slide)"
WScript.Echo ""
WScript.Echo "Bar specifications:"
WScript.Echo "  - Color: Tsinghua Purple (RGB: 80, 26, 87)"
WScript.Echo "  - Height: 30px"
WScript.Echo "  - Text: White, Microsoft YaHei, Bold, 16pt"
