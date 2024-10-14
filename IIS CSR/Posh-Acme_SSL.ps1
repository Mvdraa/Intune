#Install-module Posh-ACME

Import-Module Posh-ACME

Set-PAServer LE_STAGE

New-PACertificate -CSRPath "C:\Temp\Mitchellvanderaa.csr" -AcceptTOS -Contact "1@mitchellvanderaa.com"

