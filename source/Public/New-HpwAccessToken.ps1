function New-HpwAccessToken {
    [CmdletBinding()]
    param (
        $clientIdPath = "$env:USERPROFILE\.creds\HP\hpWarrantyClientId.xml",
        $clientSecretPath = "$env:USERPROFILE\.creds\HP\hpWarrantyClientSecret.xml",
        $accessTokenPath = "$env:USERPROFILE\.creds\HP\hpWarrantyAccessToken.xml"
    )
    
    process {
        #Create parent folders of the access token file
        $accessTokenDir = $accessTokenPath.Substring(0, $accessTokenPath.lastIndexOf('\'))
        if (!(Test-Path $accessTokenDir)) {
            $null = New-Item -ItemType Directory $accessTokenDir
        }

        #Create clientId file
        if (!(Test-Path $clientIdPath)) {
            Read-Host "Enter HP client_id" -AsSecureString | Export-Clixml $clientIdPath
        }

        #Create clientSecret file
        if (!(Test-Path $clientSecretPath)) {
            Read-Host "Enter HP client_secret" -AsSecureString | Export-Clixml $clientSecretPath
        }

        $clientId = Import-Clixml $clientIdPath | ConvertFrom-SecureString -AsPlainText
        $clientSecret = Import-Clixml $clientSecretPath | ConvertFrom-SecureString -AsPlainText
        $b64EncodedCred  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($clientId):$($clientSecret)"))

        $splat = @{
            "Method" = "POST"
            "Uri" = "https://warranty.api.hp.com/oauth/v1/token"
            "Headers" = @{
                "accept" = "application/json"
                "authorization" = "Basic $b64EncodedCred"
                "content-type" = "application/x-www-form-urlencoded"
            }
            "Body" = @{
                "grant_type" = "client_credentials"
            }
        }
        $result = Invoke-RestMethod @splat

        #Adds access token and expiry date to access token file
        [PSCustomObject]@{
            access_token = $result.access_token
            expiry_date = (Get-Date).AddSeconds($result.expires_in)
        } | ConvertTo-Json | ConvertTo-SecureString -AsPlainText | Export-Clixml -Path $accessTokenPath
    }
}