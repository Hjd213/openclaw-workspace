' PPT Template Replacement using VBScript
Option Explicit

Dim ppApp, ppTemplate, ppTarget, ppNew, slide
Dim templateFile, targetFile, outputFile

templateFile = CreateObject("WScript.Shell").SpecialFolders("Desktop") & "\2026 年宁夏回族自治区政府工作报告.pptx"
targetFile = CreateObject("WScript.Shell").SpecialFolders("Desktop") & "\八爪智能 - 高性能无人驾驶激光除草机器人 202509222_2.pptx"
outputFile = CreateObject("WScript.Shell").SpecialFolders("Desktop") & "\八爪智能 - 清华模板.pptx"

WScript.Echo "=== PPT Template Replacement ==="
WScript.Echo "Template: " & templateFile
WScript.Echo "Target: " & targetFile
WScript.Echo ""

' Create PowerPoint application
Set ppApp = CreateObject("PowerPoint.Application")
ppApp.Visible = True

' Open template to get design
WScript.Echo "[1/5] Opening template..."
Set ppTemplate = ppApp.Presentations.Open(templateFile, 0, 0, 0) ' ReadOnly
WScript.Echo "  Slides: " & ppTemplate.Slides.Count

' Open target
WScript.Echo "[2/5] Opening target..."
Set ppTarget = ppApp.Presentations.Open(targetFile, 0, 0, 0) ' ReadOnly
WScript.Echo "  Slides: " & ppTarget.Slides.Count

' Create new presentation
WScript.Echo "[3/5] Creating new..."
Set ppNew = ppApp.Presentations.Add(1)

' Apply design template
WScript.Echo "[4/5] Applying design..."
ppNew.ApplyTemplate templateFile
WScript.Echo "  Design applied"

' Copy all slides
WScript.Echo "[5/5] Copying slides..."
Dim i, slideCount
slideCount = ppTarget.Slides.Count
For i = slideCount To 1 Step -1
    WScript.Echo "  Copying slide " & i & "/" & slideCount
    ppTarget.Slides(i).Copy
    ppNew.Slides.Paste(1)
Next

' Save
WScript.Echo "Saving..."
ppNew.SaveAs outputFile
WScript.Echo "  Saved: " & outputFile

' Cleanup
ppNew.Close
ppTarget.Close
ppTemplate.Close
ppApp.Quit

WScript.Echo ""
WScript.Echo "=== DONE ==="
WScript.Echo "Output: " & outputFile
