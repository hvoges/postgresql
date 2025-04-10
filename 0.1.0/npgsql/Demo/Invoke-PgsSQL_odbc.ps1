Function Invoke-PgsSql {
    param(
        [string]$Server = "localhost",
        
        [string]$Port = 5432, 
        
        [Parameter(Mandatory=$true)]
        [string]$Database,
        
        [Parameter(Mandatory=$true)]
        [string]$User,
        
        [Parameter(Mandatory=$true)]
        [string]$Password,
        
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Query
    )

    $DBConnectionString = "DRIVER={PostgreSQL Unicode};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
    $DBConn = New-Object System.Data.Odbc.OdbcConnection;
    $DBConn.ConnectionString = $DBConnectionString;
    $DBConn.Open();
    $DBCmd = $DBConn.CreateCommand();
    $DBCmd.CommandText = "$Query"
    $result = $DBCmd.ExecuteReader();
    $result
    $DBConn.Close();
}