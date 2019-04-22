#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Set-Cookie {

    Param(
        [Parameter (Mandatory = $true)]
        [string]$name,
        [Parameter (Mandatory = $true)]
        [string]$value,
        [Parameter (Mandatory = $true)]
        [string]$domain,
        [string]$path = "/"
    )

    $c = New-Object System.Net.Cookie;
    $c.Name = $name;
    $c.Path = $path;
    $c.Value = $value
    $c.Domain = $domain;
    return $c;
}
