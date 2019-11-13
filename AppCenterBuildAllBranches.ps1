<#
.SYNOPSIS
    Build all branches of the App Center application

.DESCRIPTION
    This script can be used to build all the available branches of the selected
    App Center application. It will perform a series of API queries
    that will launch the building of the branches, wait for its completion
    and print the build results to the console in a formatted table.

.INPUTS
    Takes user, app, and token string values as input parameters.

.OUTPUTS
    Returns a DataTable object with a report on the branches build status.

.PARAMETER user
    The username used to access the App Center website

.PARAMETER app
    The name of the application, as visible on the App Center website

.PARAMETER token
    The App Center token with sufficient permissions to build and query the branches and builds

.EXAMPLE
    PS> AppCenterBuildAllBranches.ps1 yourUsername applicationName appCenterToken
    
    You can pass the desired parameters to the script or enter them when the script is launched.

.EXAMPLE
	PS> $report = .\AppCenterBuildAllBranches.ps1

	Pass the script output to a variable to receive the table with a report.

.LINK
	https://openapi.appcenter.ms/

.NOTES
    Author: Oleg Pushkarev
    Date:   November 13, 2019   
#>

[CmdletBinding()]
Param
(
	[String]$user = (Read-Host -prompt "Enter the username"),
	[String]$app = (Read-Host -prompt "Enter the application name"),
	[String]$token = (Read-Host -prompt "Enter the App Center token")
)

# Check if the user entered all the parameters and terminate the script if any parameter is missing
if (!$user -or !$app -or !$token)
{
	Write-Host "`r`nInvalid input parameters, terminating execution"
	exit
}

try
{
	# Get all available branches from the App Center
	$allBranchesResponse = Invoke-WebRequest -Uri "https://api.appcenter.ms/v0.1/apps/$($user)/$($app)/branches" -Method "GET" -Headers @{ "Accept" = "application/json"; "X-API-Token" = "$($token)"; "Content-Type" = "application/json" } | ConvertFrom-Json
}
catch
{
	Write-Host "`r`nFailed to perform the API request, terminating execution. Check your input parameters"
	exit
}

# Send the branch building request of every available branch to the App Center
foreach ($b in $allBranchesResponse)
{
	try
	{
		Invoke-WebRequest -Uri "https://api.appcenter.ms/v0.1/apps/$($user)/$($app)/branches/$($b.branch.name)/builds" -Method "POST" -Headers @{ "Accept" = "application/json"; "X-API-Token" = "$($token)"; "Content-Type" = "application/json" } | Out-Null
		Write-Host "Started building branch $($b.branch.name)"
	}
	catch
	{
		Write-Host "Failed to start building branch $($b.branch.name)"
	}
}

# Initialize a variable that will be used to end the infinite while loop, which is checking if the branches have finished building
$buildsFinished = $false

# Initialize a counter for the total number of finished builds
$parseCompletedCounter = 0

Write-Host "`r`nChecking every 60 seconds for all the branches to finish building the application`r`n"

