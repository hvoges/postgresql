function Get-PGDataType {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Type]$Type
    )

    if ( $PostgresType = $Script:ToPGSqlTypeMapping.($Type.Fullname) ) {
        return $PostgresType
    } else {
        return 'TEXT'
    }
}