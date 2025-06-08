Function Add-PGSqlLibraries {
    [CmdletBinding()]
    Param()

    if ( $PSVersionTable.PSVersion.Major -le 5 ) {  
        $global:AssemblyPath = "$PSScriptRoot\npgsql\netstandard2\"
        Add-Type -Path "$AssemblyPath\Microsoft.Bcl.AsyncInterfaces.dll"
        Add-Type -Path "$AssemblyPath\Microsoft.Bcl.HashCode.dll"
        Add-Type -Path "$AssemblyPath\Microsoft.Extensions.Logging.Abstractions.dll"
        Add-Type -Path "$AssemblyPath\Npgsql.dll"
        Add-Type -Path "$AssemblyPath\System.Buffers.dll"
        Add-Type -Path "$AssemblyPath\System.Collections.Immutable.dll"
        Add-Type -Path "$AssemblyPath\System.Diagnostics.DiagnosticSource.dll"
        Add-Type -Path "$AssemblyPath\System.Memory.dll"
        Add-Type -Path "$AssemblyPath\System.Numerics.Vectors.dll"
        Add-Type -Path "$AssemblyPath\System.Runtime.CompilerServices.Unsafe.dll"
        Add-Type -Path "$AssemblyPath\System.Text.Json.dll"
        Add-Type -Path "$AssemblyPath\System.Threading.Channels.dll"
        Add-Type -Path "$AssemblyPath\System.Threading.Tasks.Extensions.dll"

        $Handler = {
            param($Sender, $e)
            if ($global:Resolving) { return $null }
            $global:Resolving = $true
            try {
                $RequestedName = [System.Reflection.AssemblyName]::new($e.Name)
                if ($RequestedName.Name -eq "System.Runtime.CompilerServices.Unsafe") {
                    return [System.Reflection.Assembly]::LoadFrom("$AssemblyPath\System.Runtime.CompilerServices.Unsafe.dll")
                }
                elseif ($RequestedName.Name -eq "System.Buffers") {
                    return [System.Reflection.Assembly]::LoadFrom("$AssemblyPath\System.Buffers.dll")
                }
            } finally {
                $global:Resolving = $false
            }
        }
        [AppDomain]::CurrentDomain.Add_AssemblyResolve($Handler)
    }
    Elseif ( $PSVersionTable.PSVersion.Major -gt 5 ) {
        $global:AssemblyPath = "$PSScriptRoot\npgsql\netcore\"
        Add-Type -Path "$AssemblyPath\microsoft.Extensions.logging.abstractions.dll"
        Add-Type -Path "$AssemblyPath\npgsql.dll"
    }
}
