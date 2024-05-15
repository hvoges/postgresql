. $PSScriptRoot\Add-PGDataSet.ps1
. $PSScriptRoot\Convertto-PGTable.ps1
. $PSScriptRoot\Invoke-PGSql.ps1
. $PSScriptRoot\Update-PGDataSet.ps1
. $PSScriptRoot\Remove-PGDataset.ps1
. $PSScriptRoot\New-PGTable.ps1
. $PSScriptRoot\Get-PGTable.ps1
. $PSScriptRoot\Connect-PGServer.ps1
. $PSScriptRoot\Format-PGString.ps1
. $PSScriptRoot\Get-PGDataType.ps1
# . $PSScriptRoot\Convertto-PgsDataType.ps1
. $PSScriptRoot\New-PGDatabase.ps1
. $PSScriptRoot\Remove-PGDatabase.ps1
. $PSScriptRoot\Get-PGDatabase.ps1
. $PSScriptRoot\Use-PGDatabase.ps1
. $PSScriptRoot\Get-PGDatabaseTable.ps1
. $PSScriptRoot\Get-PGColumnDefinition.ps1

$Script:PgsDataTypeMapping = @{
    'System.Boolean'    = 'boolean'
    'System.Byte'       = 'smallint'
    'System.SByte'      = 'smallint'
    'System.Char'       = 'char(1)'
    'System.Int16'      = 'smallint'
    'System.Int32'      = 'integer'
    'System.Int64'      = 'bigint'
    'System.UInt16'     = 'integer'
    'System.UInt32'     = 'bigint'
    'System.UInt64'     = 'numeric'
    'System.Decimal'    = 'numeric'
    'System.Single'      = 'real'
    'System.Double'     = 'double precision'
    'System.DateTime'   = 'timestamp without time zone'
    'System.String'     = 'text'
    'System.Guid'       = 'uuid'
}

Export-ModuleMember -Function *-PG* -Variable $Script:PgsDataTypeMapping -Alias *
