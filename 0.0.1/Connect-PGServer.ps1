Function Connect-PGServer {
<#
.SYNOPSIS
Connects to a PostgreSQL server.

.DESCRIPTION
This function establishes a connection to a PostgreSQL server using the specified parameters.

.PARAMETER Server
The name or IP address of the PostgreSQL server.

.PARAMETER Port
The port number on which the PostgreSQL server is listening.

.PARAMETER Database
The name of the database to connect to.

.PARAMETER Username
The username to use for authentication.

.PARAMETER Password
The password to use for authentication.

.EXAMPLE
Connect-PgsServer -Server "localhost" -Port 5432 -Database "mydb" -Username "myuser" -Password "mypassword"

This example connects to a PostgreSQL server running on localhost, using port 5432, and authenticates with the specified username and password.

#>
    param(
        [string]$ComputerName = "localhost",
        
        [string]$Port = 5432, 
        
        [Parameter(Mandatory=$true)]
        [pscredential]$Credential,

        [switch]$Passthru
        )

        
        $ConnectionString = @{
            Host = $ComputerName
            Port = $Port
            Username = $Credential.UserName
            Password = $Credential.GetNetworkCredential().Password
        }
        $Script:Datasource = [Npgsql.NpgsqlDataSource]::Create($ConnectionString)
        If ($Passthru) {
            $Script:Datasource
        }
}