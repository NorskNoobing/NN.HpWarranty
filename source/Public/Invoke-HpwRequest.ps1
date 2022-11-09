function Invoke-HpwRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]$sn,
        [string]$pn,
        [string]$cc = "no"
    )

    begin {
        $queryBody = New-Object -TypeName System.Collections.ArrayList
    }

    process {
        $null = $queryBody.Add(
            @{
                "sn" = $sn
                "pn" = $pn
                "cc" = $cc
            }
        )
    }

    end {
        $splat = @{
            "Uri" = "warranty.api.hp.com/productwarranty/v2/jobs"
            "Method" = "POST"
            "Headers" = @{
                "accept" = "application/json"
                "ContentType" = "application/json"
                "Authorization" = "Bearer $(Get-HpwAccessToken)"
            }
            "Body" = $queryBody | ConvertTo-Json
        }
        Invoke-RestMethod @splat
    }
}