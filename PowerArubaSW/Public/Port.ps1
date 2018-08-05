﻿#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWPort {

    <#
        .SYNOPSIS
        Get Port of the Switch

        .DESCRIPTION
        Get Portinformation

        .EXAMPLE
        Get-ArubaSWPort

        Get Port information (name, status, config mode, flow control...)

        .EXAMPLE
        Get-ArubaSWPort -port_id 3

        Get Port information of port_id 3
    #>

    Param(
        [Parameter (Mandatory=$false)]
        [string]$port_id
    )

    Begin {
    }

    Process {

        $url = "rest/v4/ports"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = ($response | convertfrom-json).port_element

        if ( $port_id ) {
            $run | where-object { $_.id -match $port_id}
        } else {
            $run
        }

    }

    End {
    }
}

function Set-ArubaSWPort {

    <#
        .SYNOPSIS
        Configure Port information

        .DESCRIPTION
        Configurate Port Information (Status, Name, Mode...)

        .EXAMPLE
        $port = Get-ArubaSWPort -port_id 3
        PS C:\>$port | Set-ArubaSWPort -is_port_enable -name PowerArubaSW-Port

        Enable the port 3 and set name/description to PowerArubaSW-Port

        .EXAMPLE
        Set-ArubaSWPort -port_id 3 -is_flow_control_enable:$false -is_dsnoop_port_trusted:$false

        Disable the flow control and DHCP Snooping Port Trusted on port_id 3

        .EXAMPLE
        $port = Get-ArubaSWPort -port_id 3
        PS C:\>$port | Set-ArubaSWPort -config_mode PCM_100HDX

        Configure port 3 to 100 HDX
    #>

    Param(
        [Parameter (Mandatory=$true, ParameterSetName="port_id")]
        [string]$port_id,
        [Parameter (Mandatory=$true, ValueFromPipeline=$true, Position=1, ParameterSetName="port")]
        #ValidateScript({ Validateport $_ })]
        [psobject]$port,
        [Parameter (Mandatory=$false)]
        [ValidateLength(1,64)]
        [string]$name,
        [Parameter (Mandatory=$false)]
        [switch]$is_port_enabled,
        [Parameter (Mandatory=$false)]
        [ValidateSet("PCM_10HDX", "PCM_100HDX", "PCM_10FDX", "PCM_100FDX", "PCM_AUTO", "PCM_1000FDX", "PCM_AUTO_10", "PCM_AUTO_100",
        "PCM_AUTO_1000", "PCM_AUTO_10G", "PCM_AUTO_10_100", "PCM_AUTO_2500", "PCM_AUTO_5000", "PCM_AUTO_2500_5000", "PCM_AUTO_1000_2500",
        "PCM_AUTO_1000_2500_5000")]
        [string]$config_mode,
        [Parameter (Mandatory=$false)]
        [switch]$is_flow_control_enabled,
        [Parameter (Mandatory=$false)]
        [switch]$is_dsnoop_port_trusted
    )

    Begin {
    }

    Process {

        #get port id from port ps object
        if($port) {
            $port_id = $port.id
        }

        $url = "rest/v4/ports/${port_id}"

        $_port = new-Object -TypeName PSObject

        $_port | add-member -name "id" -membertype NoteProperty -Value $port_id

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $_port | add-member -name "name" -membertype NoteProperty -Value $name
        }

        if ( $PsBoundParameters.ContainsKey('is_port_enabled') ) {
            if ( $is_port_enabled ) {
                $_port | add-member -name "is_port_enabled" -membertype NoteProperty -Value $true
            } else {
                $_port | add-member -name "is_port_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('config_mode') ) {
            $_port | add-member -name "config_mode" -membertype NoteProperty -Value $config_mode
        }

        if ( $PsBoundParameters.ContainsKey('is_flow_control_enabled') ) {
            if ( $is_flow_control_enabled ) {
                $_port | add-member -name "is_flow_control_enabled" -membertype NoteProperty -Value $true
            } else {
                $_port | add-member -name "is_flow_control_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('is_dsnoop_port_trusted') ) {
            if ( $is_dsnoop_port_trusted ) {
                $_port | add-member -name "is_dsnoop_port_trusted" -membertype NoteProperty -Value $true
            } else {
                $_port | add-member -name "is_dsnoop_port_trusted" -membertype NoteProperty -Value $false
            }
        }
        $response = invoke-ArubaSWWebRequest -method "PUT" -body $_port -url $url

        $response | convertfrom-json
    }

    End {
    }
}