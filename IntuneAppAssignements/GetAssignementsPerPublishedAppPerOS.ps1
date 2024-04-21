#Checks for required Module
$ReqModule = Get-InstalledModule Microsoft.Graph.Beta.DeviceManagement
if($ReqModule) {
    write-host "Microsoft.Graph.Beta.DeviceManagement already installed." -ForegroundColor Green
} else {
    Install-Module Microsoft.Graph.Beta.DeviceManagement
}

Connect-Graph -scope "DeviceManagementApps.Read.All", "Group.Read.All"


#Gets all assigned apps
#GRAPH BETA REQUEST, IF INVOKE NOT WORKING CHECK IF MOVED TO GRAPH V1.0 

#Creates
$WindowsAppsGraphRequest = (invoke-graphrequest -Method GET -Uri 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?$filter=(isof(%27microsoft.graph.win32CatalogApp%27)%20or%20isof(%27microsoft.graph.windowsStoreApp%27)%20or%20isof(%27microsoft.graph.microsoftStoreForBusinessApp%27)%20or%20isof(%27microsoft.graph.officeSuiteApp%27)%20or%20(isof(%27microsoft.graph.win32LobApp%27)%20and%20not(isof(%27microsoft.graph.win32CatalogApp%27)))%20or%20isof(%27microsoft.graph.windowsMicrosoftEdgeApp%27)%20or%20isof(%27microsoft.graph.windowsPhone81AppX%27)%20or%20isof(%27microsoft.graph.windowsPhone81StoreApp%27)%20or%20isof(%27microsoft.graph.windowsPhoneXAP%27)%20or%20isof(%27microsoft.graph.windowsAppX%27)%20or%20isof(%27microsoft.graph.windowsMobileMSI%27)%20or%20isof(%27microsoft.graph.windowsUniversalAppX%27)%20or%20isof(%27microsoft.graph.webApp%27)%20or%20isof(%27microsoft.graph.windowsWebApp%27)%20or%20isof(%27microsoft.graph.winGetApp%27))%20and%20(microsoft.graph.managedApp/appAvailability%20eq%20null%20or%20microsoft.graph.managedApp/appAvailability%20eq%20%27lineOfBusiness%27%20or%20isAssigned%20eq%20true)').value

$iOSAppsGraphRequest = (invoke-graphrequest -method get -uri 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?$filter=((isof(%27microsoft.graph.managedIOSStoreApp%27)%20and%20microsoft.graph.managedApp/appAvailability%20eq%20microsoft.graph.managedAppAvailability%27lineOfBusiness%27)%20or%20isof(%27microsoft.graph.iosLobApp%27)%20or%20isof(%27microsoft.graph.iosStoreApp%27)%20or%20isof(%27microsoft.graph.iosVppApp%27)%20or%20isof(%27microsoft.graph.managedIOSLobApp%27)%20or%20(isof(%27microsoft.graph.managedIOSStoreApp%27)%20and%20microsoft.graph.managedApp/appAvailability%20eq%20microsoft.graph.managedAppAvailability%27global%27)%20or%20isof(%27microsoft.graph.webApp%27)%20or%20isof(%27microsoft.graph.iOSiPadOSWebClip%27))%20and%20(microsoft.graph.managedApp/appAvailability%20eq%20null%20or%20microsoft.graph.managedApp/appAvailability%20eq%20%27lineOfBusiness%27%20or%20isAssigned%20eq%20true)').value

$MacOSAppsGraphRequest = (invoke-graphrequest -method get -uri 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?$filter=(isof(%27microsoft.graph.macOSDmgApp%27)%20or%20isof(%27microsoft.graph.macOSPkgApp%27)%20or%20isof(%27microsoft.graph.macOSLobApp%27)%20or%20isof(%27microsoft.graph.macOSMicrosoftEdgeApp%27)%20or%20isof(%27microsoft.graph.macOSMicrosoftDefenderApp%27)%20or%20isof(%27microsoft.graph.macOSOfficeSuiteApp%27)%20or%20isof(%27microsoft.graph.macOsVppApp%27)%20or%20isof(%27microsoft.graph.webApp%27)%20or%20isof(%27microsoft.graph.macOSWebClip%27))%20and%20(microsoft.graph.managedApp/appAvailability%20eq%20null%20or%20microsoft.graph.managedApp/appAvailability%20eq%20%27lineOfBusiness%27%20or%20isAssigned%20eq%20true)').value

$AndroidAppsGraphRequest = (invoke-graphrequest -method get -uri 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?$filter=((isof(%27microsoft.graph.androidManagedStoreApp%27)%20and%20microsoft.graph.androidManagedStoreApp/isSystemApp%20eq%20true)%20or%20isof(%27microsoft.graph.androidLobApp%27)%20or%20isof(%27microsoft.graph.androidStoreApp%27)%20or%20(isof(%27microsoft.graph.managedAndroidStoreApp%27)%20and%20microsoft.graph.managedApp/appAvailability%20eq%20microsoft.graph.managedAppAvailability%27lineOfBusiness%27)%20or%20isof(%27microsoft.graph.managedAndroidLobApp%27)%20or%20(isof(%27microsoft.graph.managedAndroidStoreApp%27)%20and%20microsoft.graph.managedApp/appAvailability%20eq%20microsoft.graph.managedAppAvailability%27global%27)%20or%20(isof(%27microsoft.graph.androidManagedStoreApp%27)%20and%20microsoft.graph.androidManagedStoreApp/isSystemApp%20eq%20false)%20or%20isof(%27microsoft.graph.webApp%27))%20and%20(microsoft.graph.managedApp/appAvailability%20eq%20null%20or%20microsoft.graph.managedApp/appAvailability%20eq%20%27lineOfBusiness%27%20or%20isAssigned%20eq%20true)').value


function Get-AssignedIntuneApps {
    param (
        $AppsPerOS
    )
    #Start looping through all apps
    $AllAssignments = foreach ($App in $AppsPerOS) {
        #Gets assignments per app
        $graphUri = 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/' + [string]$App.id + '/assignments?$select=intent,target'
        $assignedToApp = (Invoke-GraphRequest -Method GET -Uri $graphUri).value
       
        #Starts looping through each assignment for each app
        foreach ($assignment in $assignedToApp) {
            #Resets filtername each loop
            $FilterName = ""
            #Reads @odata.type of app to check what is assigned for the app
            switch ($assignment.target."@odata.type") {
                "#microsoft.graph.groupAssignmentTarget" { 
                    #Gets the displayname of the group
                    $GroupAssignedToApp = (Get-MgGroup -GroupId $assignment.target.groupId).DisplayName
                    $result = $GroupAssignedToApp 
                    $FilterType = $assignment.target.deviceAndAppManagementAssignmentFilterType
                    #Checks for device filter, if exists get the displayname of this device filter
                    if ($FilterType -ne "none") {
                        $FilterName = (Get-MgBetaDeviceManagementAssignmentFilter -DeviceAndAppManagementAssignmentFilterId $assignment.target.deviceAndAppManagementAssignmentFilterId).DisplayName
                    }
                }
                "#microsoft.graph.allLicensedUsersAssignmentTarget" {
                    $result = "All Users"
                    $FilterType = $assignment.target.deviceAndAppManagementAssignmentFilterType
                    if ($FilterType -ne "none") {
                        $FilterName = (Get-MgBetaDeviceManagementAssignmentFilter -DeviceAndAppManagementAssignmentFilterId $assignment.target.deviceAndAppManagementAssignmentFilterId).DisplayName
                    }
                }
                "#microsoft.graph.allDevicesAssignmentTarget" {
                    $result = "All Devices"
                    $FilterType = $assignment.target.deviceAndAppManagementAssignmentFilterType
                    if ($FilterType -ne "none") {
                        $FilterName = (Get-MgBetaDeviceManagementAssignmentFilter -DeviceAndAppManagementAssignmentFilterId $assignment.target.deviceAndAppManagementAssignmentFilterId).DisplayName
                    }
                }
                Default {$result = "Unknown app assignment"}
            }
            #Stores everything in object in preparation of export
            [PSCustomObject]@{
                displayName = $App.displayName
                id = $App.id
                intent = $assignment.intent
                AssignedTo = $result
                FilterType = $FilterType
                FilterName = $FilterName
            } 
        } 
    }
    return $AllAssignments
}
 
#Calls function and exports all Windows Apps
$AllAssignedWindowsApps = Get-AssignedIntuneApps($WindowsAppsGraphRequest)
$AllAssignedWindowsApps | Export-Csv .\WindowsAppAssignments.csv -NoTypeInformation

#Calls function and exports all iOS/iPadOS Apps
$AllAssignediOSApps = Get-AssignedIntuneApps($iOSAppsGraphRequest)
$AllAssignediOSApps | Export-Csv .\iOSAppAssignments.csv -NoTypeInformation

#Calls function and exports all MacOS Apps
$AllAssignedMacOS = Get-AssignedIntuneApps($MacOSAppsGraphRequest)
$AllAssignedMacOS | Export-Csv .\MacOSAppAssignments.csv -NoTypeInformation

#Calls function and exports all Android Apps
$AllAssignedAndroidApps = Get-AssignedIntuneApps($AndroidAppsGraphRequest)
$AllAssignedAndroidApps | Export-Csv .\AndroidAppAssignments.csv -NoTypeInformation

Disconnect-Graph