While (!$buildsFinished)
{
	# Wait for 60 seconds before performing the check
	Start-Sleep 60
	
	# Perform the build progress check for every available branch
	for ($counter = 0; $counter -lt $allBranchesResponse.Length; $counter++)
	{
		# If the current branch has not been built, query the App Center for its build status
		if ($allBranchesResponse[$counter].parseCompleted -ne "true")
		{
			# Request the current branch build status from the App Center
			$buildResultJson = Invoke-WebRequest -Uri "https://api.appcenter.ms/v0.1/apps/$($user)/$($app)/branches/$($allBranchesResponse[$counter].branch.name)/builds" -Method "GET" -Headers @{ "Accept" = "application/json"; "X-API-Token" = "$($token)"; "Content-Type" = "application/json" }
			
			# If no build has been configured for the current branch, exit the current check iteration and flag the branch build as "Completed"
			# The first element of the array $buildResultJson would be checked since the latest build is always received first from the query
			if ($buildResultJson[0].Content -ne "[]")
			{
				$buildResult = $buildResultJson | ConvertFrom-Json
				
				if ($buildResult[0].status -eq "completed")
				{
					# Add the "Success" or "Failed" build status to the branch object
					if ($buildResult[0].result -eq "succeeded")
					{
						$allBranchesResponse[$counter] | Add-Member -MemberType NoteProperty -Name "result" -Value "Success"
					}
					else
					{
						$allBranchesResponse[$counter] | Add-Member -MemberType NoteProperty -Name "result" -Value "Failed"
					}
					
					# Count the total duration of the build and add it to the branch object
					$totalBuildTime = New-TimeSpan –Start $buildResult[0].startTime –End $buildResult[0].finishTime
					$allBranchesResponse[$counter] | Add-Member -MemberType NoteProperty -Name "duration" -Value "$($totalBuildTime.minutes):$($totalBuildTime.Seconds)"
					
					# Request a URL for the build logs from the App Center and add it to the branch object
					$logsURL = Invoke-WebRequest -Uri "https://api.appcenter.ms/v0.1/apps/$($user)/$($app)/builds/$($buildResult[0].buildnumber)/downloads/logs" -Method "GET" -Headers @{ "Accept" = "application/json"; "X-API-Token" = "$($token)"; "Content-Type" = "application/json" } | ConvertFrom-Json
					$allBranchesResponse[$counter] | Add-Member -MemberType NoteProperty -Name "link" -Value $logsURL.uri
					
					# Add the status of parsing completion to the branch object
					$allBranchesResponse[$counter] | Add-Member -MemberType NoteProperty -Name "parseCompleted" -Value "true"
					
					# Increment the counter of completed builds
					$parseCompletedCounter++
				}
			}
			else
			{
				# Since no build is configured for the selected branch, add "N/A" to every applicable column
				# and set the parse completion to "true"
				$allBranchesResponse[$counter] | Add-Member -MemberType NoteProperty -Name "result" -Value "N/A"
				$allBranchesResponse[$counter] | Add-Member -MemberType NoteProperty -Name "duration" -Value "N/A"
				$allBranchesResponse[$counter] | Add-Member -MemberType NoteProperty -Name "link" -Value "N/A"
				$allBranchesResponse[$counter] | Add-Member -MemberType NoteProperty -Name "parseCompleted" -Value "true"
				
				# Increment the counter of completed builds
				$parseCompletedCounter++
			}
		}
	}
	
	# Print the current number of finished builds to console
	if ($parseCompletedCounter -eq 0)
	{
		Write-Host "No builds finished yet"
	}
	elseif ($parseCompletedCounter -lt $allBranchesResponse.Length)
	{
		Write-Host "Finished $($parseCompletedCounter)/$($allBranchesResponse.Length) builds"
	}
	else
	{
		Write-Host "Finished $($parseCompletedCounter)/$($allBranchesResponse.Length) builds"
		
		# Since the number of finished builds is equal to the number of branches, set the $buildsFinished
		# to "true" and exit the infinite while loop
		$buildsFinished = $true
	}
}

Write-Host "`r`nAll builds are finished"

# Create a table for the report
$table = New-Object system.Data.DataTable "Report"

# Define the table's columns
$col1 = New-Object system.Data.DataColumn BranchName, ([string])
$col2 = New-Object system.Data.DataColumn BuildStatus, ([string])
$col3 = New-Object system.Data.DataColumn Duration, ([string])
$col4 = New-Object system.Data.DataColumn LogsLink, ([string])

# Add the defined columns to the table
$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.columns.add($col4)

foreach ($b in $allBranchesResponse)
{
	# Create a new row
	$row = $table.NewRow()
	
	# Enter the data in the created row
	$row.BranchName = $b.branch.name
	$row.BuildStatus = $b.result
	$row.Duration = $b.duration
	$row.LogsLink = $b.link
	
	# Add the row to the table
	$table.Rows.Add($row)
}

# Set more user-friendly headers for the columns
$table.Columns[0].ColumnName = "Branch name"
$table.Columns[1].ColumnName = "Build status"
$table.Columns[3].ColumnName = "Link to build logs"

# Return the finished table or print it to console
return $table