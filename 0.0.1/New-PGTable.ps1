function New-PGTable {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Connection')]    
        $Datasource,

        [Parameter(ParameterSetName = 'OnLink')]
        [string]$Server = "localhost",
        
        [Parameter(ParameterSetName = 'OnLink')]
        [string]$Port = "5432", 
        
        [Parameter(Mandatory = $true, ParameterSetName = 'OnLink')]
        [string]$Database,

        [Parameter(Mandatory = $true)]
        [String]$TableName,

        [Parameter(ParameterSetName='NewPKColumn')]
        [String]$NewPKColumnName,

        [Parameter(ParameterSetName='NewPKColumn')]
        [Switch]$AutoIncrementOff,
        
        [Parameter(ParameterSetName='ExistingColumnPK')]
        [String[]]$PKColumn,
        
        [Parameter(Mandatory = $true)]
        [PSCredential]$Credential,

        [Parameter(Mandatory = $true,
            ValueFromPipeline)]            
        [Object]$InputObject,

        [Switch]$force
    )

    Begin {

    }

    end {
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
        
        if ( $force ) {
            "DROP TABLE IF EXISTS {0};" -f $TableName
        }

        if ( $PSCmdlet.ParameterSetName -eq 'NewPKColumn' ) {
            If ( -not $AutoIncrementOff ){
                $Serial = 'Serial'
            }
            Else {
                $Serial = 'integer'
            }
            $NewColumnPKStatement = "{0} {1} primary key,`n" -f $NewPKColumnName, $Serial
        }
        Elseif ( $PSCmdlet.ParameterSetName -eq 'ExistingColumnPK' ) {
            $PrimaryKey = @()
            Foreach ( $Column in $PKColumn ) {
                if ( $column -in $InputObject.PSObject.Properties.Name ) {
                    $PrimaryKey += $Column
                }
                else {
                    Write-Warning -Message ("Column {0} not found in the input object" -f $Column)
                }
            }
            $PKStatement = ",`nPRIMARY KEY ({0})" -f $PrimaryKey -join ", "        
        }

        $Columns = foreach ( $Property in $InputObject.PSObject.Properties ) {
            "{0} {1}" -f $Property.Name, ( Get-PgDataType -Type $Property.TypeNameOfValue )
        }
        
        $DBStrings = Format-PGString -TableName $TableName 
        $CreateStatement = "CREATE TABLE if not exists {0} `n({1}{2}{3});" -f $DBStrings.Table, $NewColumnPKStatement, ( $Columns -join ",`n"), $PKStatement
        $CreateStatement
    }
}
