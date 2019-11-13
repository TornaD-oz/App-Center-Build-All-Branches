<img src="https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRELuv4MS85LS_w7Ke_20r7zgVL24yFnHSYvz9QGHxe4irNednT" alt="App Center logo" width="125" height="125"> <img src="https://s3.amazonaws.com/pix.iemoji.com/images/emoji/apple/ios-11/256/heavy-plus-sign.png" alt="Plus sign" width="125" height="125"> <img src="https://img.evbuc.com/https%3A%2F%2Fcdn.evbuc.com%2Fimages%2F69182927%2F253710638063%2F1%2Foriginal.20190703-211514?w=1000&auto=compress&rect=0%2C35%2C940%2C470&s=5d3c8e33e2116a61504ef2c8aca5fbce" alt="PowerShell logo" width="250" height="125">

# App Center: build all branches (PowerShell)
This is a small PowerShell script to send a build request to all branches of the App Center application.

## Description
This script can be used to build all the available branches of the selected App Center application. It will perform a series of API queries that will launch the building of the branches, wait for its completion and print the build results to console in a formatted table.

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
*PS> .\AppCenterBuildAllBranches.ps1 yourUsername applicationName appCenterToken*

You can pass the desired parameters to the script or enter them when the script is launched.

*PS> $report = .\AppCenterBuildAllBranches.ps1*

Pass the script output to a variable to receive the table with a report.

An example output can be seen on the following image:
![Example output](https://user-images.githubusercontent.com/32512127/68801984-1c593900-066e-11ea-979e-1676d5c1e5c8.png)

## Additional URLs
URL to the App Center API:
https://openapi.appcenter.ms/

## Notes
The script was tested on PowerShell v5.0, .NET Framework or .NET Core are required to work with the DataTable.

Author: Oleg Pushkarev

Date:   November 13, 2019
