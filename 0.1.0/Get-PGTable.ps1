Function Get-PGTable {
    <#
.SYNOPSIS
    Retrieves rows from a specified PostgreSQL table.

.DESCRIPTION
    The Get-PgsTable function fetches data from a specified table in a PostgreSQL database. It allows for the selection of specific columns or all columns by default. The function supports direct database connections through a Npgsql datasource or by specifying connection parameters such as server, port, database, and credentials.

.PARAMETER Datasource
    A Npgsql.NpgsqlDataSource object representing the data source. This parameter is mandatory if the 'Connection' parameter set is used.

.PARAMETER Server
    The hostname or IP address of the PostgreSQL server. Defaults to "localhost". This parameter is used along with Port, Database, and Credential parameters when not using an existing Datasource object.

.PARAMETER Port
    The port on which the PostgreSQL server is listening. This parameter is used along with Server, Database, and Credential parameters when not using an existing Datasource object.

.PARAMETER Database
    The name of the PostgreSQL database from which to retrieve data. This parameter is mandatory when using the 'OnLink' parameter set.

.PARAMETER Table
    The name of the table from which to retrieve data. This parameter is mandatory.

.PARAMETER Columns
    An array of column names to retrieve. Defaults to '*' (all columns). If specified, only the named columns will be retrieved.

.PARAMETER Credential
    The PSCredential object containing the username and password for database authentication. This parameter is mandatory when using the 'OnLink' parameter set and no Datasource is provided.

.EXAMPLE
    $credential = Get-Credential
    $dataTable = Get-PgsTable -Server 'db.example.com' -Database 'mydb' -Credential $credential -Table 'users'

    This example retrieves all columns from the 'users' table in the 'mydb' database, after prompting for database credentials.

.EXAMPLE
    $credential = Get-Credential
    $columns = 'user_id', 'username'
    $dataTable = Get-PgsTable -Server 'db.example.com' -Port 5432 -Database 'mydb' -Credential $credential -Table 'users' -Columns $columns

    This example retrieves only the 'user_id' and 'username' columns from the 'users' table in the 'mydb' database, after prompting for database credentials.

.NOTES
    This function utilizes the Npgsql library to interact with PostgreSQL databases and requires the library to be loaded in your PowerShell session. It provides flexibility in database connections, allowing for the use of existing Npgsql data sources or the creation of new connections based on provided parameters.

    The function is designed to efficiently retrieve and return data in the form of a DataTable, which can then be used for further processing or display within PowerShell scripts.
#>

    Param(        
        [string]$Database = $Script:Database,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]    
        [String]$Table,

        [String[]]$Columns = '*',

        [Parameter(ParameterSetName = 'OnLink')]
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
                Database = $Database
                Username = $Credential.UserName
                Password = $Credential.GetNetworkCredential().Password
            }
            $Datasource = [Npgsql.NpgsqlDataSource]::Create($ConnectionString)
        }
        Elseif ( -not $Datasource ) {
            Throw "Please connect to a PostgreSQL server first using Connect-PGServer or provide a Datasource object or connection parameters."
        }
        If ( -not ( ( $Datasource.ConnectionString.Split(";") | ConvertFrom-StringData).Database )) {
            If ( $Database ) {
                Use-PGDatabase -Database $Database
            }
            Else {
                Throw "Please provide a database name or add a Database via Use-PGDatabase to your connection."
            }
        }
    }

    Process {    
        $DBStrings = Format-PGString -TableName $Table -ColumnName $Columns
        $Query = 'SELECT {1} FROM {0};' -f $DBStrings.TableFullName, $DBStrings.Columns

        $Command = $Datasource.CreateCommand($Query)
        $Reader = $Command.ExecuteReader()

        $DataTable = New-Object System.Data.DataTable
        for ($i = 0; $i -lt $Reader.FieldCount; $i++) {
            $DataTable.Columns.Add($Reader.GetName($i)) | Out-Null
        }
        
        while ($Reader.Read()) {
            $row = $DataTable.NewRow()
            for ($i = 0; $i -lt $Reader.FieldCount; $i++) {
                $row[$i] = $Reader.GetValue($i)
            }
            $DataTable.Rows.Add($row)
        }
        $Reader.Close()
        $DataTable
        # $Reader = $Command.ExecuteReaderAsync()
        # $Reader = $Command.ExecuteReaderAsync().GetAwaiter().GetResult()
        # if ( $Reader.Status -eq 'Faulted' ) {
        #     If ( $Reader.Exception.InnerException ) {
        #         return $Reader.Exception.InnerException.Message            
        #     } 
        #     Else {
        #         return $Reader.Exception.Message
        #     }
        # }
        # $DataTable = New-Object System.Data.DataTable
        # $DataTable.Load($Reader.Result)
        # $DataTable      
    }
    End {
        $Reader.Dispose()  
    }
}