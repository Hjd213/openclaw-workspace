Set pp = CreateObject("PowerPoint.Application")
pp.Visible = True

desktop = CreateObject("WScript.Shell").SpecialFolders("Desktop")

' Get files
Set fso = CreateObject("Scripting.FileSystemObject")
Set folder = fso.GetFolder(desktop)
Dim files(), fileCount
fileCount = 0

For Each file In folder.Files
    If LCase(fso.GetExtensionName(file.Name)) = "pptx" Then
        If Left(file.Name, 1) <> "~" And InStr(file.Name, "EightClaw") = 0 And InStr(file.Name, "清华") = 0 Then
            ReDim Preserve files(fileCount)
            files(fileCount) = file.Path
            fileCount = fileCount + 1
        End If
    End If
Next

If fileCount < 2 Then
    WScript.Echo "Need at least 2 PPT files!"
    pp.Quit
    WScript.Quit 1
End If

' Sort by date (newest first)
For i = 0 To fileCount - 1
    For j = i + 1 To fileCount - 1
        If fso.GetFile(files(i)).DateLastModified < fso.GetFile(files(j)).DateLastModified Then
            temp = files(i)
            files(i) = files(j)
            files(j) = temp
        End If
    Next
Next

' files(0) is newest (target), files(1) is oldest (template)
targetFile = files(0)
templateFile = files(1)

WScript.Echo "Template: " & templateFile
WScript.Echo "Target: " & targetFile

' Open presentations
Set templatePres = pp.Presentations.Open(templateFile, 0, 0, 0)
Set targetPres = pp.Presentations.Open(targetFile, 0, 0, 0)

WScript.Echo "Template slides: " & templatePres.Slides.Count
WScript.Echo "Target slides: " & targetPres.Slides.Count

' Create new and apply template
Set newPres = pp.Presentations.Add(1)
newPres.ApplyTemplate templateFile

WScript.Echo "Design applied"

' Copy slides
For i = targetPres.Slides.Count To 1 Step -1
    WScript.Echo "Copying slide " & i
    targetPres.Slides(i).Copy
    newPres.Slides.Paste(1)
Next

' Save
outputFile = desktop & "\EightClaw-Tsinghua-FINAL.pptx"
newPres.SaveAs outputFile

WScript.Echo "Saved: " & outputFile

' Cleanup
newPres.Close
targetPres.Close
templatePres.Close
pp.Quit

WScript.Echo "DONE!"
