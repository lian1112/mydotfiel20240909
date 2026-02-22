# Sync junctions in C:\merged_personal from E:\personal and F:\personal
$merged = "C:\merged_personal"

# Remove broken junctions
Get-ChildItem $merged | Where-Object { $_.Attributes -match 'ReparsePoint' } | ForEach-Object {
    if (-not (Test-Path (Join-Path $_.FullName '.'))) { $_.Delete() }
}

# Add new junctions from E:\personal
Get-ChildItem "E:\personal" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $target = Join-Path $merged $_.Name
    if (-not (Test-Path $target)) { cmd /c mklink /J $target $_.FullName | Out-Null }
}

# Add new junctions from F:\personal
Get-ChildItem "F:\personal" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $target = Join-Path $merged $_.Name
    if (-not (Test-Path $target)) { cmd /c mklink /J $target $_.FullName | Out-Null }
}
