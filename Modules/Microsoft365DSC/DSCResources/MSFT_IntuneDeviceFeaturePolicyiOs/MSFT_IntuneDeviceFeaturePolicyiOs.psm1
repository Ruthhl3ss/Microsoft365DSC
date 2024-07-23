function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $lockScreenFootnote,

        [Parameter()]
        [System.Int32]
        $homeScreenGridWidth,

        [Parameter()]
        [System.Int32]
        $homeScreenGridHeight,

        [Parameter()]
        [System.String]
        $wallpaperDisplayLocation,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $airPrintDestinations,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $contentFilterSettings,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $homeScreenDockIcons,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $homeScreenPages,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $notificationSettings,

        [Parameter()]
        [System.String]
        $wallpaperImage,

        [Parameter()]
        [System.String]
        $iosSingleSignOnExtension,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    try {
        $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
            -InboundParameters $PSBoundParameters
    }
    catch {
        Write-Verbose -Message 'Connection to the workload failed.'
    }

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $nullResult = $PSBoundParameters
    $nullResult.Ensure = 'Absent'
    try {
        $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $id -ErrorAction SilentlyContinue

        #region resource generator code
        if ($null -eq $getValue) {
            $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -Filter "DisplayName eq '$Displayname'" -ErrorAction SilentlyContinue | Where-Object `
                -FilterScript { `
                    $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.iosDeviceFeaturesConfiguration' `
            }
        }
        #endregion

        if ($null -eq $getValue) {
            Write-Verbose -Message "Nothing with id {$id} was found"
            return $nullResult
        }

        
        #AirPrintDestinationsComplexSettings
        $airPrintDestinationscomplex = @{}
        $airPrintDestinationscomplex.Add('ipAddress', $getValue.AdditionalProperties.airPrintDestinations.ipAddress)
        $airPrintDestinationscomplex.Add('resourcePath', $getValue.AdditionalProperties.airPrintDestinations.resourcePath)
        $airPrintDestinationscomplex.Add('forceTls', $getValue.AdditionalProperties.airPrintDestinations.forceTls)
        
        #ContentFilterSettingsComplexSettings
        $contentFilterSettingscomplex = @{}
        if ($null -ne $getValue.AdditionalProperties.contentFilterSettings.'@odata.type') {
            $contentFilterSettingscomplex.Add('odata.type', $getValue.AdditionalProperties.contentFilterSettings.'@odata.type'.toString())
        }
        $contentFilterSettingscomplex.Add('allowedUrls', $getValue.AdditionalProperties.contentFilterSettings.allowedUrls)
        $contentFilterSettingscomplex.Add('blockedUrls', $getValue.AdditionalProperties.contentFilterSettings.blockedUrls)

        #HomeScreenDockIconsComplexSettings
        $homeScreenDockIconscomplex = @()

        $Index = 0
                
        foreach ($object in $getValue.AdditionalProperties.homeScreenDockIcons) {
            Write-Verbose "Using index $Index"

            $PerSettingHomeScreenDockIcons = @{}


            $odatatype = $getValue.AdditionalProperties.homeScreenDockIcons.'@odata.type'| Select-Object -Index $Index
            $PerSettingHomeScreenDockIcons.Add('@odata.type', $odatatype)
            $DisplayName = $getValue.AdditionalProperties.homeScreenDockIcons.displayName | Select-Object -Index $Index
            $PerSettingHomeScreenDockIcons.Add('displayName', $DisplayName)
            $BundleID = $getValue.AdditionalProperties.homeScreenDockIcons.bundleID | Select-Object -Index $Index
            $PerSettingHomeScreenDockIcons.Add('bundleID', $BundleID)
            $IsWebClip = $getValue.AdditionalProperties.homeScreenDockIcons.isWebClip | Select-Object -Index $Index
            $PerSettingHomeScreenDockIcons.Add('isWebClip', $IsWebClip)

            $homeScreenDockIconscomplex += $PerSettingHomeScreenDockIcons

            $Index++

        }
        <#
        #HomeScreenPagesComplexSettings
        $homeScreenPagescomplex = @(
            Displayname = $null   
            icons = @()
            
        )
        $Index = 0
        foreach ($object in $getValue.AdditionalProperties.homeScreenPages.icons) {
            Write-Verbose "Using index $Index"

            $PerSettingHomeScreenPages = @{}

            $odatatype = $getValue.AdditionalProperties.homeScreenPages.icons.'@odata.type'| Select-Object -Index $Index
            $PerSettingHomeScreenPages.Add('@odata.type', $odatatype)
            $DisplayName = $getValue.AdditionalProperties.homeScreenPages.icons.displayName | Select-Object -Index $Index
            $PerSettingHomeScreenPages.Add('displayName', $DisplayName)
            $BundleID = $getValue.AdditionalProperties.homeScreenPages.icons.bundleID | Select-Object -Index $Index
            $PerSettingHomeScreenPages.Add('bundleID', $BundleID)
            $IsWebClip = $getValue.AdditionalProperties.homeScreenPages.icons.isWebClip | Select-Object -Index $Index
            $PerSettingHomeScreenPages.Add('isWebClip', $IsWebClip)

            $homeScreenPagescomplex += $PerSettingHomeScreenPages

            $Index++
        }
        #>

        $notificationSettingscomplex = @{}
        $Index = 0
        foreach ($object in $getValue.AdditionalProperties.notificationSettings) {
            Write-Verbose "Using index $Index"

            $PerSettingNotificationSettings = @{}

            $BundleID = $getValue.AdditionalProperties.notificationSettings.bundleID | Select-Object -Index $Index
            $PerSettingNotificationSettings.Add('bundleID', $BundleID)
            $appName = $getValue.AdditionalProperties.notificationSettings.appName | Select-Object -Index $Index
            $PerSettingNotificationSettings.Add('appName', $appName)
            $publisher = $getValue.AdditionalProperties.notificationSettings.publisher | Select-Object -Index $Index
            $PerSettingNotificationSettings.Add('publisher', $publisher)
            $enabled = $getValue.AdditionalProperties.notificationSettings.enabled | Select-Object -Index $Index
            $PerSettingNotificationSettings.Add('enabled', $enabled)

            $showInNotificationCenter = $getValue.AdditionalProperties.notificationSettings.showInNotificationCenter | Select-Object -Index $Index -ErrorAction SilentlyContinue
            If ($showInNotificationCenter -ne $null) {
                $PerSettingNotificationSettings.Add('showInNotificationCenter', $showInNotificationCenter)
            }
            $showOnLockScreen = $getValue.AdditionalProperties.notificationSettings.showOnLockScreen | Select-Object -Index $Index -ErrorAction SilentlyContinue
            If ($showOnLockScreen -ne $null) {
                $PerSettingNotificationSettings.Add('showOnLockScreen', $showOnLockScreen)
            } 
            $alertType = $getValue.AdditionalProperties.notificationSettings.alertType | Select-Object -Index $Index -ErrorAction SilentlyContinue
            If ($alertType -ne $null) {
                $PerSettingNotificationSettings.Add('alertType', $alertType)
            }
            $badgesEnabled = $getValue.AdditionalProperties.notificationSettings.badgesEnabled | Select-Object -Index $Index -ErrorAction SilentlyContinue
            if ($badgesEnabled -ne $null) {
                $PerSettingNotificationSettings.Add('badgesEnabled', $badgesEnabled)
            }
            $soundsEnabled = $getValue.AdditionalProperties.notificationSettings.soundsEnabled | Select-Object -Index $Index -ErrorAction SilentlyContinue
            if ($soundsEnabled -ne $null) {
                $PerSettingNotificationSettings.Add('soundsEnabled', $soundsEnabled)
            }
            $previewVisibility = $getValue.AdditionalProperties.notificationSettings.previewVisibility | Select-Object -Index $Index -ErrorAction SilentlyContinue
            if ($previewVisibility -ne $null) {
                $PerSettingNotificationSettings.Add('previewVisibility', $previewVisibility)
            }

            $notificationSettingscomplex += $PerSettingNotificationSettings

            $Index++

        }



        Write-Verbose -Message "Found something with id {$id}"
        $results = @{
            Id                       = $getValue.id
            DisplayName              = $getValue.DisplayName
            Description              = $getValue.Description
            lockScreenFootnote       = $getValue.AdditionalProperties.lockScreenFootnote
            homeScreenGridWidth      = $getValue.AdditionalProperties.homeScreenGridWidth
            homeScreenGridHeight     = $getValue.AdditionalProperties.homeScreenGridHeight
            wallpaperDisplayLocation = $getValue.AdditionalProperties.wallpaperDisplayLocation
            airPrintDestinations     = $airPrintDestinationscomplex
            contentFilterSettings    = $contentFilterSettingscomplex
            homeScreenDockIcons      = $homeScreenDockIconscomplex
            homeScreenPages          = $homeScreenPagescomplex
            notificationSettings     = $notificationSettingscomplex
            wallpaperImage           = $getValue.AdditionalProperties.wallpaperImage
            iosSingleSignOnExtension = $getValue.AdditionalProperties.iosSingleSignOnExtension
            Ensure                   = 'Present'
            Credential               = $Credential
            ApplicationId            = $ApplicationId
            TenantId                 = $TenantId
            ApplicationSecret        = $ApplicationSecret
            CertificateThumbprint    = $CertificateThumbprint
            Managedidentity          = $ManagedIdentity.IsPresent
            AccessTokens             = $AccessTokens
        }

        $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $getValue.Id
        $assignmentResult = @()
        if ($assignmentsValues.Count -gt 0) {
            $assignmentResult += ConvertFrom-IntunePolicyAssignment `
                -IncludeDeviceFilter:$true `
                -Assignments ($assignmentsValues)
        }
        $results.Add('Assignments', $assignmentResult)

        return [System.Collections.Hashtable] $results
    }
    catch {
        New-M365DSCLogEntry -Message 'Error retrieving data:' `
            -Exception $_ `
            -Source $($MyInvocation.MyCommand.Source) `
            -TenantId $TenantId `
            -Credential $Credential

        return $nullResult
    }
}

