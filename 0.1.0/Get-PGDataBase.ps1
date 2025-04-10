Function Get-PGDataBase {
    [CmdletBinding()]
    Param(        
        [Parameter()]
        [string]$Database,

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
            Throw "Please connect to a PostgreSQL server first using Connect-PGServer or provide a Datasource object or connection parameters."
        }
    }

    process {
        If ($Database) {
            $WhereStatement = "Where datname = '{0}'" -f $Database
        }
        $Query = @"
SELECT
    oid, 
    datname as database,
    pg_database_size(datname) as size,
    datdba as owner,
    encoding as dbencoding,
    datlocprovider as LocaleProvider,
    datistemplate as IsTemplate,
    datallowconn as Connectable,
    datconnlimit as MaxConnections,
    datfrozenxid as FrozenTransacionID,
    datminmxid as lastMinTransactionID,
    dattablespace as DefaultTableSpace,
    datcollate as Collation,
    datctype as CharacterClassification,
    datlocale as IcuLocale, 
    daticurules as IcuCollationRules,
    datcollversion as CollationVersion,
    array_to_string(datacl, ',') as datacl,
    'https://www.postgresql.org/docs/current/catalog-pg-database.html' as documentation
FROM
    pg_catalog.pg_database
{0};
"@ -f $WhereStatement
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