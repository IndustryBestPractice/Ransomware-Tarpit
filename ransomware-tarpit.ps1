########
#
# Ransomware-Tarpit.ps1
#
# Quick & Dirty example powershell script for generating random files
# when files within a monitored directory are deleted and changed. The idea
# is to create a Tarpit for ransomware where the malware never runs out of 
# files to encrypt.
#
# As seen on https://reddit.com/r/securitycadence
#
# Requires pswatch Powershell module: https://github.com/jfromaniello/pswatch
#
# SrvAny or NSSM can be used to execute as a service, NSSM recommended.
#    https://nssm.cc/download
#
#    https://4sysops.com/archives/how-to-run-a-powershell-script-as-a-windows-service/
#
########
Import-Module pswatch

###### Settings

# Root directory to monitor, will watch sub directories as well
$path = "C:\fileShare"

# File Extensions to use for generated files
$ext = @(".docx", ".doc", ".xlsx", ".xls", ".ppt", ".pptx", ".pdf", ".txt", ".csv")

# Number of files to create when change is detected
$filesToGenerate = 5

# Minimum Space in bytes remaining on the drive of the root directory that must be reached before we delete files
#  Set to 0 if you do not wish to clean up and are fine with running the system out of space.
$minimumSpace = 1073741824

# Send an email on file modify
$sendEmail = $False

# Email Settings
$to = "infosec@industrybestpractice.com"
$from = "ransomwaretarpit@industrybestpractice.com"
$subject = "File Modification in the Ransomware Tarpit!"
$SMTPServer = "smtp.industrybestpractice.com"

###### Quick check of settings

# Makse sure path ends with a backslash
if (-not ($path -match '\\$')) {
	$path += "\"
}

if (-not (Test-Path -Path $path)) {
	write-host "Monitored directory does not exist"
	exit
}

###### Script Body

# For loop watches root directory for changes
watch $path -IncludeDeleted | foreach {
	# File change detected
	write-output "Change made on $($_.path)"
	
	# Get path of file that was modified so that we can create our new files there
	$fileCreatePath = (split-path -path $_.path) + "\"
	
	# Send email alert
	if ($SendEmail) {
		$body = "File $($_.path) was modified!"
		
		Send-MailMessage -From $from -To $to -Subject $subject -body $body -SmtpServer $SMTPServer
	}
	
	if ($minimumSpace -gt 0) {
		# Check Available space and delete files if below minimumSpace
		if ((get-psdrive ($path.split(":")[0])).free -lt $minimumSpace) {
			
			# Remove generated files to free up space
			remove-item -path $path -recurse -force -ea silentlycontinue # will error as it tries to delete files that are being created
		}
	}
	
	# Loop to create files
	1..$filesToGenerate | % {
		
		# Get random extension
		$fileExt = $ext | get-random
		
		# Generate random file name
		$fileName = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 12 |%{[char]$_})
		
		# Determine random file size
		$byteSize = get-random -Minimum 25000 -Maximum 5000000
		
		# Create file
		$out = new-object byte[] $byteSize ; (new-object Random).NextBytes($out); [IO.File]::WriteAllBytes($fileCreatePath + $FileName + $fileExt, $out)
	}
}