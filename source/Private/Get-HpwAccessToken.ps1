function Get-HpwAccessToken {
    [CmdletBinding()]
    param (
        $accessTokenPath = "$env:USERPROFILE\.creds\HP\hpWarrantyAccessToken.xml"
    )
    
    process {
        #Conditions to refresh access token
        if (Test-Path $accessTokenPath) {
            [datetime]$accessTokenExpiryDate = (Import-Clixml $accessTokenPath | ConvertFrom-SecureString -AsPlainText | ConvertFrom-Json).expiry_date

            #Refresh access token if there's less than 5 minutes till token expiry
            if (($accessTokenExpiryDate.AddMinutes(-5)) -lt (Get-Date)) {
                New-HpwAccessToken
            }
        } else {
            New-HpwAccessToken
        }

        #Import the existing access token
        (Import-Clixml $accessTokenPath | ConvertFrom-SecureString -AsPlainText | ConvertFrom-Json).access_token
    }
}