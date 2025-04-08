function New-PGDatabase {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory)]
        [string]$Database,

        [Parameter(ParameterSetName = 'Connection')]    
        $Datasource = $Script:Datasource,

        [Parameter(ParameterSetName = 'OnLink')]
        [string]$ComputerName = "localhost",
    
        [Parameter(ParameterSetName = 'OnLink')]
        [string]$Port = 5432, 
    
        [Parameter(Mandatory = $true, ParameterSetName = 'OnLink')]
        [PSCredential]$Credential
    )

    Begin {
        If ( $PSCmdlet.ParameterSetName -eq 'OnLink') {
            $ConnectionString = @{
                Host = $ComputerName
                Port = $Port
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

    process {
        $CreateStatement = "CREATE Database {0}" -f $Database
        $Command = $Datasource.CreateCommand($CreateStatement)
        $Executer = $Command.ExecuteScalarAsync() 
        $Executer.Wait()
        if ( $Executer.Status -eq 'Faulted' ) {
            return $Executer.Exception.Message   
        }
        Write-Verbose "IsCompleted Successfully: $($Executer.IsCompletedSuccessfully)"
        $Executer.Dispose()
    }
}
