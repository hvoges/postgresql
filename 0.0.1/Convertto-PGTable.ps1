function ConvertTo-PGTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline)]
        [Object]$InputObject,

        [Parameter(Mandatory=$true)]
        [String]$TableName
    )

    $CreateTable = "CREATE TABLE {0} (`n" -f $TableName

    foreach ( $Property in $InputObject.PSObject.Properties ) {
        if ( $PostgresType =  Get-PGDataType -Type $Property.TypeNameOfValue ) {
            $CreateTable += "`t{0} {1},`n" -f $Property.Name, $PostgresType
        }
        else {
            $CreateTable += "`t{0} text,`n" -f $Property.Name
        }
    }                
    
    $CreateTable = $CreateTable.TrimEnd(",`n")
    $createTable += "`n);"
    $CreateTable
}