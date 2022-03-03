function Invoke-MySudo {
  & /usr/bin/env sudo -E pwsh -command "$args"
}

set-alias sudo Invoke-MySudo

# Load starship
Invoke-Expression (&starship init powershell)

#Clear-Host
