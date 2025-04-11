Function Get-PGTableColumnType {
    Param(        
        [string]$Database = $Script:Database,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]    
        [String]$Table,

        [String[]]$Column,

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
    }

    Process {    
        # $Query = 'SELECT {1} FROM {0};' -f $DBStrings.TableFullName, $DBStrings.Columns
        if ( $Column -in '*',$Null ) {
            $ColumnFilter = ''
        }
        Elseif ( $Column )
        {
            $QuotedColumn = Foreach ( $ColumnItem in $Column ) {
                "'{0}'" -f $ColumnItem
            }
            $ColumnFilter = 'AND a.attname in ({0})' -f ($QuotedColumn -join ",")
        }

        $Query = @'
SELECT
    a.attname AS ColumnName,
    pg_catalog.format_type(a.atttypid, a.atttypmod) AS DataType
FROM
    pg_catalog.pg_attribute a
JOIN
    pg_catalog.pg_class c ON a.attrelid = c.oid
JOIN
    pg_catalog.pg_namespace n ON c.relnamespace = n.oid
WHERE
    c.relname = '{0}' -- Ersetzen Sie 'ihre_tabelle' durch den tatsächlichen Tabellennamen
    {1}
    AND a.attnum > 0
    AND NOT a.attisdropped;
'@ -f $Table,$ColumnFilter

        $Command = $Datasource.CreateCommand($Query)
        $Reader = $Command.ExecuteReaderAsync()
        if ( $Reader.Status -eq 'Faulted' ) {
            Write-Verbose $Query
            return $Reader.Exception.Message
        }
        $DataTable = New-Object System.Data.DataTable
        $DataTable.Load($Reader.Result)
        $DataTable  
    }
    End {
        $Reader.Dispose()  
    }
}