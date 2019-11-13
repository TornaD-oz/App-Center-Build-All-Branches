# App Center: build all branches (PowerShell)
This is a small PowerShell script to send a build request to all branches of the App Center application.

## Decription
This script can be used to build all the available branches of the selected App Center application. It will perform a series of API queries, that will launch the building of the branches, wait for it's completion and print the build results to console in a formatted table.

## Inputs
Takes user, app, and token string values as input parameters.

###### Parameter "user":
The username used to access the App Center website

###### Parameter "app":
The name of the application, as visible on the App Center website

###### Parameter "token":
The App Center token with sufficient permissions to build and query the branches and builds

## Outputs
Returns a DataTable object with a report on the branches build status.

## Examples
*PS> .\AppCenterApi.ps1 yourUsername applicationName appCenterToken*

You can pass the desired parameters to the script, or enter them when the script is launched.

*PS> $report = .\AppCenterApi.ps1*

Pass the script output to a variable to receive the table with the report.

## Addional URL
URL to the App Center API:
https://openapi.appcenter.ms/

## Notes
The script was tested on PowerShell v5.0, .NET Framework or .NET Core are required to work with the DataTable.

Author: Oleg Pushkarev

Date:   November 13, 2019
