' author: David L. Mileto
' email: david.l.mileto@lmco.com
' cell: 301.247.3120
' This script recursively downloads an index directory of files
' The docList is first populated with the directory which we wish
' to replicate. After which, we download the index of the directory
' and parse all links in the directory (filtering out and links to
' parent directories by ".." identifier).  Links to files are downloaded
' and sub-directories are added to the doclist.  After the initial directory
' is clear, the next item in doclist is evaluated to download all subdirectory
' content

Set hReq = CreateObject("MSXML2.XMLHTTP")
Set oDoc = CreateObject("HTMLFILE")
Set bStream = CreateObject("ADODB.STREAM")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Dim docList, downloadList
redim docList(-1)
redim downloadList(-1)
url = "http://dl.yf.io/bdd100k/models/"
basePath = "http://dl.yf.io/bdd100k/"

push docList, url

x = 0


' The docList is pre-populated with a web page we wish to parse through.
' The web page is a standard apache-like directory index.  The loop goes through
' the web page and finds links to sub-directories and adds those subdirectories
' to the docList.  It also downloads link to a file that it finds.
Do While ( x <= UBound(docList)) 
	Wscript.Echo "GETTING DIRECTORY CONTENTS: " & docList(x)
	
	' We want to recreate the directory on our local device, so we take the url
	' and re-base the base-path from http://... to C:\... or whatever the local
	' directory is.  The following performs the rebase, and creates a new
	' folder if necessary.
	downloadFolder = Replace(docList(x), basePath, "")
	If objFSO.FolderExists(downloadFolder) <> True Then
		objFSO.CreateFolder downloadFolder
	End If
	getDoc(docList(x)) ' Loads the global variable oDoc with html-text contents
	Set a = oDoc.GetElementsByTagName("A") 'Select all hyper-links in oDoc
	For i = 0 To a.length - 1
		' Links aren't correct.  The base path is wrong.  The following fixes
		' them.
		rebasedUrl = ReBase(docList(x), a.item(i).href)
		
		' The following is to filter out links that lead to parent directories.
		' If we don't omit parent directories, we'll have an infinite loop.
		' The function checks if it is indeed a folder, AND also a non-parent
		' directory.  Anything that makes it through gets added to the docList
		If NonParentFolder(rebasedUrl) Then
			WScript.Echo "ADDING SUBDIRECTORY: " & rebasedUrl
			push docList, rebasedUrl
		Else
		
			' The following checks if the link is not a folder, but a file.
			' If it's a file, download it.
			If Right(rebasedURL, 1) <> "/" Then
				Wscript.Echo "--------> " & rebasedUrl
				push downloadList, rebasedUrl
				'Wscript.Echo objFSO.GetFileName(rebasedURL)
				DownloadFile downloadFolder, rebasedURL
			End If
		End If
	Next
	oDoc.Close
	x = x + 1
Loop

WScript.Quit 127  ' End of the main sequence.


' The following are supporting subroutines and functions.

' Given a local folder and a url, this subrountine will download the url 
' contents and save them at the folder location.
Sub DownloadFile(folder, myUrl)
	local_target = folder & "\" & objFSO.GetFileName(myUrl)
	If objFSO.FileExists(local_target) Then
		WScript.Echo local_target & " already exists"
	Else
		hReq.Open "GET", myUrl, false
		hReq.Send
		If hReq.Status <> 200 Then
			WScript.Echo "Site returned non-200 status."
			WScript.Quit 1
		End If
		bStream.type = 1 'binary
		bStream.Open
		bStream.write hReq.ResponseBody
		bStream.SaveToFile local_target
		bStream.Close
	End If
End Sub

' Given a url, getDoc will populate the oDoc global variable with the HTML-text
' contents of the URL.
Sub getDoc(myUrl)
	hReq.Open "GET", myUrl, false
	hReq.Send

	If hReq.Status <> 200 Then
		WScript.Echo "Site returned non-200 status."
		WScript.Quit 1
	End If

	oDoc.Open "text/html", "replace"
	oDoc.Write(hReq.ResponseText)
End Sub

' The NonParentFolder will only return true if the given url is indeed a link
' to a directory AND does not contain .. in its path.  This could be dangerous
' if the target website uses absolute paths for every hyper-link
Function NonParentFolder(url)
	Dim retVal : retVal = False
	If Right(url, 1) = "/" Then
		retVal = True
	End If
	If InStr(url, "..") Then
		retVal = False
	End If
	NonParentFolder = retVal
End Function

' The Rebase function changes everything before the first "/" with the new
' basePath
Function Rebase(basePath, relativePath)
	Dim retVal : retVal = relativePath
	retVal = Replace(retVal, "//", "/")
	retVal = Replace(retVal, "about:", basePath)
	Rebase = retVal
End Function

' Appends an element to an array... much like pushing something onto the stack.
' Yes, it's very inefficient when the arrays get long.
Sub push(arr, var)
	Dim uba
	uba = UBound(arr)
	redim preserve arr(uba + 1)
	arr(uba+1) = var
End Sub