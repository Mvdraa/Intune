Invoke-Command -ScriptBlock {   
    $CertName = Read-Host "CN van certificaat? (i.e. *.mitchellvanderaa.com)"
    $customerName = Read-Host "Klantnaam?"
    $Signature = 'Windows NT$'
    $INFPath = "c:\temp\CSR_$($customerName).inf"
    $CSRPath = "c:\temp\$($customerName).csr"

    $INF = @"
    [Version]
    Signature= "$Signature" 
    [NewRequest]
    Subject = "CN=$CertName, OU=ICT, O=Novion, L=NB, S=Veldhoven, C=NL"
    KeySpec = 1
    KeyLength = 2048
    Exportable = TRUE
    MachineKeySet = TRUE
    SMIME = False
    ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
    ProviderType = 12
    RequestType = PKCS10
    HashAlgorithm = sha256
    [EnhancedKeyUsageExtension]
    OID=1.3.6.1.5.5.7.3.1
"@

    Write-Host "CSR being generated...."
    $INF | out-file -FilePath $INFPath -Force
    certreq -new $INFPath $CSRPath 
    Get-Content $CSRPath | Set-Clipboard
    Write-Host "CSR Request created check ctrl+v"
}
