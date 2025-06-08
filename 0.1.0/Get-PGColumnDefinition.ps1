function Get-PGColumnDefinition {

    [CmdletBinding()]
    Param(        
        [Parameter(mandatory = $true,
                   ValueFromPipeline = $true,   
                   ValueFromPipelineByPropertyName = $true)]
        [string]$Table,

        [Parameter()]
        [string]$Database,        

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
        $DBStrings = Format-PGString -TableName $Table -ColumnName $Columns 

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
        $Query = @"
SELECT * FROM information_schema.columns
WHERE table_name = '{0}' 
ORDER BY ordinal_position;
"@ -f $DBStrings.Table.Trim('"')

        $Command = $Datasource.CreateCommand($Query)
        $Reader = $Command.ExecuteReaderAsync() 
        if ( $Reader.Status -eq 'Faulted' ) {
            return $Reader.Exception.Message   
        }            
        $DataTable = New-Object System.Data.DataTable
        $DataTable.Load($Reader.Result)
        $DataTable
        If ( -not $KeepOpen ) {
            $Reader.Dispose()
        }
    }
}