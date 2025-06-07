function Invoke-PGProcedure {
    [CmdletBinding(DefaultParameterSetName='Connection')]
    Param(        
        [string]$Database = $Script:Database,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]    
        [Object]$InputObject,

        [Parameter(Mandatory = $true)]
        [string]$ProcedureName,

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
        Write-Verbose "Datasource: $Datasource"
        If ( -not ( ( $Datasource.ConnectionString.Split(";") | ConvertFrom-StringData).Database )) {
            If ( $Database ) {
                Use-PGDatabase -Database $Database
            }
            Else {
                Throw "Please provide a database name or add a Database via Use-PGDatabase to your connection."
            }
        }
        $ProcedureParameter = Get-PGProcedureParameter -Datasource $Datasource -Name $ProcedureName
    }

    process {         
        $Command = $datasource.CreateCommand($ProcedureName)
        $command.CommandType = [System.Data.CommandType]::StoredProcedure

        # Add Object-Properties as parameters to the command
        foreach ( $Parameter in $ProcedureParameter ) {
            If ($InputObject.($Parameter.ParameterName) ) {
                $null = $Command.Parameters.AddWithValue($Parameter.parametername,( ConvertTo-PGNetType -PGType $Parameter.datatype -Value ($Inputobject.($Parameter.Parametername))))
            }
        }

        $result = $command.ExecuteReaderAsync();
        $result.Wait()        
        if ($result.IsFaulted) {
            throw $result.Exception.InnerException
        }
        Write-Verbose "Procedure executed successfully. Rows affected: $($result.Result)"
        return $result.Result
    }
}