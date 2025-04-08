Function Invoke-PGSql {
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$Query,

        [string]$Database = $Script:Database,

        [ValidateSet('DataTable', 'Scalar', 'NonQuery')]
        [String]$ResultType,

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
        $Command = $Datasource.CreateCommand($Query)
        Switch ( $ResultType ) {
            'DataTable' { 
                $Reader = $Command.ExecuteReaderAsync()
                $Reader.Status
                if ( $Reader.Status -eq 'Faulted' ) {
                    return $Reader.Exception.Message   
                }            
                $DataTable = New-Object System.Data.DataTable
                $DataTable.Load($Reader.Result)
                $DataTable
                $Reader.Dispose()             
            }
            'Scalar' { 
                $Executer = $Command.ExecuteScalarAsync() 
                $Executer.Wait()
                if ( $Executer.Status -eq 'Faulted' ) {
                    return $Executer.Exception.Message   
                }
                Write-Verbose "$($Executer.Result) returned from $Query"
                $Executer.Dispose()
            }
            'NonQuery' {         
                $Writer = $Command.ExecuteNonQueryAsync()
                $Writer.Wait()
                if ( $Writer.Status -eq 'Faulted' ) {
                    return $Reader.Exception.Message   
                }  
                Write-Verbose "$($Writer.Result) rows updated in $Table"
                $Writer.Dispose()     
            }
        }
    }
}