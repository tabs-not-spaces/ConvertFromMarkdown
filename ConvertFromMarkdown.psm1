. $PSScriptRoot\exportManuscript.ps1
. $PSScriptRoot\TestPSCodeBlock.ps1

function ConvertFrom-Markdown {
    param (
        $markdownFile = "$pwd\README.md",
        $outputPath = $pwd,
        [ValidateSet("Html", "Docx", "PDF")]
        $OutputType,
        [Switch]$Show
    )

    Write-Progress -Activity "Generating manuscript" -Status "[$(Get-Date)] Creating chapters"
    Export-Manuscript -markdownFile $markdownFile -outputPath $outputPath

    Write-Progress -Activity "Generating manuscript" -Status "[$(Get-Date)] Analyzing PowerShell"
    Test-PSCodeBlock  -markdownFile $markdownFile -outputPath $outputPath

    if (!(Get-Command pandoc.exe -ErrorAction SilentlyContinue)) {return}

    #if ((Get-Command pandoc.exe -ErrorAction SilentlyContinue) -and $AsPDF) {
    if ($OutputType) {
        $targetPath = "$($outputPath)\manuscript"

        # $chapters = (Get-Content "$targetPath\book.txt") -join ' '
        $chapters = (Get-ChildItem $targetPath chap* | ForEach-Object FullName ) -join ' '

        $outFile = "$($targetPath)\book.$($OutputType)"
        Write-Progress -Activity "Generating manuscript" -Status "[$(Get-Date)] Creating $($OutputType)"
        "pandoc $chapters -S --toc --standalone -o $outFile" | Invoke-Expression

        Write-Progress -Activity "Generating manuscript" -Status "[$(Get-Date)] Launching $($OutputType)"
        if ($Show) {
            Invoke-Item $outFile
        }
    }
}

function Test-IsUri {
    param($targetUri)

    [System.Uri]::IsWellFormedUriString($targetUri, 'Absolute')
}