function Invoke-MySudo { & /usr/bin/env sudo pwsh -command "& $args" }
set-alias sudo invoke-mysudo

oh-my-posh --init --shell pwsh --config ~/Code/oh-my-posh/themes/robbyrussel.omp.json | Invoke-Expression

Clear-Host
