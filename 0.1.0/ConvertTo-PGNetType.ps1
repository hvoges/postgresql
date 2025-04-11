<#
.SYNOPSIS
Converts a PostgreSQL data type to its corresponding .NET type.

.DESCRIPTION
The ConvertTo-PGNetType function takes a PostgreSQL data type as input and returns the corresponding .NET type.
If a value is provided, it attempts to cast the value to the corresponding .NET type.

.PARAMETER PGType
The PostgreSQL data type to convert.

.PARAMETER Value
Optional. The value to cast to the corresponding .NET type.

.EXAMPLE
ConvertTo-PGNetType -PGType "integer"
# Returns: [System.Int32]

.EXAMPLE
ConvertTo-PGNetType -PGType "text" -Value "Hello World"
# Returns: "Hello World" as a System.String object

.NOTES
This function relies on a $ToNetTypeMapping hashtable that maps PostgreSQL types to .NET types.
If no mapping is found for the provided PostgreSQL type, an error is raised.

.OUTPUTS
If a value is provided, returns the value cast to the corresponding .NET type.
If no value is provided, returns the .NET type itself.
#>
Function ConvertTo-PGNetType {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PGType,

        [object]$Value
    )

    if ( $ToNetTypeMapping.$PGType -and $Value ) 
    {
        $Value -as [Type]$ToNetTypeMapping.$PGType
    }
    elseif ( $ToNetTypeMapping.$PGType ) {
        [Type]$ToNetTypeMapping.$PGType
    }
    else {
        Write-Error -Message "No mapping found for PostgreSQL type '$PGType'"
    }
}