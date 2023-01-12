function New-HpwJob {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]$sn,
        [string]$pn,
        [string]$cc
    )

    begin {
        $queryBody = New-Object -TypeName System.Collections.ArrayList
    }

    process {
        $CurrentQueryBody = $null

        #Build request Uri
        $PSBoundParameters.Keys.ForEach({
            [string]$Key = $_
            [string]$Value = $PSBoundParameters.$key
        
            $CurrentQueryBody = $CurrentQueryBody + @{
                "$Key" = "$Value"
            }
        })

        $null = $queryBody.Add($CurrentQueryBody)
    }

    end {
        $splat = @{
            "Uri" = "https://warranty.api.hp.com/productwarranty/v2/jobs"
            "Method" = "POST"
            "Headers" = @{
                "accept" = "application/json"
                "Content-Type" = "application/json"
                "Authorization" = "Bearer $(Get-HpwAccessToken)"
            }
            "Body" = ConvertTo-Json @($queryBody)
        }
        Invoke-RestMethod @splat
    }
}