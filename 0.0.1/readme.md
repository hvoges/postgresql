# Postgresql for Powershell - A module to manage Postgresql from Powershell
This module is using the free and open Source npgsql [.net library](https://www.npgsql.org/) to access Postgresql from Powershell. The Binaries are delivered with this module and are stored in the npgsql-Folder. Please check the version of the module - currently it´s Version 8.0. You can update the binaries by downloading the nuget-package from the [nuget-website](https://www.nuget.org/packages/Npgsql/) and extracting the package with 7-zip. The Binaries are stored in the subfolder npgsql of this module. 
npgsql is using .net framework 
Currently the module is in a very early development-state. It´s main purpose is to store and query data from a postgresql cluster from powershell without deeper postgresql knowledge. In future version, the implementation of management-cmdlets like backup and restore and configuration of system settings is planned. One of the intentions I have with this module is to learn postgresql. 

Basically, you can access data stored in a postgresql-database by directly entering Connection-Information: 
Get-PGDatabase -