param(
  [string]$Title = "Codex Finished",
  [string]$Message = "Task completed.",
  [int]$TimeoutSeconds = 6
)

$ErrorActionPreference = "Stop"

function Show-SessionMessage {
  param(
    [string]$PopupTitle,
    [string]$PopupMessage,
    [int]$Timeout
  )

  # msg.exe targets the actively logged-in desktop session and tends to be
  # more reliable than toast APIs in headless/non-UI host contexts.
  $body = "$PopupTitle`n$PopupMessage"
  $safeTimeout = [Math]::Max(1, [Math]::Min(99999, $Timeout))
  $argList = @("*", "/TIME:$safeTimeout", $body)

  $proc = Start-Process -FilePath "msg.exe" -ArgumentList $argList -NoNewWindow -PassThru -Wait
  if ($proc.ExitCode -ne 0) {
    throw "msg.exe exited with code $($proc.ExitCode)."
  }
}

function Show-Toast {
  param(
    [string]$ToastTitle,
    [string]$ToastMessage
  )

  [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
  [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] > $null

  $safeTitle = [System.Security.SecurityElement]::Escape($ToastTitle)
  $safeMessage = [System.Security.SecurityElement]::Escape($ToastMessage)

  $xml = @"
<toast>
  <visual>
    <binding template="ToastGeneric">
      <text>$safeTitle</text>
      <text>$safeMessage</text>
    </binding>
  </visual>
</toast>
"@

  $doc = New-Object Windows.Data.Xml.Dom.XmlDocument
  $doc.LoadXml($xml)

  $toast = [Windows.UI.Notifications.ToastNotification]::new($doc)
  $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Windows.PowerShell")
  $notifier.Show($toast)
}

try {
  Show-SessionMessage -PopupTitle $Title -PopupMessage $Message -Timeout $TimeoutSeconds
  Write-Host "Local session message sent (msg.exe)."
  exit 0
} catch {
  try {
    Show-Toast -ToastTitle $Title -ToastMessage $Message
    Write-Host "Fallback toast notification sent."
    exit 0
  } catch {
    try {
      $wshell = New-Object -ComObject WScript.Shell
      $null = $wshell.Popup($Message, [Math]::Max(1, $TimeoutSeconds), $Title, 64)
      Write-Host "Final fallback popup notification shown."
      exit 0
    } catch {
      Write-Warning "Failed to send local notification: $($_.Exception.Message)"
      exit 1
    }
  }
}
