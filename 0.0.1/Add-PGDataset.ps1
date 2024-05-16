Function Add-PGDataset {
    <#
.SYNOPSIS
    Inserts data into a PostgreSQL table.

.DESCRIPTION
    The Add-PgsDataset function allows for the insertion of data into a PostgreSQL table by directly providing values or column-value pairs. This function supports connections to PostgreSQL using Npgsql, facilitating operations with databases through pipeline input or parameterized inputs.

.PARAMETER Server
    The hostname or IP address of the PostgreSQL server. Defaults to "localhost".

.PARAMETER Port
    The port on which the PostgreSQL server is listening. Defaults to 5432.

.PARAMETER Database
    The name of the PostgreSQL database to connect to. This parameter is mandatory.

.PARAMETER Credential
    The PSCredential object containing the username and password for database authentication.

.PARAMETER Datasource
    An Npgsql.NpgsqlDataSource object representing the data source. If not provided, it will be created using other connection parameters.

.PARAMETER Table
    The name of the table to insert data into. This parameter is mandatory.

.PARAMETER Values
    An array of values to be inserted into the table. Each value in the array represents a single row's value for the columns in the table. This parameter is mandatory when using the 'Values' parameter set.

.PARAMETER ColumnValuePairs
    A hashtable where each key-value pair represents a column name and its corresponding value to be inserted. This parameter is mandatory when using the 'ColumnValuePairs' parameter set.

.EXAMPLE
    $credential = Get-Credential
    $values = @('John', 'Doe', 30)
    Add-PgsDataset -Server 'db.example.com' -Database 'mydb' -Credential $credential -Table 'users' -Values $values

    This example inserts a single row into the 'users' table with the values provided in the $values array.

.EXAMPLE
    $credential = Get-Credential
    $columnValuePairs = @{
        FirstName = 'John'
        LastName = 'Doe'
        Age = 30
    }
    Add-PgsDataset -Server 'db.example.com' -Database 'mydb' -Credential $credential -Table 'users' -ColumnValuePairs $columnValuePairs

    This example inserts a single row into the 'users' table using the column-value pairs provided in the $columnValuePairs hashtable.

.NOTES
    This function requires the Npgsql library for connecting to and working with PostgreSQL databases. Ensure that this library is available and loaded into your PowerShell session.

    The function supports inserting data by specifying either an array of values (assuming the order matches the table columns) or a hashtable of column-value pairs for more precise control over the inserted data.
#>
    
    [CmdletBinding(DefaultParameterSetName = 'Values')]
    Param(
        [string]$Server = "localhost",
        
        [string]$Port = 5432, 
        
        [string]$Database,

        [PSCredential]$Credential,

        [Npgsql.NpgsqlDataSource]$Datasource = $Script:Datasource,

        [Parameter(Mandatory = $true)]
        [String]$Table,

        [Parameter(ParameterSetName = 'Values')]
        # A String-Array with all Columns to be inserted. Alternativly use the ColumnValuePairs parameter
        [String[]]$Columns, 

        [Parameter(Mandatory,
            ParameterSetName = 'Values',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        # An Array with all Values to be inserted. If only some columns are to be inserted, use the ColumnValuePairs parameter
        $Values,
        #[Object]$Values, 

        [Parameter(Mandatory,
            ParameterSetName = 'ColumnValuePairs',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        # A Hashtable containing the ColumnName and its Value
        [hashtable]$ColumnValuePairs
        # [String[]]$Columns = '*'
    )

    Begin {
        if ( $Values -isnot [System.Collections.Hashtable] ) {
            $DBStrings = Format-PGString -TableName $Table -ColumnName $Columns           
        }
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
        $Connection = $Datasource.OpenConnectionAsync()
    }

    Process {
        if (( $Values -is [System.Collections.Hashtable] ) -or ( $Values -is [System.Collections.Specialized.OrderedDictionary])) {
# ColumnValuePairs checken
            $DBStrings = Format-PGString -TableName $Table -ColumnName $Values.keys 
            $ValueList = ( 1..$ColumnValuePairs.keys.Count | ForEach-Object { '$' + $_ } ) -join ',' 
            $Query = 'INSERT INTO {0} ({1}) VALUES ({2});' -f $DBStrings.Table, $DBStrings.Columns, $ValueList
            Write-Verbose -Message "Query: $Query"
            $Command = [npgsql.NpgsqlCommand]::new($Query, $Connection.Result)
            Foreach ( $Value in $ColumnValuePairs.Values ) {
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
            Switch ( $Values ) {
                { $_ -is [System.Data.DataRow] } { $Values = $Values.itemarray }
                { $_ -is [array] } { }
                { $_ -is [PSObject] } { $Values = $Values.PSObject.Properties.Value }

                Default { Write-Error 'Data cannot be converted'; Continue }
            }
            if ($Columns.Count -ne $Values.Count) {
                Throw 'The number of columns and values must match'
            }
            $ValueList = ( 1..$Values.Count | ForEach-Object { '$' + $_ } ) -join ',' 
            $Query = 'Insert into {0} {1} values({2});' -f $DBStrings.Table,$ColumnString,$ValueList
            $Command = [npgsql.NpgsqlCommand]::new($Query, $Connection.Result)
            Foreach ($Value in $Values) {
                $Param = $Command.CreateParameter()
                if ( $Value -eq "Default") {
                    $null = $Command.Parameters.Add('')
                }
                else {
                    $Param.Value = $Value
                    # $Param.DataTypeName =  $PgsDataTypeMapping.($value.gettype().fullname)
                    $null = $Command.Parameters.Add($Param)
                }

            }
            $Result = $command.ExecuteNonQueryAsync()
            # Wait till the query finished
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