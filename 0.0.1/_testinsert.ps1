$ConnectionData = @{
    Host = "localhost"
    Username = "netzweise"
    Password = "Passw0rd"
    Database = "netzweise"
}
$Datasource = [Npgsql.NpgsqlDataSource]::Create($ConnectionData)
# Die Connection ist in der Property result gespeichert
$Connection = $Datasource.OpenConnectionAsync()
$command = [npgsql.NpgsqlCommand]::new('Insert into pode."Demo" ("id","name","Ort") values($1,$2,$3),($4,$5,$6),($7,$8,$9),($10,$11,$12)',$Connection.result)
$Values = 11,"Holger Voges","Hannover",12,"Hans Meier","Berlin",15,"Fred Feuerstein","Steinzeit",16,"Wilma Feuerstein","Steinzeit"
foreach ($Value in $Values) {
    $param = $command.CreateParameter()
    $param.Value = $value
    $command.Parameters.Add($param)  
}
$Result = $command.ExecuteNonQueryAsync() 
$Result.GetAwaiter().GetResult()

If ($Result.status -eq "Faulted") {
    $Result.Exception.Message
}

$command.Parameters.Clear()
$Values = 13,"Julia Schneider","Hannover",14,"Marco Kleinert","Köln",17,"Barney Geröllheimer","Steinzeit",18,"Betty Geröllheimer","Steinzeit"
foreach ($Value in $Values) {
    $param = $command.CreateParameter()
    $param.Value = $value
    $command.Parameters.Add($param)  
}
$Result = $command.ExecuteNonQueryAsync() 
$Result.GetAwaiter().GetResult()
$Connection.Result.Dispose()
