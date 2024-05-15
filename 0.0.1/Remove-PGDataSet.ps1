Function Remove-PGDataSet {
<#
.SYNOPSIS
    Removes datasets from a specified PostgreSQL table.

.DESCRIPTION
    The Remove-PgsDataSet function deletes rows from a PostgreSQL table that match a specified condition. This function supports conditional deletion based on a column filter expression, enabling targeted removal of records. It incorporates the capability to prompt the user before executing the deletion, ensuring accidental data loss prevention.

.PARAMETER Datasource
    An optional Npgsql.NpgsqlDataSource object representing the data source. If not provided, it will be created using the Server, Port, Database, and Credential parameters.

.PARAMETER Server
    The hostname or IP address of the PostgreSQL server. Defaults to "localhost". This parameter is used if Datasource is not provided.

.PARAMETER Port
    The port on which the PostgreSQL server is listening. This parameter is required if Datasource is not provided.

.PARAMETER Database
    The name of the PostgreSQL database to connect to. This parameter is required if Datasource is not provided.

.PARAMETER Table
    The name of the table from which to remove data. This parameter is mandatory.

.PARAMETER ColumnFilter
    A filter expression used to determine which rows should be removed. The expression should be a valid SQL WHERE clause condition (e.g., "age > 21"). This parameter is mandatory.

.PARAMETER Credential
    The PSCredential object containing the username and password for database authentication. This parameter is mandatory and used if Datasource is not provided.

.EXAMPLE
    $credential = Get-Credential
    Remove-PgsDataSet -Server 'db.example.com' -Database 'mydb' -Credential $credential -Table 'users' -ColumnFilter "age < 18"

    This example removes rows from the 'users' table where the age is less than 18, after prompting for confirmation.

.EXAMPLE
    $dataSource = [Npgsql.NpgsqlDataSource]::Create($connectionString)
    Remove-PgsDataSet -Datasource $dataSource -Table 'logs' -ColumnFilter "log_date < '2021-01-01'"

    This example removes rows from the 'logs' table where the log_date is before January 1st, 2021, using an existing NpgsqlDataSource.

.NOTES
    This function utilizes the Npgsql library for database operations and requires it to be available in your PowerShell session. The function is designed to ensure that accidental data deletion is minimized by prompting for confirmation before executing the delete operation, adhering to PowerShell's best practices for data safety.

    Ensure your column filter expressions are correctly formatted and tested to prevent unintended data loss.
#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param(
        $Datasource,
    
        [string]$Server = "localhost",
            
        [string]$Port, 
            
        [string]$Database,
    
        [String]$Table,
    
        [String]$ColumnFilter,

        [Parameter(Mandatory = $true)]
        [PSCredential]$Credential
    )

    Process {    
        $DBStrings = Format-PGString -TableName $Table 
        $Query = 'delete FROM {0} where {1};' -f $DBStrings.Table, $ColumnFilter

        if ( $PSCmdlet.ShouldProcess( $Table, "Remove rows where $ColumnFilter" ) ) {
            If (-not $Datasource ) {
                $ConnectionString = @{
                    Host     = $Server
                    Port     = $Port
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
                return $Writer.Exception.Message        
            }
            Write-Verbose "$($Writer.Result) rows removed from $Table"
            $Writer.Dispose()    
        }
    }
}