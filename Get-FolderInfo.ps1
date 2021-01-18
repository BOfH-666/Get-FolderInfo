
$ScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -parent
Update-FormatData -AppendPath $ScriptRoot\Get-FolderInfo.format.ps1xml

class FolderInfo {
    [System.IO.DirectoryInfo] $path;
    [Int64] $Bytes;
    [Int64] $SubfolderCount;
    [Int64] $FileCount;
    [string] $Size;
    FolderInfo([System.IO.DirectoryInfo] $Path) {
        $this.Path = $Path;

        $Result = robocopy $([REGEX]::Replace( $this.Path, '\\$', '')) $([System.IO.Path]::GetTempPath()) /E /L /R:0 /NFL /NDL /NC /BYTES /NP /NJH /XJ /XJD /XJF

        $Result -match '(FEHLER|ERROR)\s5\s\(' | Out-Null
        If ($Matches) { Write-Debug "`nFolder: '$($this.Path)' - 'Access denied'`n" }

        $Result | Where-Object { $_ -match '(Dateien|Files\s)\:\s+(\d+)\s' } | Out-Null
        Write-Verbose "Matches:`n '$($Matches)'"
        $this.FileCount = $Matches[2]

        $Result | Where-Object { $_ -match '(Verzeich\.|Dirs\s)\:\s+(\d+)\s' } | Out-Null
        $this.SubfolderCount = [Int64]$Matches[2] - 1

        $this.Bytes = [Int64](($Result | Where-Object { $_ -match 'Bytes' }).trim() -replace '\s+', ' ').split(' ')[2]
        switch ([Int64]$this.Bytes) {
            { $this.Bytes -gt 1TB } 
            { $this.Size = "{0,9:n2} TB" -f ($this.Bytes / 1TB) ; break }
            { $this.Bytes -gt 1GB } 
            { $this.Size = "{0,9:n2} GB" -f ($this.Bytes / 1GB) ; break }
            { $this.Bytes -gt 1MB } 
            { $this.Size = "{0,9:n2} MB" -f ($this.Bytes / 1MB) ; break }
            { $this.Bytes -gt 1KB } 
            { $this.Size = "{0,9:n2} KB" -f ($this.Bytes / 1KB) ; break }
            default  
            { $this.Size = "{0,9} B " -f $this.Bytes } 
        }
    }
}

<#
    .SYNOPSIS
        Displays basic folder info.

    .DESCRIPTION
        This function shows the file and subfolder count as well as the total size in bytes and in human readable formats. The property "Size" is a string property for human convenience. It cannot be used for calculating or sorting purposses. Therefor you can use the property "Bytes".

    .PARAMETER  Path
        The folder path to show the info for.

    .EXAMPLE
        PS C:\> Get-FolderInfo

        This command will show the information about the current working directory.

    .EXAMPLE
        PS C:\> Get-ChildItem -Path $env:USERPROFILE -Directory | Get-FolderInfo | Sort-Object -Property Bytes -Descending

        This command will show the information about all subfolders of the documents folder of the currently logged on user sorted by total size of the folder contents.

    .EXAMPLE
        PS C:\> Get-FolderInfo -Path D:\Files\Documents,D:\Files\Backup

        This command will show the information about the two specified folders.

    .INPUTS
        System.IO.DirectoryInfo

    .OUTPUTS
        FolderInfo

    .NOTES
        Author: O.Soyk
        Date:   20210118
        (To improve the performance of the function it utilizes the MS Windows command line tool Robocopy)

    .LINK
        http://social.technet.microsoft.com/wiki/contents/articles/1073.robocopy-and-a-few-examples.aspx

    .LINK
        https://technet.microsoft.com/en-us/library/cc733145(v=ws.10).aspx
#>
Function Get-FolderInfo {
    [CmdletBinding()]
    [OutputType([FolderInfo])]
    param(
        [Parameter(Position = 0, 
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo[]]
        $Path = (Get-Location).Path
    )
    process {
        Foreach ($Item in $Path) {
            [FolderInfo]::new($Item)
        }
    }
}
