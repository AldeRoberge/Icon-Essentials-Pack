param(
    [Parameter(Mandatory = $true)]
    [string]$RootFolder
)

Write-Host "Scanning for PNG files in: $RootFolder" -ForegroundColor Cyan

# Get all PNG files recursively
$pngFiles = Get-ChildItem -Path $RootFolder -Filter *.png -File -Recurse

# Hashtable to store file hashes
$hashTable = @{}

foreach ($file in $pngFiles) {
    try {
        # Compute file hash (SHA256 is strong and built-in)
        $hash = (Get-FileHash -Algorithm SHA256 -Path $file.FullName).Hash

        if ($hashTable.ContainsKey($hash)) {
            # If hash already exists, add to list
            $hashTable[$hash] += ,$file
        } else {
            # Initialize new list for this hash
            $hashTable[$hash] = @($file)
        }
    } catch {
        Write-Warning "Failed to hash file: $($file.FullName)"
    }
}

# Process duplicates
foreach ($entry in $hashTable.GetEnumerator()) {
    $files = $entry.Value

    if ($files.Count -gt 1) {
        Write-Host "`nDuplicate group found ($($files.Count) files):" -ForegroundColor Yellow
        $files | ForEach-Object { Write-Host "  $($_.FullName)" }

        # Sort by CreationTime and delete the oldest ones
        $sorted = $files | Sort-Object CreationTime -Descending
        $toKeep = $sorted[0]
        $toDelete = $sorted | Select-Object -Skip 1

        Write-Host "Keeping newest: $($toKeep.FullName)" -ForegroundColor Green
        foreach ($f in $toDelete) {
            try {
                Remove-Item -Path $f.FullName -Force
                Write-Host "Deleted: $($f.FullName)" -ForegroundColor Red
            } catch {
                Write-Warning "Failed to delete: $($f.FullName)"
            }
        }
    }
}

Write-Host "`nCleanup complete!" -ForegroundColor Cyan
