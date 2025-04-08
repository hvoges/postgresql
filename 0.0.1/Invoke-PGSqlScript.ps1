Function Invoke-PGSqlScript {
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$FilePath,

        [string]$Database = $Script:Database,

        [Parameter(ParameterSetName = "OnLink")]
        [string]$ComputerName = "localhost",
        
        [Parameter(ParameterSetName = "OnLink")]
        [string]$Port = 5432, 

        [Parameter(Mandatory = $true,ParameterSetName = "OnLink")]
        [PSCredential]$Credential,
        
        [Parameter(ParameterSetName = "Connection")]
        $Datasource = $Script:Datasource
    )

    Begin {
        If ( -not $Database ) {
            Throw "Please provide a database name or connect to a database first using Connect-PGServer."
        }
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
        $Query = Get-Content -Path $FilePath -Raw
        $Command = $Datasource.CreateCommand($Query)
        $Executer = $Command.ExecuteNonQueryAsync() 
        $Executer.Wait()
        if ( $Executer.Status -eq 'Faulted' ) {
            return $Executer.Exception.Message   
        }            
        return $Executer.Result
    }
    
    End {
        $Command.Dispose()
 
    }
}