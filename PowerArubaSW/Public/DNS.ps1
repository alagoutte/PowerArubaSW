#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWDns {

    <#
        .SYNOPSIS
        Get DNS information.

        .DESCRIPTION
        Get DNS information about the device

        .EXAMPLE
        Get-ArubaSWDns
        This function give you all the informations about the dns parameters configured on the switch
    #>

    Param(
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/dns"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json)

        $run
    }

    End {
    }
}

function Set-ArubaSWDns {

    <#
        .SYNOPSIS
        Set global configuration about DNS

        .DESCRIPTION
        Set DNS global parameters

        .EXAMPLE
        Set-ArubaSWDns -mode Manual
        Set the DNS mode to manual

        .EXAMPLE
        Set-ArubaSWDns -mode DHCP
        Set the DNS mode to DHCP

        .EXAMPLE
        Set-ArubaSWDns -mode Manual -server1 192.0.2.1 -server2 192.0.2.2 -domain example.org
        This set DNS mode to manual with server 1 and server 2 and domain name to example.org

        .EXAMPLE
        Set-ArubaSWDns -mode Manual -domain example.org, example.net
        This set DNS mode to manual with domain name to example.org and example.net
    #>

    Param(
        [Parameter (Mandatory = $true)]
        [ValidateSet ("DHCP", "Manual")]
        [string]$mode,
        [Parameter (Mandatory = $false)]
        [string]$server1,
        [Parameter (Mandatory = $false)]
        [string]$server2,
        [Parameter (Mandatory = $false)]
        [string[]]$domain,
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/dns"

        $conf = New-Object -TypeName PSObject

        $ip1 = New-Object -TypeName PSObject

        $ip2 = New-Object -TypeName PSObject

        $check = Get-ArubaSWDns

        switch ( $mode ) {
            DHCP {
                $mode_status = "DCM_DHCP"
            }
            Manual {
                $mode_status = "DCM_MANUAL"
            }
        }

        $conf | Add-Member -name "dns_config_mode" -membertype NoteProperty -Value $mode_status

        if ($PsBoundParameters.ContainsKey('server1')) {
            $ip1 | Add-Member -name "version" -MemberType NoteProperty -Value "IAV_IP_V4"

            $ip1 | Add-Member -name "octets" -MemberType NoteProperty -Value $server1

            $conf | Add-Member -name "server_1" -membertype NoteProperty -Value $ip1
        }
        else {
            $conf | Add-Member -name "server_1" -membertype NoteProperty -Value $check.server_1
        }

        if ($PsBoundParameters.ContainsKey('server2')) {
            $ip2 | Add-Member -name "version" -MemberType NoteProperty -Value "IAV_IP_V4"

            $ip2 | Add-Member -name "octets" -MemberType NoteProperty -Value $server2

            $conf | Add-Member -name "server_2" -membertype NoteProperty -Value $ip2
        }
        else {
            $conf | Add-Member -name "server_2" -membertype NoteProperty -Value $check.server_2
        }

        if ( $PsBoundParameters.ContainsKey('domain') ) {
            $conf | Add-Member -name "dns_domain_names" -membertype NoteProperty -Value $domain
        }

        $response = Invoke-ArubaSWWebRequest -method "PUT" -body $conf -uri $uri -connection $connection

        $run = $response | ConvertFrom-Json

        $run
    }

    End {
    }
}

function Remove-ArubaSWDns {

    <#
        .SYNOPSIS
        Remove DNS server or domain name on the switch

        .DESCRIPTION
        Remove DNS server or domain name

        .EXAMPLE
        Remove-ArubaSWDns
        Remove the ip of server 1 and server 2, and all the domain names
    #>

    Param(
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm,
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $dns = New-Object -TypeName PSObject

        $dns | Add-Member -name "dns_config_mode" -membertype NoteProperty -Value "DCM_DISABLED"

        $uri = "rest/v4/dns"

        if ( -not ( $noconfirm )) {
            $message = "Remove DNS on the switch"
            $question = "Proceed with removal of DNS config ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove DNS"
            $null = Invoke-ArubaSWWebRequest -method "PUT" -body $dns -uri $uri -connection $connection
            Write-Progress -activity "Remove DNS" -completed
        }
    }

    End {
    }
}
