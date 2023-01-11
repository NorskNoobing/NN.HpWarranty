function Invoke-HpwRequest {
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
        if ($pn) {
            $CurrentQueryBody = $CurrentQueryBody + @{
                "pn" = $pn
            }
        }
        if ($cc) {
            $CurrentQueryBody = $CurrentQueryBody + @{
                "cc" = $cc
            }
        }

        $null = $queryBody.Add(
            $CurrentQueryBody + @{
                "sn" = $sn
            }
        )

        $CurrentQueryBody = $null
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
            "Body" = $queryBody | ConvertTo-Json
        }
        Invoke-RestMethod @splat
    }
}