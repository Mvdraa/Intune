#Install-module Posh-ACME

Import-Module Posh-ACME

Set-PAServer LE_PROD

New-PACertificate -CSRPath "C:\Temp\Mitchellvanderaa.csr" -AcceptTOS -Contact "1@mitchellvanderaa.com"

Get-PACertificate | Select-Object -ExpandProperty Certfile | Set-Clipboard
