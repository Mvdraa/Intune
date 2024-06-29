
#First connect to the SharePoint site which you want to use as template and grant app permissions

connect-pnponline "https://v6kwc.sharepoint.com/" -interactive

#Exports the template as XML
Get-PnPSiteTemplate -Out "PnP-Provisioning-File.xml"

<#Targets the XML to modifiy  <pnp:StructuralNavigation RemoveExistingNodes="false"> to true
    This is done to prevent duplicate navigation link creation i.e. Home/Documents
#>

#Set variables
$path = "C:/Users/Mitchell/PnP-Provisioning-File.xml"
$xml = [xml](Get-Content -Path $path)
$RemoveExistingNodes = "true"
#Target the XML node which contains the value if the current navigation should be deleted
$node = $xml.Provisioning.Templates.ProvisioningTemplate.Navigation.CurrentNavigation.StructuralNavigation
$node.RemoveExistingNodes = $RemoveExistingNodes

#Connect to target library
connect-pnponline -url "https://v6kwc.sharepoint.com/sites/TemplateImportTest" -Interactive
Invoke-PnPSiteTemplate -Path $path

