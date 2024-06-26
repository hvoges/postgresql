. $PSScriptRoot\Add-PGDataSet.ps1
. $PSScriptRoot\Connect-PGServer.ps1
. $PSScriptRoot\Convertto-PGTable.ps1
. $PSScriptRoot\Format-PGString.ps1
. $PSScriptRoot\Get-PGColumnDefinition.ps1
. $PSScriptRoot\Get-PGDatabase.ps1
. $PSScriptRoot\Get-PGDatabaseTable.ps1
. $PSScriptRoot\Get-PGDataType.ps1
. $PSScriptRoot\Get-PGTable.ps1
. $PSScriptRoot\Invoke-PGSql.ps1
. $PSScriptRoot\New-PGDatabase.ps1
. $PSScriptRoot\New-PGTable.ps1
. $PSScriptRoot\Remove-PGDatabase.ps1
. $PSScriptRoot\Remove-PGDataset.ps1
. $PSScriptRoot\Update-PGDataSet.ps1
. $PSScriptRoot\Use-PGDatabase.ps1
. $PSScriptRoot\DataTypes.ps1
# . $PSScriptRoot\Convertto-PgsDataType.ps1

Export-ModuleMember -Function *-PG* -Variable @($Script:ToPgssqlTypeMapping,$Script:ToNpgsqlTypeMapping,$Script:ToNetTypeMapping)  -Alias *
