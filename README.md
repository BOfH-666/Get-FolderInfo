# Get-FolderInfo

Show the total size of a given folder, its sub folder count and its file count utilizing robocopy to make it blazing fast



**.SYNOPSIS**  
Show information about a particular folder  
        
**.DESCRIPTION**  
The function Get-FolderInfo determines the size and the count of the files and subfolders of a given directory. (To improve the performance of the function it utilizes the command line tool robocopy )  
        
**.PARAMETER  Path**  
Complete path of the folder.  
        
**.PARAMETER  HumanFriendlyFormat**  
Formats the output in a for humans easier readable format.  
        
**.EXAMPLE**  
`PS C:\> Get-FolderInfo`  
Without any further parameter Get-FolderInfo determines the size and the count of files and subfolders of the current directory.
        
**.EXAMPLE**  
`PS C:\> Get-FolderInfo -Path C:\windows\system32`  
This command will determine the size and the count of files and subfolders of the given directory.  
        
**.EXAMPLE**  
`PS C:\> Get-ChildItem -Path C:\users -Directory | Get-FolderInfo`   
This command will determine the size and the count of files and subfolders of the directory C:\users.  
        
**.EXAMPLE**  
`PS C:\> 'C:\temp', 'C:\Windows\Temp', "$ENV:TEMP" | Get-FolderInfo`   
This command will determine the size and the count of files and subfolders of given three temp directories.  
        
**.EXAMPLE**  
`PS c:\> Get-ChildItem -Path 'a particular folder containing subfolders' -Directory | Get-FolderInfo | Sort-Object -Property SubFolders,FileCount,Bytes -Descending`  
This command will determine the size and the count of files and subfolders of 'a particular folder containing subfolders' and sort it descanding for SubFolder, FileCount and Bytes.  
        
**.INPUTS**  
System.IO.DirectoryInfo  
        
**.OUTPUTS**  
System.String  
System.Int64  
        
**.NOTES**  
Author: O.Soyk  
Date:   20150604  
        
**.LINK**  
        http://social.technet.microsoft.com/wiki/contents/articles/1073.robocopy-and-a-few-examples.aspx  
**.LINK**  
        https://technet.microsoft.com/en-us/library/cc733145(v=ws.10).aspx  

