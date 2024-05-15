function Get-PGDataType {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Type]$Type
    )

    $typeMap = @{
        'System.String'    = 'TEXT'
        'System.Int32'     = 'INTEGER'
        'System.Int64'     = 'BIGINT'
        'System.Double'    = 'DOUBLE PRECISION'
        'System.Decimal'   = 'NUMERIC'
        'System.DateTime'  = 'TIMESTAMP'
        'System.Boolean'   = 'BOOLEAN'
    }

    if ($typeMap.ContainsKey($Type.FullName)) {
        return $typeMap[$Type.FullName]
    } else {
        return 'TEXT'
    }
}