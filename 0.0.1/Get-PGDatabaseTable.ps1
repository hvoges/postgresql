function Get-PGDatabaseTable {
    [CmdletBinding()]
    Param(        
        [Parameter(ParameterSetName = 'OnLink',
            ValueFromPipeline = $true,   
            ValueFromPipelineByPropertyName = $true)]
        [string]$ComputerName = "localhost",
        
        [Parameter(ParameterSetName = 'OnLink')]
        [string]$Port = 5432, 
        
        [Parameter(Mandatory = $true, ParameterSetName = 'OnLink')]
        [PSCredential]$Credential,

        [Parameter(ParameterSetName = 'Connection')]    
        $Datasource = $Script:Datasource,

        [Parameter()]
        [string]$Database,

        [Parameter()]
        [string]$Table,

        [Parameter()]
        [Switch]$ShowViews
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
            Throw 'Please connect to a PostgreSQL server first using Connect-PGDatabase or provide a Datasource object or connection parameters.'
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