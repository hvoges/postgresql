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