function New-PGTable {

    [CmdletBinding(DefaultParameterSetName = 'Connection')]
    Param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Connection')]    
        [Npgsql.NpgsqlDataSource]$Datasource,

        [Parameter(ParameterSetName = 'OnLink')]
        [string]$Server = "localhost",
        
        [Parameter(ParameterSetName = 'OnLink')]
        [string]$Port = "5432", 

        [Parameter(Mandatory = $true, ParameterSetName = 'OnLink')]
        [PSCredential]$Credential,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'OnLink')]
        [string]$Database,

        [Parameter(Mandatory = $true, ValueFromPipeline)]            
        [HashTable]$ColumnDefinition,

        [String]$TableName = $ColumnDefinition.TableName,

        [Switch]$force
    )

    Begin {
        If (-not $Datasource ) {
            $ConnectionString = @{
                Host     = $Server
                Port     = $Port
                Database = $Database
                Username = $Credential.UserName
                Password = $Credential.GetNetworkCredential().Password
            }
            $Datasource = [Npgsql.NpgsqlDataSource]::Create($ConnectionString)
        }
    }

    Process {
        if ( $force ) {
            "DROP TABLE IF EXISTS {0};" -f $TableName
        }

        if ( -not ( $TableName )) {
            Throw "Please provide a value 'tablename' in the ColumnDefinition hash table or with parameter -tablename"
        }
        $TableDefinition.Remove("TableName")

        if ( $ColumnDefinition.PrimaryKeyNewColumn ) {
            If ( -not $ColumnDefinition.PrimaryKeyAutoIncrementOff ){
                $Serial = 'Serial'
            }
            Else {
                $Serial = 'integer'
            }
            $NewColumnPKStatement = "{0} {1} primary key,`n" -f $NewPKColumnName, $Serial
        }
        Elseif ( $ColumnDefinition.PrimaryKeyExistingColumn ) {
            $PrimaryKey = @()
            Foreach ( $Column in $PKColumn ) {
                if ( $column -in $ColumnDefinition.Keys ) {
                    $PrimaryKey += $Column
                }
                else {
                    Write-Warning -Message ("Column {0} not found in the input object" -f $Column)
                }
            }
            $PKStatement = ",`nPRIMARY KEY ({0})" -f $PrimaryKey -join ", "        
        }

        $Columns = foreach ( $Column in $ColumnDefinition.GetEnumerator()) {
                "{0} {1}" -f $Column.key, ( Get-PgDataType -Type $Column.Value)
        }
        
        $DBStrings = Format-PGString -TableName $TableName 
        $CreateStatement = "CREATE TABLE if not exists {0} `n({1}{2}{3});" -f $DBStrings.TableFullName, $NewColumnPKStatement, ( $Columns -join ",`n"), $PKStatement
        $CreateStatement
    }

    end {

    }
}
