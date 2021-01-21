# Get-FolderInfo
  
**.SYNOPSIS**  
Displays basic folder info.  
  
**.DESCRIPTION**  
This function shows the file and subfolder count as well as the total size in bytes and in human readable formats. The property "Size" is a string property for human convenience. It cannot be used for calculating or sorting purposses. Therefor you can use the property "Bytes".  
  
**.PARAMETER  Path**  
The folder path to show the info for.  
  
**.EXAMPLE**  

```Powershell
PS C:\> Get-FolderInfo
```
  
This command will show the information about the current working directory.
  
**.EXAMPLE**  

```Powershell
PS C:\> Get-ChildItem -Path $env:USERPROFILE -Directory | Get-FolderInfo | Sort-Object -Property Bytes -Descending
```
  
This command will show the information about all subfolders of the documents folder of the currently logged on user sorted by total size of the folder contents.  
  
**.EXAMPLE**  

```Powershell
PS C:\> Get-FolderInfo -Path D:\Files\Documents,D:\Files\Backup
```
  
This command will show the information about the two specified folders.  
  
**.INPUTS**  
System.IO.DirectoryInfo  
  
**.OUTPUTS**  
FolderInfo  
  
**.NOTES**  
Author: O.Soyk  
Date:   20210118  
(To improve the performance of the function it utilizes the MS Windows command line tool Robocopy)  
  
**.LINK**  
        http://social.technet.microsoft.com/wiki/contents/articles/1073.robocopy-and-a-few-examples.aspx  
**.LINK**  
        https://technet.microsoft.com/en-us/library/cc733145(v=ws.10).aspx  
