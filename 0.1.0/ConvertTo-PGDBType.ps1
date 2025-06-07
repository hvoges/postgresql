Function ConvertTo-PGDBType {
    param(
        # The Name of the Type to convert to NpgsqlDbType
        [Parameter(Mandatory = $true)]
        [string]$TypeName
    )

    Switch ( $TypeName ) {
        { $_  -match '^character varying\(\d+\)$' } { $TypeName = 'text'; break }
        { $_  -match '^timestamp without time zone$' } { $TypeName = 'timestamp'; break }
        { $_  -match '^timestamp with time zone$' } { $TypeName = 'timestamptz'; break }
        { $_  -match '^interval$' } { $TypeName = 'time'; break }
    }

    Try {
        [NpgsqlTypes.NpgsqlDbType]$TypeName
    }
    Catch {
        Write-Error -Message "No mapping found for PostgreSQL type '$TypeName'"
    }
}