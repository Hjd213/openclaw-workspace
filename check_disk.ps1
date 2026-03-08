$folders = Get-ChildItem "C:\" -Directory -ErrorAction SilentlyContinue
$results = @()

foreach ($folder in $folders) {
    $size = (Get-ChildItem $folder.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $results += [PSCustomObject]@{
        Folder = $folder.Name
        SizeGB = [math]::Round($size / 1GB, 2)
    }
}

$results | Sort-Object SizeGB -Descending | Format-Table -AutoSize
