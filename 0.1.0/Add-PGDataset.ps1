Function Add-PGDataset {

    [CmdletBinding(DefaultParameterSetName = 'Values')]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^\w+\.\w+$' })]
        [String]$Table,

        [Parameter(ParameterSetName = 'Values')]
        # A String-Array with all Columns to be inserted. Alternativly use the ColumnValuePairs parameter
        [String[]]$Columns, 

        [Parameter(Mandatory,
            ParameterSetName = 'Values',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        # An Array with all Values to be inserted. 
        $Values,

        [string]$Server = "localhost",
        
        [string]$Port = 5432, 
        
        [string]$Database = $Script:Database,

        [PSCredential]$Credential,

        [Npgsql.NpgsqlDataSource]$Datasource = $Script:Datasource,

        [Switch]$KeepOpen
    )

    Begin {
        if ( $Values -isnot [System.Collections.Hashtable] ) {
            $DBStrings = Format-PGString -TableName $Table -ColumnName $Columns           
        }
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
        if (( $Values -is [System.Collections.Hashtable] ) -or ( $Values -is [System.Collections.Specialized.OrderedDictionary])) {
        # Add Properties using Command-Parameters        
            $DBStrings = Format-PGString -TableName $Table -ColumnName $Values.keys 
            $ValueList = ( 1..$Values.keys.Count | ForEach-Object { '$' + $_ } ) -join ',' 
            $Query = 'INSERT INTO {0} ({1}) VALUES ({2});' -f $DBStrings.TableFullName, $DBStrings.Columns, $ValueList
            Write-Verbose -Message "Query: $Query"
            
            $Command = [npgsql.NpgsqlCommand]::new($Query, $Connection.Result)
            Foreach ( $Value in $Values.Values ) {
                $Param = $Command.CreateParameter()
                $Param.Value = $Value
                $null = $Command.Parameters.Add($Param)  
            }
            $Result = $command.ExecuteNonQueryAsync()
            # Wait till the query finished
            if ( $Result.GetAwaiter().GetResult() -eq 1 ) {
                Write-Verbose "$($Writer.Result) rows updated in $Table"
            }            
        }
        else
        {
            $ColumnString = '(' + ($Columns -join ',') + ')'            
            # convert Datarows and PSObjects to arrays 
            Switch ( $Values ) {
                { $_ -is [System.Data.DataRow] } { $Values = $Values.itemarray; break }
                { $_ -is [array]               } { break }
                { $_ -is [PSObject]            } { $Values = $Values.PSObject.Properties.Value; break }

                Default { Write-Verbose 'Datatype wasn´t converted'; Continue }
            }
            if ( $Columns.Count -gt 1 -and $Values -is [string] ) {
                Throw 'Values must be an array when inserting multiple columns'
            }
            elseif ( $Columns.Count -ne $Values.Count ) {
                Throw 'The number of columns and values must match'
            }

            # Generate enumerated List for Parameters in the form $Number 
            # https://www.npgsql.org/doc/basic-usage.html#parameters
            $ValueList = ( 1..$Values.Count | ForEach-Object { '$' + $_ } ) -join ','  
            $Query = 'Insert into {0} {1} values({2});' -f $DBStrings.TableFullName,$ColumnString,$ValueList
            $Command = [npgsql.NpgsqlCommand]::new($Query, $Connection.Result)

            for ( $i=1; $i -le $columns.length; $i++ ) {
                $Command.Parameters.AddWithValue(( convertto-PGNetType -PGType $TableColumns.($Columns[$i-1]) -Value $Values[$i-1] ))
            }
            $Result = $command.ExecuteNonQueryAsync()
            # Wait till the query finished$ps
            if (( $Result.GetAwaiter().GetResult() ) -eq 1 ) {
                Write-Verbose "Data inserted"
            }
        }
    }

    End {
        if ( -not $Datasource ) {
            $Result.Dispose()
        }
    }
}