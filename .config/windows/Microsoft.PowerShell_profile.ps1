# Save to $PROFILE
# (you can open it via: `notepad $PROFILE`)

Set-Alias -Name np -Value C:\Windows\notepad.exe

Import-Module "$HOME\code\dotfiles\.config\windows\GitAliases.psm1" -DisableNameChecking
Import-Module "$HOME\code\dotfiles\.config\windows\WSLTools.psm1" -DisableNameChecking

# to allow duplicating tabs in current directory
function prompt {
   $loc = $executionContext.SessionState.Path.CurrentLocation;
   $out = ""
   if ($loc.Provider.Name -eq "FileSystem") {
       $out += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
   }
   $out += "PS $loc$('>' * ($nestedPromptLevel + 1)) "
   return $out
}