function Set-TargetResource {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $lockScreenFootnote,

        [Parameter()]
        [System.Int32]
        $homeScreenGridWidth,

        [Parameter()]
        [System.Int32]
        $homeScreenGridHeight,

        [Parameter()]
        [System.String]
        $wallpaperDisplayLocation,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $airPrintDestinations,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $contentFilterSettings,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $homeScreenDockIcons,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $homeScreenPages,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $notificationSettings,

        [Parameter()]
        [System.String]
        $wallpaperImage,

        [Parameter()]
        [System.String]
        $iosSingleSignOnExtension,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    Write-Verbose -Message "Intune Device Compliance iOS Policy {$DisplayName}"

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $PSBoundParameters

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName -replace 'MSFT_', ''
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $currentDeviceiOsPolicy = Get-TargetResource @PSBoundParameters

    $PSBoundParameters.Remove('Ensure') | Out-Null
    $PSBoundParameters.Remove('Credential') | Out-Null
    $PSBoundParameters.Remove('ApplicationId') | Out-Null
    $PSBoundParameters.Remove('ApplicationSecret') | Out-Null
    $PSBoundParameters.Remove('TenantId') | Out-Null
    $PSBoundParameters.Remove('CertificateThumbprint') | Out-Null
    $PSBoundParameters.Remove('ManagedIdentity') | Out-Null
    $PSBoundParameters.Remove('AccessTokens') | Out-Null


    if ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent') {
        Write-Verbose -Message "Creating {$DisplayName}"
        $PSBoundParameters.Remove('Assignments') | Out-Null

        $CreateParameters = ([Hashtable]$PSBoundParameters).clone()
        $CreateParameters = Rename-M365DSCCimInstanceParameter -Properties $CreateParameters

        $AdditionalProperties = Get-M365DSCAdditionalProperties -Properties ($CreateParameters)
        foreach ($key in $AdditionalProperties.keys) {
            if ($key -ne '@odata.type') {
                $keyName = $key.substring(0, 1).ToUpper() + $key.substring(1, $key.length - 1)
                $CreateParameters.remove($keyName)
            }
        }

        $CreateParameters.Remove('Id') | Out-Null
        $CreateParameters.Remove('Verbose') | Out-Null

        foreach ($key in ($CreateParameters.clone()).Keys) {
            if ($CreateParameters[$key].getType().Fullname -like '*CimInstance*') {
                $CreateParameters[$key] = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $CreateParameters[$key]
            }
        }

        if ($AdditionalProperties) {
            $CreateParameters.add('AdditionalProperties', $AdditionalProperties)
        }

        #region resource generator code
        $policy = New-MgBetaDeviceManagementDeviceConfiguration @CreateParameters
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments

        if ($policy.id) {
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
        }
        #endregion
    }
    elseif ($Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present') {
        Write-Verbose -Message "Updating {$DisplayName}"
        $PSBoundParameters.Remove('Assignments') | Out-Null

        $UpdateParameters = ([Hashtable]$PSBoundParameters).clone()
        $UpdateParameters = Rename-M365DSCCimInstanceParameter -Properties $UpdateParameters

        $AdditionalProperties = Get-M365DSCAdditionalProperties -Properties ($UpdateParameters)
        foreach ($key in $AdditionalProperties.keys) {
            if ($key -ne '@odata.type') {
                $keyName = $key.substring(0, 1).ToUpper() + $key.substring(1, $key.length - 1)
                $UpdateParameters.remove($keyName)
            }
        }

        $UpdateParameters.Remove('Id') | Out-Null
        $UpdateParameters.Remove('Verbose') | Out-Null

        foreach ($key in ($UpdateParameters.clone()).Keys) {
            if ($UpdateParameters[$key].getType().Fullname -like '*CimInstance*') {
                $UpdateParameters[$key] = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $UpdateParameters[$key]
            }
        }

        if ($AdditionalProperties) {
            $UpdateParameters.add('AdditionalProperties', $AdditionalProperties)
        }

        #region resource generator code
        Update-MgBetaDeviceManagementDeviceConfiguration @UpdateParameters `
            -DeviceConfigurationId $currentInstance.Id
        $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $Assignments
        Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.id `
            -Targets $assignmentsHash `
            -Repository 'deviceManagement/deviceConfigurations'
        #endregion
    }
    elseif ($Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present') {
        Write-Verbose -Message "Removing {$DisplayName}"
        #region resource generator code
        Remove-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $currentInstance.Id
        #endregion
    }
}

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $lockScreenFootnote,

        [Parameter()]
        [System.Int32]
        $homeScreenGridWidth,

        [Parameter()]
        [System.Int32]
        $homeScreenGridHeight,

        [Parameter()]
        [System.String]
        $wallpaperDisplayLocation,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $airPrintDestinations,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $contentFilterSettings,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $homeScreenDockIcons,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $homeScreenPages,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance]
        $notificationSettings,

        [Parameter()]
        [System.String]
        $wallpaperImage,

        [Parameter()]
        [System.String]
        $iosSingleSignOnExtension,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Assignments,

        [Parameter()]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )


    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    Write-Verbose -Message "Testing configuration of {$id}"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = ([Hashtable]$PSBoundParameters).clone()

    if ($CurrentValues.Ensure -ne $Ensure) {
        Write-Verbose -Message "Test-TargetResource returned $false"
        return $false
    }
    $testResult = $true

    foreach ($key in $PSBoundParameters.Keys) {
        if ($PSBoundParameters[$key].getType().Name -like '*CimInstance*') {
            $CIMArraySource = @()
            $CIMArrayTarget = @()
            $CIMArraySource += $PSBoundParameters[$key]
            $CIMArrayTarget += $CurrentValues.$key
            if ($CIMArraySource.count -ne $CIMArrayTarget.count) {
                Write-Verbose -Message "Configuration drift:Number of items does not match: Source=$($CIMArraySource.count) Target=$($CIMArrayTarget.count)"
                $testResult = $false
                break
            }
            $i = 0
            foreach ($item in $CIMArraySource ) {
                $testResult = Compare-M365DSCComplexObject `
                    -Source (Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $CIMArraySource[$i]) `
                    -Target ($CIMArrayTarget[$i])

                $i++
                if (-Not $testResult) {
                    $testResult = $false
                    break
                }
            }
            if (-Not $testResult) {
                $testResult = $false
                break
            }

            $ValuesToCheck.Remove($key) | Out-Null
        }
    }
    $ValuesToCheck.Remove('Id') | Out-Null

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $ValuesToCheck)"

    #Convert any DateTime to String
    foreach ($key in $ValuesToCheck.Keys) {
        if (($null -ne $CurrentValues[$key]) `
                -and ($CurrentValues[$key].getType().Name -eq 'DateTime')) {
            $CurrentValues[$key] = $CurrentValues[$key].toString()
        }
    }

    if ($testResult) {
        $testResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
            -Source $($MyInvocation.MyCommand.Source) `
            -DesiredValues $PSBoundParameters `
            -ValuesToCheck $ValuesToCheck.Keys
    }

    Write-Verbose -Message "Test-TargetResource returned $testResult"

    return $testResult
}

