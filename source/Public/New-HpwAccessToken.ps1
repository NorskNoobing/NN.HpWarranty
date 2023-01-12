function New-HpwAccessToken {
    [CmdletBinding()]
    param (
        [string]$credsPath = "$env:USERPROFILE\.creds\HP\hpWarrantyCreds.xml",
        [string]$accessTokenPath = "$env:USERPROFILE\.creds\HP\hpWarrantyAccessToken.xml",
        [switch]$RefreshCreds
    )
    
    process {
        #Create parent folders of the access token file
        $accessTokenDir = $accessTokenPath.Substring(0, $accessTokenPath.lastIndexOf('\'))
        if (!(Test-Path $accessTokenDir)) {
            $null = New-Item -ItemType Directory $accessTokenDir
        }

        #Create creds file
        if (!(Test-Path $credsPath) -or $RefreshCreds) {
            while (!$clientId) {
                $clientId = Read-Host "Enter HP client_id"
            }
            while (!$clientSecret) {
                $clientSecret = Read-Host "Enter HP client_secret"
            }
            
            @{
                "client_id" = $clientId
                "client_secret" = $clientSecret
            } | ConvertTo-Json | ConvertTo-SecureString -AsPlainText | Export-Clixml $credsPath
        }

        $creds = Import-Clixml $credsPath | ConvertFrom-SecureString -AsPlainText | ConvertFrom-Json
        $b64EncodedCred  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($creds.client_id):$($creds.client_secret)"))

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