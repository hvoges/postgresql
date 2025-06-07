function ConvertTo-PGSqlWhereClause {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true)]
        $Filter
    )

    process {
        if (-not $Filter) {
            return ''
        } 
        elseif ([String]$Filter -match '(?<property>[\w]+)\s*(?<operator>-c?(?:eq|ne|gt|lt|ge|le|like|notlike|match|notmatch))\s*(?<Value>"([^"]*)"|''([^'']*)''|([^\s''"]+))' ) {
            If ( $matches.operator -in '-like', '-clike', '-notlike', '-cnotlike' ) {
                $matches.Value = "'{0}'" -f $matches.Value.trim('",''').replace('*','%')
                $matches.Value
            }
            if ( $matches.value.StartsWith('"')) {
                $matches.Value = "'{0}'" -f $matches.Value.trim('"')
            }
            'where {0} {1} {2}' -f $matches.property, (ConvertTo-PgSqlComparisonOperator -Operator $matches.operator), $matches.Value
        }
        Else {
            throw "Invalid filter format. Expected format: <property> <-operator> <value>"
        }
    }

}