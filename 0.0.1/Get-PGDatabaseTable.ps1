function Get-PGDatabaseTable {
<#
.SYNOPSIS
    Retrieves information about tables in a PostgreSQL database.

.DESCRIPTION
    The Get-PGDatabaseTable function queries the information_schema.tables view in a PostgreSQL database
    to retrieve information about base tables. By default, it excludes system tables from the pg_catalog 
    and information_schema schemas.

.PARAMETER Database
    The name of the database to query.

.PARAMETER Table
    The name of a specific table to query. If not specified, all tables will be returned.
    Note: This parameter is defined but not currently used in the function implementation.

.PARAMETER ShowViews
    If specified, includes views in the results.
    Note: This parameter is defined but not currently used in the function implementation.

.PARAMETER ComputerName
    The hostname or IP address of the PostgreSQL server. Defaults to "localhost".
    Used with the OnLink parameter set.

.PARAMETER Port
    The TCP port on which the PostgreSQL server is listening. Defaults to 5432.
    Used with the OnLink parameter set.

.PARAMETER Credential
    A PSCredential object containing the username and password to connect to the PostgreSQL server.
    Required when using the OnLink parameter set.

.PARAMETER Datasource
    An existing Npgsql.NpgsqlDataSource object representing a connection to a PostgreSQL server.
    Required when using the Connection parameter set.

.EXAMPLE
    Get-PGDatabaseTable -Database "mydb" -Datasource $myDataSource
    
    Returns all tables in the "mydb" database using an existing connection.

.EXAMPLE
    Get-PGDatabaseTable -Database "mydb" -ComputerName "pgserver" -Credential $cred
    
    Returns all tables in the "mydb" database on the remote PostgreSQL server "pgserver".

.NOTES
    This function requires the Npgsql .NET data provider to be installed.
    It can use either an existing connection or create a new one based on provided parameters.
#>    
    [CmdletBinding()]
    Param(        
        [Parameter(mandatory)]
        [string]$Database,

        [string]$Table,

        [Switch]$ShowViews,

        [Parameter(ParameterSetName = 'OnLink',
            ValueFromPipeline = $true,   
            ValueFromPipelineByPropertyName = $true)]
        [string]$ComputerName = "localhost",
        
        [Parameter(ParameterSetName = 'OnLink')]
        [string]$Port = 5432, 
        
        [Parameter(Mandatory = $true, ParameterSetName = 'OnLink')]
        [PSCredential]$Credential,

        [Parameter(ParameterSetName = 'Connection')]    
        $Datasource = $Script:Datasource
    )   
    Begin {
        If ( $PSCmdlet.ParameterSetName -eq 'OnLink') {
            $ConnectionString = @{
                Host     = $ComputerName
                Port     = $Port
                Username = $Credential.UserName
                Password = $Credential.GetNetworkCredential().Password
            }
            $Datasource = [Npgsql.NpgsqlDataSource]::Create($ConnectionString)
        }
        Elseif ( -not $Datasource ) {
            Throw 'Please connect to a PostgreSQL server first using Connect-PGServer or provide a Datasource object or connection parameters.'
        }
    }

    process {
        $Query = "SELECT * FROM information_schema.tables WHERE table_type = 'BASE TABLE' and table_schema not in ('pg_catalog','information_schema');" -f $Database

        $Command = $Datasource.CreateCommand($Query)
        $Reader = $Command.ExecuteReaderAsync() 
        if ( $Reader.Status -eq 'Faulted' ) {
            return $Reader.Exception.Message   
        }            
        $DataTable = New-Object System.Data.DataTable
        $DataTable.Load($Reader.Result)
        $DataTable
        $Reader.Dispose()     
    }
}