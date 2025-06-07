function Register-PGClientData {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param(        
        [string]$Database = $Script:Database,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]    
        [Object]$Object,

        [Parameter(Mandatory = $true)]
        [string]$Parameter,

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
        $ProcedureParameterNames = Get-PGProcedureParameter -Datasource $Datasource -Name $ProcedureName
    }

    process {         
        $sql = "CALL {0}()" -f $ProcedureName
        $command = $Datasource.CreateCommand($sql)

        $Counter = 0
        $ProcedureParameter = @{}
        foreach ( $ParameterName in $ProcedureParameterNames ){
            If ( $Object.($ParameterName.ParameterName) ) {
                '{0} => ${1}' -f $ProcedureParameter[$ParameterName.ParameterName], $counter
            }
        }
        
        $Null = foreach ($key in $Parameters.Keys) {
            $param = $command.CreateParameter()
            $param.ParameterName = $key
            $param.Value = $Parameters[$key]
            $command.Parameters.Add($param)
        }
        $result = $command.ExecuteNonQueryAsync()
        $null = $result.Wait()
        
        if ($result.IsFaulted) {
            throw $result.Exception.InnerException
        }
        Write-Verbose "Procedure executed successfully. Rows affected: $($result.Result)"
        return $result.Result
    }
    
}
