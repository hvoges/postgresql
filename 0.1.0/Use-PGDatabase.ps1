function Use-PGDatabase {
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Database
    )

    if ( $Script:Datasource ) {
        $ConnectionString = $Script:Datasource.ConnectionString
        $ConnectionString.Database = $Database
        $Script:Datasource = [Npgsql.NpgsqlDataSource]::Create($ConnectionString)
    } else {
        $Script:Database = $Database
    }
}