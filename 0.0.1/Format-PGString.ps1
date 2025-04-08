function Format-PGString {
    <#
.SYNOPSIS
Formats an input string for table names and column names.

.DESCRIPTION
The Format-PGString function takes a table name and an array of column names as input and formats them for use in SQL queries or other scenarios where table and column names need to be properly quoted and escaped.

.PARAMETER TableName
The name of the table to be formatted. This parameter accepts a string value.

.PARAMETER ColumnName
An array of column names to be formatted. This parameter accepts a string array.

.OUTPUTS
PSCustomObject

The function returns a PSCustomObject with two properties:
- Table: The formatted table name.
- Columns: The formatted column names, separated by commas.

.EXAMPLE
Format-PGString -TableName 'my.table' -ColumnName 'col1', 'col2', 'col3'

Table   Columns
-----   -------
"my"."table" "col1","col2","col3"

.EXAMPLE
Format-PGString -TableName 'my.table' -ColumnName '*'

Table   Columns
-----   -------
"my"."table" *

.NOTES
- The function assumes that the input strings do not contain any quotes. If the input strings contain quotes, they will be trimmed.
- If the ColumnName parameter contains a single asterisk (*), it will be treated as a wildcard and returned as is.
- The function uses the PowerShell string formatting operator (-f) to properly escape and quote the table and column names.

#>
    [CmdletBinding()]
    param(
        [ValidateScript({ $_ -match '^\w+\.\w+$|^"\w+\"."\w+"$' }, ErrorMessage = 'Table name must be in the format "schema.table"')]
        [Parameter()]
        [string]$TableName,

        $ColumnName
    )

    $FormattedStrings = [PSCustomObject]@{
        Table         = ''; 
        Schema        = '';
        TableFullName = '';
        Columns       = ''
    }
    
    If ( $TableName -match '^"\w+\"."\w+"$') {
        $NameParts = Foreach ( $part in $TableName.split('.')) {
            '{0}' -f $part.Trim('"')
        }
    }
    else {
        $NameParts = Foreach ( $part in $TableName.split('.')) {
            '"{0}"' -f $part.Trim('"')
        }
    }
    $FormattedStrings.Table = $NameParts[-1]
    $FormattedStrings.Schema = $NameParts[0]
    $FormattedStrings.TableFullName = $NameParts -join '.'
    # If the ColumnName parameter contains a single asterisk (*), it will be treated as a wildcard and returned as is.
    if ( $ColumnName -match '\*' ) {
        $FormattedStrings.Columns = [String]$ColumnName
    }
    ElseIf (( $ColumnName -is [System.Collections.Hashtable] ) -or ( $Columname -is [System.Collections.Specialized.OrderedDictionary] )) {
        $Columns = foreach ( $Column in $ColumnName.Keys ) {
            '"{0}"' -f $Column.Trim('"')
        }
        $FormattedStrings.Columns = $Columns -join ',' | Out-String
    }
    ElseIf ( $ColumnName ) {
        $Columns = foreach ( $Column in $ColumnName ) {
            '"{0}"' -f $Column.Trim('"')
        }
        $FormattedStrings.Columns = $Columns -join ',' | Out-String
    }

    $FormattedStrings
}