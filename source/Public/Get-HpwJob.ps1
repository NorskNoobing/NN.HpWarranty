function Get-HpwJob {
    [CmdletBinding()]
    param (
        $id
    )

    process {
        $splat = @{
            "Uri" = "https://warranty.api.hp.com/productwarranty/v2/jobs/$id"
            "Method" = "GET"
            "Headers" = @{
                "accept" = "application/json"
                "Content-Type" = "application/json"
                "Authorization" = "Bearer $(Get-HpwAccessToken)"
            }
        }
        Invoke-RestMethod @splat
    }
}