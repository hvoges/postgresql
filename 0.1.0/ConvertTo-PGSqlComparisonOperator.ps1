function ConvertTo-PGSqlComparisonOperator {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$SQLWhereClause
    )

    process {
        $operators = @{
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

        $newClause = $SQLWhereClause

        foreach ($op in $operators.Keys) {
            $newClause = $newClause -replace "\s+$op\s+", " $($operators[$op]) "
        }

        Write-Output $newClause
    }
}