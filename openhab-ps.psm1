
function connect-OpenHAB {
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $OpenHAB_IP,
        $OpenHAB_Port = 8080,
        <#[Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   Position=0)][pscredential]$Credentials,#>
        [switch]$trustCert
    )

    Begin
    {
    if ($trustCert.IsPresent)
        {
        Unblock-Certs
        }
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
    }
    Process
    {
   <# if (!$Credentials)
        {
        $User = Read-Host -Prompt "Please Enter ScaleIO MDM username"
        $SecurePassword = Read-Host -Prompt "Enter ScaleIO Password for user $user" -AsSecureString
        $Credentials = New-Object System.Management.Automation.PSCredential (“$user”,$Securepassword)
        }#>
    write-Verbose "Generating Login Token"
    $ENV:OpenHAB_baseurl = "http://$($OpenHAB_IP):$OpenHAB_Port" # :$GatewayPort"
    Write-Verbose $ENV:OpenHAB_baseurl
    try
        {
        $OpenHAB_connected = Invoke-RestMethod -Uri "$ENV:OpenHAB_baseurl/rest" -Method Get -ContentType 'Application/json' -UseBasicParsing  -Verbose #-Credential $Credentials
        }
    catch [System.Net.WebException]
        {
        # Write-Warning $_.Exception.Message
        write $_.Exception.Message
        Break
        }
    catch
        {
        Write-Verbose $_
        Write-Warning $_.Exception.Message
        break
        }
        #>
        Write-Host "Successfully connected to OpenHAB $ENV:OpenHAB_baseurl with api Version $($OpenHAB_connected.version)"
		Write-Host "Overred API Calls: "
		Write-Output $OpenHAB_connected.links
		$ENV:OpenHAB_isconnected = $true
    }
    End
    {
    }


}

Function Invoke-OpenHABREST
{
    [CmdletBinding()]
    [OutputType([int])]
    Param(
	$Method = 'GET',
	$Function,
	$Object_Type
	)

$result = Invoke-RestMethod -Method $Method -UseBasicParsing -Uri "$env:OpenHAB_baseurl/rest/$Function"
if ($result.GetType().fullname -match "system.string")
	{
	}
else
	{
	$result | Add-Member -TypeName $Object_Type
	}

Write-Output $result
}