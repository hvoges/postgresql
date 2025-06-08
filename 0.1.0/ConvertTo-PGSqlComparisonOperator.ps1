function ConvertTo-PGSqlComparisonOperator {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Operator
    )

    ##ToDo: Add Match
    process {
        $Operators = @{
            '-eq' = '='
            '-ceq' = '='
            '-ne' = '!='
            '-cne' = '!='
            '-gt' = '>' 
            '-cgt' = '>'
            '-ge' = '>='
            '-cge' = '>='
            '-lt' = '<' 
            '-clt' = '<'
            '-le' = '<='
            '-cle' = '<='
            '-like' = 'LIKE'
            '-clike' = 'LIKE'
            '-notlike' = 'NOT LIKE'
            '-cnotlike' = 'NOT LIKE'
            '-in' = 'IN'
            '-cin' = 'IN'
            '-notin' = 'NOT IN' 
            '-cnotin' = 'NOT IN'
            '-match' = 'SIMILAR TO'
            '-cmatch' = 'SIMILAR TO'
            '-notmatch' = 'NOT SIMILAR TO'
            '-cnotmatch' = 'NOT SIMILAR TO'
            '-contains' = 'IN'
            '-ccontains' = 'IN'
            '-notcontains' = 'NOT IN'
            '-cnotcontains' = 'NOT IN'
        }

        If ( -not $Operators.$Operator ) {
            Write-Error "No matching operator found for $Operator"
            return
        }
        $Operators.$Operator
    }
}