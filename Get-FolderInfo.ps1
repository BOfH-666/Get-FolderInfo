<#
    .SYNOPSIS
        Show information about a particular folder

    .DESCRIPTION
        The function Get-FolderInfo determines the size and the count of the files and subfolders of a given directory. (To improve the performance of the function it utilizes the command line tool Robocopy )

    .PARAMETER  Path
        Complete path of the folder.

    .PARAMETER  HumanFriendlyFormat
        Formats the output in a for humans easier readable format.

    .EXAMPLE
        PS C:\> Get-FolderInfo

        Without any further parameter Get-FolderInfo determines the size and the count of files and subfolders of the current directory.

    .EXAMPLE
        PS C:\> Get-FolderInfo -Path C:\windows\system32

        This command will determine the size and the count of files and subfolders of the given directory.

    .EXAMPLE
        PS C:\> Get-ChildItem -Path C:\users -Directory | Get-FolderInfo 

        This command will determine the size and the count of files and subfolders of the directory C:\users.

    .EXAMPLE
        PS C:\> 'C:\temp', 'C:\Windows\Temp', "$ENV:TEMP" | Get-FolderInfo 

        This command will determine the size and the count of files and subfolders of given three temp directories.
    .EXAMPLE
        PS c:\> Get-ChildItem -Path 'a particular folder containing subfolders' -Directory | Get-FolderInfo | Sort-Object -Property SubFolders,FileCount,Bytes -Descending

        This command will determine the size and the count of files and subfolders of 'a particular folder containing subfolders' and sort it descanding for SubFolder, FileCount and Bytes.
    .INPUTS
        System.IO.DirectoryInfo

    .OUTPUTS
        System.String
        System.Int64

    .NOTES
        Author: O.Soyk
        Date:   20150604

    .LINK
        http://social.technet.microsoft.com/wiki/contents/articles/1073.robocopy-and-a-few-examples.aspx

    .LINK
        https://technet.microsoft.com/en-us/library/cc733145(v=ws.10).aspx
#>
Function Get-FolderInfo {
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(ValueFromPipeline = $true,
            Position = 0, 
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo[]]
        $Path = (Get-Location).Path,
        [parameter(Mandatory = $false)]
        [alias("HFF", "Format")]
        [Switch]
        $HumanFriendlyFormat
    )
    process {
        Foreach ($Item in $Path) {
            $Result = robocopy $([REGEX]::Replace($Item.FullName, '\\$', '')) $([System.IO.Path]::GetTempPath()) /E /L /R:0 /NFL /NDL /NC /BYTES /NP /NJH /XJ /XJD /XJF
            Write-Verbose "Result:`n'$($Result)'"

            $Result -match '(FEHLER|ERROR)\s5\s\(' | Out-Null
            If ($Matches) { Write-Debug "`nFolder: '$($Item)' - 'Access denied'`n" }

            $Result | Where-Object { $_ -match '(Dateien|Files\s)\:\s+(\d+)\s' } | Out-Null
            Write-Verbose "Matches:`n '$($Matches)'"
            $FileCount = $Matches[2]

            $Result | Where-Object { $_ -match '(Verzeich\.|Dirs\s)\:\s+(\d+)\s' } | Out-Null
            $SubfolderCount = $Matches[2]

            $Size = (($Result | Where-Object { $_ -match 'Bytes' }).trim() -replace '\s+', ' ').split(' ')[2]

            if ($HumanFriendlyFormat) {
                $SubFolderStringLength = $SubfolderCount.ToCharArray().count + [MATH]::Floor(($SubfolderCount.ToCharArray().count - 1 ) / 3)
                $SubfolderColumnName = "{0,$SubFolderStringLength}" -f "Subfolders"
                $FileCountStringLength = $FileCount.ToCharArray().count + [MATH]::Floor(($FileCount.ToCharArray().count - 1 ) / 3)
                $FileCountColumnName = "{0,$FileCountStringLength}" -f "FileCount"
                switch ([Int64]$Size) {
                    { [Int64]$Size / 1TB -gt 1 } { $SizeBytes = "{0,9:###,###.00 TB}" -f [MATH]::Round([Int64]$Size / 1TB, 2 ); break }
                    { [Int64]$Size / 1GB -gt 1 } { $SizeBytes = "{0,9:###.00 GB}" -f [MATH]::Round([Int64]$Size / 1GB, 2 ); break }
                    { [Int64]$Size / 1MB -gt 1 } { $SizeBytes = "{0,9:###.00 MB}" -f [MATH]::Round([Int64]$Size / 1MB, 2 ); break }
                    { [Int64]$Size / 1KB -gt 1 } { $SizeBytes = "{0,9:###.00 KB}" -f [MATH]::Round([Int64]$Size / 1KB, 2 ); break }
                    Default { $SizeBytes = "{0,9:###,##0 B }" -f [Int64]$Size }
                }
                [PSCustomObject]@{
                    Path                 = $Item.FullName 
                    $SubfolderColumnName = "{0,10:###,###,###,###,###,##0}" -f [INT64]$SubfolderCount
                    $FileCountColumnName = "{0,9:###,###,###,###,###,##0}" -f [INT64]$FileCount
                    TotalSize            = $SizeBytes
                }
            }
            else {
                [PSCustomObject]@{
                    Path       = $Item.FullName 
                    Subfolders = [INT64]$SubfolderCount
                    FileCount  = [INT64]$FileCount
                    Bytes      = [Int64]$Size
                }
            }
        }
    }
}
