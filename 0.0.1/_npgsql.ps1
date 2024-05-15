Add-Type -path  .\npgsql\Npgsql.dll 
Add-Type -path  .\npgsql\Microsoft.Extensions.Logging.Abstractions.dll

# $connString = "host=localhost;Username=netzweise;Password=Passw0rd;Database=netzweise"
$connection = @{
    Host = "localhost"
    Username = "netzweise"
    Password = "Passw0rd"
    Database = "netzweise"
}
$Datasource = [Npgsql.NpgsqlDataSource]::Create($connection)

# $Datasource = [Npgsql.NpgsqlDataSource]::Create($connString)
$Command = $Datasource.CreateCommand('Select * from pode."Demo"')
$Reader = $Command.ExecuteReaderAsync()
$DataTable = New-Object System.Data.DataTable
$DataTable.Load($Reader.Result)
$Reader.Dispose()


# if ( $Reader.result.HasRows ) {
#     # Iterate through the rows
#     while ($Reader.result.Read()) {
#         # For each row, iterate through each field
#         for ($i = 0; $i -lt $Reader.Result.FieldCount; $i++) {
#             # Output the field name and value
#             Write-Output "$($Reader.result.GetName($i)): $($Reader.result.GetValue($i))"
#         }
#         # Add a separator for readability
#         Write-Output "---------------------"
#     }
# } 





# $conn = New-Object Npgsql.NpgsqlDataSource($connString)
# $conn.Open()

# $sql = "SELECT * FROM mytable" 
# $cmd = New-Object Npgsql.NpgsqlCommand($sql, $conn)

# $dt = New-Object System.Data.DataTable
# $da = New-Object Npgsql.NpgsqlDataAdapter($cmd)
# $da.Fill($dt)

# $conn.Close()