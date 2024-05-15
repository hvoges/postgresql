function ConvertTo-PGTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [PSObject]$InputObject,

        [Parameter(mandatory=$true)]        
        [string]$TableName,

        [Switch]$PassThru

    )

    process {
        # Get object properties and data types
        $Properties = $InputObject.PSObject.Properties | Select-Object Name,TypeNameOfValue
        # Map .NET data types to PostgreSQL data types

        # Build CREATE TABLE statement
        $CreateTable = "CREATE TABLE {0} (`n" -f $TableName
        foreach ( $Property in $Properties ) {
            $PostgresType = $Script:PgsDataTypeMapping[$Property.TypeNameOfValue]
            if ( $null -eq $PostgresType ) { $PostgresType = 'text' } # Default to text if type not mapped
            $CreateTable += "`t{0} {1},`n" -f $Property.Name, $PostgresType
        }
        $CreateTable = $CreateTable.TrimEnd(",`n")
        $createTable += "`n);"

        # Output CREATE TABLE statement
        if ( $PassThru ) {
            $CreateTable
        }
        else {
            Write-Verbose $CreateTable
        }
    }
}