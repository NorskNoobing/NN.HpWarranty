function New-HpwJob {
    <#
    .EXAMPLE
        @("5CD2022DDS","5CD2022D9Q") | New-HpwJob

        Get an array of serialnumbers without productnumber.
        Note that this could result in a not found message when retrieving the results.
    .EXAMPLE
        @("5CD2022DDS","5CD2022D9Q") | New-HpwJob -pn "2U740AV"

        Get an array of serialnumbers using the same productnumber.
    .EXAMPLE
        @(
        @{
            "sn" = "5CD2022DDS"
            "pn" = "2U740AV"
        },
        @{
            "sn" = "5CD2022D9Q"
            "pn" = "2U740AV"
        }
        ) | New-HpwJob -HashtableInput

        You can pipe an array of hashtables into the function with the use of the "-Hashtable" switch
        in order to set multiple inputs independent of eachother e.g. separate PN for each SN.
    #>
    [CmdletBinding(DefaultParameterSetName="Normal inputs")]
    param (
        [Parameter(ParameterSetName="Normal inputs",Mandatory,ValueFromPipeline,Position=0)]$sn,
        [Parameter(ParameterSetName="Normal inputs")][string]$pn,
        [Parameter(ParameterSetName="Normal inputs")][string]$cc,
        [Parameter(ParameterSetName="Hashtable input",Mandatory,ValueFromPipeline,Position=0)][hashtable]$InputObject,
        [Parameter(ParameterSetName="Hashtable input")][switch]$HashtableInput
    )

    begin {
        $queryBody = New-Object -TypeName System.Collections.ArrayList
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            "Normal inputs" {
                $ParamHashtable = $PSBoundParameters
            }
            "Hashtable input" {
                $ParamHashtable = $InputObject
            }
        }

        $CurrentQueryBody = $null

        #Build request Uri
        $ParamHashtable.Keys.ForEach({
            [string]$Key = $_
            [string]$Value = $ParamHashtable.$key
        
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