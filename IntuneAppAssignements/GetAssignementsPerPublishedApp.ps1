$ReqModule = Get-InstalledModule Microsoft.Graph.Beta.DeviceManagement
if($ReqModule) {
    write-host "Microsoft.Graph.Beta.DeviceManagement already installed." -ForegroundColor Green
} else {
    Install-Module Microsoft.Graph.Beta.DeviceManagement
}

Connect-Graph -scope "DeviceManagementApps.Read.All", "Group.Read.All"


#Gets all assigned apps
#GRAPH BETA REQUEST, IF INVOKE NOT WORKING CHECK IF MOVED TO GRAPH V1.0 
$AssignedApps = (invoke-graphrequest -method get -uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps").value | Where-Object {$_.isAssigned -eq $true}


$AllAssignments = foreach ($App in $AssignedApps) {
    #Gets assignments per app
    $graphUri = 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/' + [string]$App.id + '/assignments?$select=intent,target'
    $assignedToApp = (Invoke-GraphRequest -Method GET -Uri $graphUri).value
   
    foreach ($assignment in $assignedToApp) {
        $FilterName = ""
        switch ($assignment.target."@odata.type") {
            "#microsoft.graph.groupAssignmentTarget" { 
                $GroupAssignedToApp = (Get-MgGroup -GroupId $assignment.target.groupId).DisplayName
                $result = $GroupAssignedToApp 
                $FilterType = $assignment.target.deviceAndAppManagementAssignmentFilterType
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
$AllAssignments | Export-Csv .\AppAssignments.csv -NoTypeInformation

