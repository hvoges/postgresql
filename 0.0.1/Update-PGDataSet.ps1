Function Update-PGDataSet {
<#
.SYNOPSIS
    Updates datasets in a specified PostgreSQL table.

.DESCRIPTION
    The Update-PgsDataSet function modifies rows in a PostgreSQL table based on a provided filter and new value criteria. It supports updating datasets by constructing a dynamic SQL UPDATE statement using the specified table name, column filter, and new values for the targeted columns. The function incorporates checks to confirm the update action before proceeding, minimizing the risk of unintended data modifications.

.PARAMETER Datasource
    An optional Npgsql.NpgsqlDataSource object representing the data source. If not provided, it will be created using the Server, Port, Database, and Credential parameters.

.PARAMETER Server
    The hostname or IP address of the PostgreSQL server. Defaults to "localhost". This parameter is used if Datasource is not provided.

.PARAMETER Port
    The port on which the PostgreSQL server is listening. This parameter is required if Datasource is not provided.

.PARAMETER Database
    The name of the PostgreSQL database to connect to. This parameter is required if Datasource is not provided.

.PARAMETER Table
    The name of the table in which to update data. This parameter is mandatory.

.PARAMETER ColumnFilter
    A filter expression used to determine which rows should be updated. The expression should be a valid SQL WHERE clause condition (e.g., "user_id = 42"). This parameter is mandatory.

.PARAMETER NewValue
    The new value to be applied to the update operation, formulated as a part of the SQL SET clause (e.g., "age = 30, status = 'active'"). This parameter specifies the changes to apply to the filtered rows.

.PARAMETER Credential
    The PSCredential object containing the username and password for database authentication. This parameter is mandatory and used if Datasource is not provided.

.EXAMPLE
    $credential = Get-Credential
    Update-PgsDataSet -Server 'db.example.com' -Database 'mydb' -Credential $credential -Table 'users' -ColumnFilter "user_id = 42" -NewValue "age = 30, status = 'active'"

    This example updates the 'users' table, setting the age to 30 and status to 'active' for the user with user_id 42, after prompting for confirmation.

.NOTES
    This function leverages the Npgsql library for PostgreSQL database interactions and requires this library to be available in your PowerShell session. It's designed with a safety mechanism that prompts for confirmation before executing the update operation, adhering to best practices for preventing accidental data modifications.

    Carefully construct your ColumnFilter and NewValue parameters to ensure accurate and intended data updates. Incorrectly formulated expressions can lead to unintended data modifications or errors.
#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'medium')]    
    Param(
        $Datasource,

        [string]$Server = "localhost",
        
        [string]$Port, 
        
        [string]$Database,

        [String]$Table,

        [String]$ColumnFilter,

        [String]$NewValue,    
        
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential
    )

    $SqlOperators = "\s*=\s*|\s*<\s*|\s*>\s*|\s*<>\s*|\s*!=\s*|\s*like\s*" 
    $Column,$ComparionOperator,$ComparisonValue = $ColumnFilter -split "($SqlOperators)",0 | ForEach-Object { $_.Trim() }
    $ColumnFilter = '"{0}" {1} {2}' -f $Column,$ComparionOperator,$ComparisonValue
    $Column,$ComparionOperator,$ComparisonValue = $NewValue -split "($SqlOperators)",0 | ForEach-Object { $_.Trim() }
    $NewValue = '"{0}" {1} {2}' -f $Column,$ComparionOperator,$ComparisonValue
    $DBStrings = Format-PGString -TableName $Table 
    $Query = 'Update {0} set {1} where {2};' -f $DBStrings.Table, $NewValue, $ColumnFilter

    if ( $PSCmdlet.ShouldProcess( $Table, "Update rows where $ColumnFilter" )) {
        If (-not $Datasource ) {
            $ConnectionString = @{
                Host = $Server
                Port = $Port
                Database = $Database
                Username = $Credential.UserName
                Password = $Credential.GetNetworkCredential().Password
            }
            $Datasource = [Npgsql.NpgsqlDataSource]::Create($ConnectionString)
        }

        $Command = $Datasource.CreateCommand($Query)
        $Writer = $Command.ExecuteNonQueryAsync()
        $Writer.Wait()
        if ( $Writer.Status -eq 'Faulted' ) {
            return $Reader.Exception.Message   
        }  
        Write-Verbose "$($Writer.Result) rows updated in $Table"
        $Writer.Dispose()    
    }
}