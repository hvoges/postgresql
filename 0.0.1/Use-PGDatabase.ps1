function Use-PGDatabase {
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Database
    )

    $Script:Database = $Database
}