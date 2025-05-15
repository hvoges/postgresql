function ConvertTo-PGPoshComparisonOperator {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Filter
    )

    ##ToDo: Add Match
    process {
        $Operators = @{
            '='  = '-eq'
            '<>' = '-ne'
            '!=' = '-ne'
            '>'  = '-gt'
            '>=' = '-ge'
            '<'  = '-lt'
            '<=' = '-le'
            'LIKE' = '-like'
            'NOT LIKE' = '-notlike'
            'IN' = '-in'
            'NOT IN' = '-notin'
        }

        If ( -not $Operators.$Filter ) {
            Write-Error "No matching operator found for $Filter"
            return
        }
        $Operators.$Filter
    }
}