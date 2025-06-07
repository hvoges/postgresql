Function Add-PGDataset {

    [CmdletBinding(DefaultParameterSetName = 'Values')]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^\w+\.\w+$' })]
        [String]$Table,

        [Parameter(Mandatory,
            ValueFromPipeline)]
        # A Hashtable or OrderedDictionary with column names as keys and values as values
        $Values,

        [string]$Server = "localhost",
        
        [string]$Port = 5432, 
        
        [string]$Database = $Script:Database,

        [PSCredential]$Credential,

        [Npgsql.NpgsqlDataSource]$Datasource = $Script:Datasource,

        [Switch]$KeepOpen
    )

    Begin {
        $DBStrings = Format-PGString -TableName $Table
        If ( $Database -and $Credential ) {
            $ConnectionString = @{
                Host     = $Server
                Port     = $Port
                Database = $Database
                Username = $Credential.UserName
                Password = $Credential.GetNetworkCredential().Password
            }
            $Datasource = [Npgsql.NpgsqlDataSource]::Create($ConnectionString)
        }
        Elseif ( -not $Datasource ) {
            Throw 'No connection information provided'
        }
        $Connection = $Datasource.OpenConnectionAsync()
        $TableColumns = Get-PGTableColumnType -Table $DBStrings.UnquotedTable -Datasource $Datasource
    }

    Process {
        # Convert the Parameter Values to Columns and Values
        Switch ( $Values ) {
            { ( $Values -is [System.Collections.Hashtable] ) -or ( $Values -is [System.Collections.Specialized.OrderedDictionary] ) } {
                [Array]$ColumnNames = $Values.Keys
                [Array]$ColumnValues = $Values.Values
                break;
            }
            { $_ -is [System.Data.DataRow] } { 
                $ColumnNames = $Values.Table.Columns | ForEach-Object { $_.ColumnName }
                $ColumnValues = $Values.ItemArray
                break;
            }
            { $_ -is [System.Collections.IEnumerable] } {
                Throw 'An array cannot be inserted. Use a HashTable or an Object instead.'
            }
            Default {
                $ColumnNames = $Values.PSObject.Properties.Name
                $ColumnValues = $Values.PSObject.Properties.Value
            }
        }
     
        # convert Datarows and PSObjects to arrays 
        Switch ( $ColumnValues ) {
            { $_ -is [datetime] } { $_ = $_.ToString(); break }
            #ToDo: Test the Object-Types. PSObject only tests for PSCustomObjects
            #{ $_ -is [PSObject] } { $_ = $_.ToString(); break }
        }
        # Get the columns of the table
        # Generate enumerated List for Parameters in the form $Number 
        # https://www.npgsql.org/doc/basic-usage.html#parameters
        $ColumnString = '(' + ( $ColumnNames -join ',') + ')'     
        $ValueList = ( 1..$ColumnValues.Count | ForEach-Object { '$' + $_ } ) -join ',' 
        $Query = 'Insert into {0} {1} values({2});' -f $DBStrings.TableFullName, $ColumnString, $ValueList
        $Command = [npgsql.NpgsqlCommand]::new($Query, $Connection.Result)

        # ColumnValues is a ValueCollection, so we need to convert it to an array
        for ( $i = 1; $i -le $ColumnValues.length; $i++ ) {
            $Command.Parameters.AddWithValue(( ConvertTo-PGDBType -TypeName $TableColumns.($ColumnNames[$i - 1])), ( convertto-PGNetType -PGType $TableColumns.($ColumnNames[$i - 1]) -Value $ColumnValues[$i - 1]))
        }
        $Result = $command.ExecuteNonQueryAsync()
        # Wait till the query finished$ps
        if (( $Result.GetAwaiter().GetResult() ) -eq 1 ) {
            Write-Verbose "Data inserted"
        }
    }

    End {
        if ( -not $Datasource ) {
            $Result.Dispose()
        }
    }
}