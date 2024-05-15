function Remove-PGDatabase {
    [CmdletBinding()]

    Param(        
        [Parameter(Mandatory=$true)]
        [string]$Database,

        [Parameter(ParameterSetName='Connection')]    
        $Datasource = $Script:Datasource,

        [Parameter(ParameterSetName='OnLink')]
        [string]$Server = "localhost",
        
        [Parameter(ParameterSetName='OnLink')]
        [string]$Port = 5432, 

        [Parameter(Mandatory=$true,ParameterSetName='OnLink')]
        [PSCredential]$Credential,

        [Switch]$force
    )    

    Begin {
        If ( $PSCmdlet.ParameterSetName -eq 'OnLink') {
            $ConnectionString = @{
                Host = $Server
                Port = $Port
                Username = $Credential.UserName
                Password = $Credential.GetNetworkCredential().Password
            }
            $Datasource = [Npgsql.NpgsqlDataSource]::Create($ConnectionString)
        }
        Elseif ( -not $Datasource ) {
            Throw "Please connect to a PostgreSQL server first using Connect-PGDatabase or provide a Datasource object or connection parameters."
        }
        if ($force) {
            $ForceOption = " WITH (FORCE)"
        }
    }

    process {
        $DropStatement = "Drop Database {0}{1}" -f $Database, $ForceOption

        $Command = $Datasource.CreateCommand($DropStatement)
        $Executer = $Command.ExecuteScalarAsync() 
        $Executer.Wait()
        if ( $Executer.Status -eq 'Faulted' ) {
            return $Executer.Exception.Message   
        }
        Write-Verbose "$($Executer.Result) returned from $Query"
        $Executer.Dispose()
    }
}
