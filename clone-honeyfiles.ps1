################################
# clone-honeyfiles.p1
#
# Very simple script to clone the directory structure
# and file names of a production file server to a 
# honeypot file server.
#
#############################

$sourcePath = "\\prodFileServer\FileShare"
$destinationPath = "\\honeyPotFileServer\FileShare"

foreach ($f in (Get-ChildItem -Recurse $sourcePath | Where { ! $_.PSIsContainer } | Select FullName).fullname) {

	$dPath = $f.toLower().replace($sourcePath, $destinationPath)
	
	# Create path if it doesn't exist
	if (-not (Test-Path (split-path -Path $dPath))) {
		new-item -path (split-path -path $dpath) -itemtype "Directory"
	}
	
	# Determine random file size
	$byteSize = get-random -Minimum 25000 -Maximum 5000000
		
	# Create file
	$out = new-object byte[] $byteSize ; (new-object Random).NextBytes($out); [IO.File]::WriteAllBytes($dpath, $out)

}