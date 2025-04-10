function Use-PGDatabase {
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Database
    )

    if ( $Script:Datasource ) {
        $ConnectionString = ( $Script:Datasource.ConnectionString.split(";") | Out-String )
        $ConnectionStringDictionary = ConvertFrom-StringData -StringData $ConnectionString
        $ConnectionStringDictionary["Database"] = $Database
        $Script:Datasource = [Npgsql.NpgsqlDataSource]::Create($ConnectionStringDictionary)
    } else {
        $Script:Database = $Database
    }    
}