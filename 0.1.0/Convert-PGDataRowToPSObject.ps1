function Convert-PGDataRowToPSObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Data.DataRow]$DataRow
    )


Process {
    # Create an ordered hashtable to store the properties.
    # This ensures the property order matches the column order.
    $DataRow | Select-Object -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors 
}
}