function Export-TargetResource {
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.String]
        $Filter,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [Switch]
        $ManagedIdentity,

        [Parameter()]
        [System.String[]]
        $AccessTokens
    )

    $ConnectionMode = New-M365DSCConnection -Workload 'MicrosoftGraph' `
        -InboundParameters $PSBoundParameters

    #Ensure the proper dependencies are installed in the current environment.
    Confirm-M365DSCDependencies

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace('MSFT_', '')
    $CommandName = $MyInvocation.MyCommand
    $data = Format-M365DSCTelemetryParameters -ResourceName $ResourceName `
        -CommandName $CommandName `
        -Parameters $PSBoundParameters
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    try {

        #region resource generator code
        [array]$getValue = Get-MgBetaDeviceManagementDeviceConfiguration -Filter $Filter -All `
            -ErrorAction Stop | Where-Object `
            -FilterScript { `
                $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.iosDeviceFeaturesConfiguration'  `
        }
        #endregion

        $i = 1
        $dscContent = ''
        if ($getValue.Length -eq 0) {
            Write-Host $Global:M365DSCEmojiGreenCheckMark
        }
        else {
            Write-Host "`r`n" -NoNewline
        }
        foreach ($config in $getValue) {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount) {
                $Global:M365DSCExportResourceInstancesCount++
            }

            Write-Host "    |---[$i/$($getValue.Count)] $($config.DisplayName)" -NoNewline
            $params = @{
                Id                    = $config.id
                DisplayName           = $config.DisplayName
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
                Managedidentity       = $ManagedIdentity.IsPresent
                AccessTokens          = $AccessTokens
            }

            $Results = Get-TargetResource @Params
            $Results = Update-M365DSCExportAuthenticationResults -ConnectionMode $ConnectionMode `
                -Results $Results

            if ($Results.Assignments) {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                if ($complexTypeStringResult) {
                    $Results.Assignments = $complexTypeStringResult
                }
                else {
                    $Results.Remove('Assignments') | Out-Null
                }
            }

            If ($Results.airPrintDestinations) {
                Write-Verbose -Message "Using Get-M365DSCDRGComplexTypeToString for airPrintDestinations"
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.airPrintDestinations) -CIMInstanceName AirPrintDestination
                if ($complexTypeStringResult) {
                    Write-Verbose -Message "Setting airPrintDestinations to $complexTypeStringResult"
                    $Results.airPrintDestinations = $complexTypeStringResult
                }
                else {
                    Write-Verbose -Message "Setting airPrintDestinations to $null"
                    $Results.Remove('airPrintDestinations') | Out-Null
                }
            }

            If ($Results.contentFilterSettings) {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.contentFilterSettings -CIMInstanceName ContentFilterSettings
                if ($complexTypeStringResult) {
                    $Results.contentFilterSettings = $complexTypeStringResult
                }
                else {
                    $Results.Remove('contentFilterSettings') | Out-Null
                }
            }

            if ($Results.homeScreenDockIcons) {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.homeScreenDockIcons -CIMInstanceName HomeScreenDockIcons
                if ($complexTypeStringResult) {
                    $Results.homeScreenDockIcons = $complexTypeStringResult
                }
                else {
                    $Results.Remove('homeScreenDockIcons') | Out-Null
                }
            }

            If ($Results.homeScreenPages){
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.homeScreenPages.icons -CIMInstanceName HomeScreenPages
                if ($complexTypeStringResult) {
                    $Results.homeScreenPages.icons = $complexTypeStringResult
                }
                else {
                    $Results.Remove('homeScreenPages') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential

            if ($Results.Assignments) {
                $isCIMArray = $false
                if ($Results.Assignments.getType().Fullname -like '*[[\]]') {
                    $isCIMArray = $true
                }
                $currentDSCBlock = Convert-DSCStringParamToVariable -DSCBlock $currentDSCBlock -ParameterName 'Assignments' -IsCIMArray:$isCIMArray
            }

            $dscContent += $currentDSCBlock
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            $i++
            Write-Host $Global:M365DSCEmojiGreenCheckMark
        }
        return $dscContent
    }
    catch {
        if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                $_.Exception -like "*Request not applicable to target tenant*") {
            Write-Host "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
        }
        else {
            Write-Host $Global:M365DSCEmojiRedX

            New-M365DSCLogEntry -Message 'Error during Export:' `
                -Exception $_ `
                -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $TenantId `
                -Credential $Credential
        }

        return ''
    }
}
function Get-M365DSCAdditionalProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = 'true')]
        [System.Collections.Hashtable]
        $Properties
    )

    $additionalProperties = @(
        'lockScreenFootnote'
        'homeScreenGridWidth'
        'homeScreenGridHeight'
        'wallpaperDisplayLocation'
        'airPrintDestinations'
        'contentFilterSettings'
        'homeScreenDockIcons'
        'homeScreenPages'
        'notificationSettings'
        'wallpaperImage'
        'iosSingleSignOnExtension'

    )

    $results = @{'@odata.type' = '#microsoft.graph.iosDeviceFeaturesConfiguration' }
    $cloneProperties = $Properties.clone()
    foreach ($property in $cloneProperties.Keys) {
        if ($property -in ($additionalProperties) ) {
            $propertyName = $property[0].ToString().ToLower() + $property.Substring(1, $property.Length - 1)
            if ($properties.$property -and $properties.$property.getType().FullName -like '*CIMInstance*') {
                if ($properties.$property.getType().FullName -like '*[[\]]') {
                    $array = @()
                    foreach ($item in $properties.$property) {
                        $array += Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $item
                    }
                    $propertyValue = $array
                }
                else {
                    $propertyValue = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $properties.$property
                }

            }
            else {
                $propertyValue = $properties.$property
            }

            $results.Add($propertyName, $propertyValue)
        }
    }
    if ($results.Count -eq 1) {
        return $null
    }
    return $results
}

Export-ModuleMember -Function *-TargetResource