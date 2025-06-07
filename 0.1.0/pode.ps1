Import-Module -Name Pode.Web

# Start-PodeServer {
#     Use-PodeWebTemplates -Title 'Rauminstallation' -Theme Light
#     Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http -Name User
#     New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging
#     Add-PodeRoute -Method Post -Path '/Clients' -ScriptBlock {
#         Set-PodeResponseStatus -Code 200
#         $WebEvent.Data | Out-File E:\logs\received.json
#         $WebEvent.Endpoint | Out-File E:\Logs\webevent.json
#     }
# }

Start-PodeServer {
    Add-PodeEndpoint -Address * -Port 80 -Protocol Http

#    Add-PodeRoute -Method Get -Path '/clients' -ScriptBlock {
#        Write-PodeJsonResponse -Value @{ 'value' = $env:COMPUTERNAME; }
#    }

    Add-PodeRoute -Method Get -Path '/ClientConfiguration' -ScriptBlock {
        $Data = $WebEvent.Data 
        $Data | Out-File E:\logs\received.json
        # $WebEvent.Endpoint | Out-File E:\Logs\webevent.json
        Write-PodeJsonResponse -Value $Data
    }

    Add-PodeRoute -Method Get -Path '/ClientConfiguration' -ScriptBlock {
        $Data = $WebEvent.Data 
        $Data | Out-File E:\logs\received.json
        # $WebEvent.Endpoint | Out-File E:\Logs\webevent.json
        Write-PodeJsonResponse -Value $Data
    }
}