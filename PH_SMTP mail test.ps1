#param([String] $remoteHost =$(throw "Please specify the Target Server"),[String] $domain = $(throw "Please specify the #recipient Domain"),[String] $sendingdomain = $(throw "Please specify the Sending Domain"))

# Set Hostname
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Hostname'
$msg   = 'Enter Hostname or IP:'
$remotehost = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

# Set From Mail Address
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'From Address'
$msg   = 'Enter From Address:'
$sendingdomain = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

# Set To Mail Address
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'To Address'
$msg   = 'Enter To Address:'
$domain = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)


#param([String] $remoteHost,[String] $domain, [String] $sendingdomain)

$Fromdomain = $domain -split '@'

if ($remotehost -eq "" -or $domain -eq "" -or $sendingdomain -eq "") {"Please specify the Target Server, recipient domain and sending domain"
return; }

# Read response from remote server and write as output
function readResponse {

while($stream.DataAvailable)
{
$read = $stream.Read($buffer, 0, 1024)
write-host -n -foregroundcolor cyan ($encoding.GetString($buffer, 0, $read))
""
}
}

# Set server Port
$port = 25
$socket = new-object System.Net.Sockets.TcpClient($remoteHost, $port)
if($socket -eq $null) { return; }

# Send Commands
$stream = $socket.GetStream()
$writer = new-object System.IO.StreamWriter($stream)
$buffer = new-object System.Byte[] 1024
$encoding = new-object System.Text.AsciiEncoding
readResponse($stream)
$command = "HELO "+ $Fromdomain[1]
write-host -foregroundcolor DarkGreen $command
""
$writer.WriteLine($command)
$writer.Flush()
start-sleep -m 500
readResponse($stream)
$command = "MAIL FROM: "+ $domain
write-host -foregroundcolor DarkGreen $command
""
$writer.WriteLine($command)
$writer.Flush()
start-sleep -m 500
readResponse($stream)
$command = "RCPT TO: "+ $sendingdomain
write-host -foregroundcolor DarkGreen $command
""
$writer.WriteLine($command)
$writer.Flush()
start-sleep -m 500
readResponse($stream)
$command = "QUIT"
write-host -foregroundcolor DarkGreen $command
""
$writer.WriteLine($command)
$writer.Flush()
start-sleep -m 500
readResponse($stream)
## Close the streams
$writer.Close()
$stream.Close() 

$a4 = new-object -comobject wscript.shell 
$intAnswer = $a4.popup("Do you want to send a test mail?", ` 
0,"Package list",4) 

If ($intAnswer -eq 6) 
{ 
Send-MailMessage -SMTPServer $remotehost -To $sendingdomain -From $domain -Subject “This is a test email” -Body “This is a test email sent via PS.”
}