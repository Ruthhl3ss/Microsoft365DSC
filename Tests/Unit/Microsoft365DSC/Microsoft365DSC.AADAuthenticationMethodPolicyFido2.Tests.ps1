[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
                        -ChildPath '..\..\Unit' `
                        -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
            -ChildPath '\Stubs\Microsoft365.psm1' `
            -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
    -ChildPath '\Stubs\Generic.psm1' `
    -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\UnitTestHelper.psm1' `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "AADAuthenticationMethodPolicyFido2" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString "f@kepassword1" -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@mydomain.com', $secpasswd)

            Mock -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
            }

            Mock -CommandName New-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credentials"
            }

            # Mock Write-Host to hide output during the tests
            Mock -CommandName Write-Host -MockWith {
            }
        }
        # Test contexts
        Context -Name "The AADAuthenticationMethodPolicyFido2 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = [CimInstance[]]@(
                        (New-CimInstance -ClassName MSFT_MicrosoftGraphexcludeTarget2 -Property @{
                            TargetType = "user"
                            Id = "FakeStringValue"
                        } -ClientOnly)
                    )
                    Id = "FakeStringValue"
                    IsAttestationEnforced = $True
                    IsSelfServiceRegistrationAllowed = $True
                    keyRestrictions = (New-CimInstance -ClassName MSFT_MicrosoftGraphfido2KeyRestrictions -Property @{
                        aaGuids = @("FakeStringValue")
                        enforcementType = "allow"
                        isEnforced = $True
                    } -ClientOnly)
                    State = "enabled"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName New-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }

        Context -Name "The AADAuthenticationMethodPolicyFido2 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = [CimInstance[]]@(
                        (New-CimInstance -ClassName MSFT_MicrosoftGraphexcludeTarget2 -Property @{
                            TargetType = "user"
                            Id = "FakeStringValue"
                        } -ClientOnly)
                    )
                    Id = "FakeStringValue"
                    IsAttestationEnforced = $True
                    IsSelfServiceRegistrationAllowed = $True
                    keyRestrictions = (New-CimInstance -ClassName MSFT_MicrosoftGraphfido2KeyRestrictions -Property @{
                        aaGuids = @("FakeStringValue")
                        enforcementType = "allow"
                        isEnforced = $True
                    } -ClientOnly)
                    State = "enabled"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
                    return @{
                        AdditionalProperties = @{
                            isAttestationEnforced = $True
                            '@odata.type' = "#microsoft.graph.fido2AuthenticationMethodConfiguration"
                            isSelfServiceRegistrationAllowed = $True
                            keyRestrictions = @{
                                aaGuids = @("FakeStringValue")
                                enforcementType = "allow"
                                isEnforced = $True
                            }
                        }
                        ExcludeTargets = @(
                            @{
                                TargetType = "user"
                                Id = "FakeStringValue"
                            }
                        )
                        Id = "FakeStringValue"
                        State = "enabled"

                    }
                }
            }

            It 'Should return Values from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Remove-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }
        Context -Name "The AADAuthenticationMethodPolicyFido2 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = [CimInstance[]]@(
                        (New-CimInstance -ClassName MSFT_MicrosoftGraphexcludeTarget2 -Property @{
                            TargetType = "user"
                            Id = "FakeStringValue"
                        } -ClientOnly)
                    )
                    Id = "FakeStringValue"
                    IsAttestationEnforced = $True
                    IsSelfServiceRegistrationAllowed = $True
                    keyRestrictions = (New-CimInstance -ClassName MSFT_MicrosoftGraphfido2KeyRestrictions -Property @{
                        aaGuids = @("FakeStringValue")
                        enforcementType = "allow"
                        isEnforced = $True
                    } -ClientOnly)
                    State = "enabled"
                    Ensure = 'Present'
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
                    return @{
                        AdditionalProperties = @{
                            isAttestationEnforced = $True
                            '@odata.type' = "#microsoft.graph.fido2AuthenticationMethodConfiguration"
                            isSelfServiceRegistrationAllowed = $True
                            keyRestrictions = @{
                                aaGuids = @("FakeStringValue")
                                enforcementType = "allow"
                                isEnforced = $True
                            }
                        }
                        ExcludeTargets = @(
                            @{
                                TargetType = "user"
                                Id = "FakeStringValue"
                            }
                        )
                        Id = "FakeStringValue"
                        State = "enabled"

                    }
                }
            }


            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "The AADAuthenticationMethodPolicyFido2 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = [CimInstance[]]@(
                        (New-CimInstance -ClassName MSFT_MicrosoftGraphexcludeTarget2 -Property @{
                            TargetType = "user"
                            Id = "FakeStringValue"
                        } -ClientOnly)
                    )
                    Id = "FakeStringValue"
                    IsAttestationEnforced = $True
                    IsSelfServiceRegistrationAllowed = $True
                    keyRestrictions = (New-CimInstance -ClassName MSFT_MicrosoftGraphfido2KeyRestrictions -Property @{
                        aaGuids = @("FakeStringValue")
                        enforcementType = "allow"
                        isEnforced = $True
                    } -ClientOnly)
                    State = "enabled"
                    Ensure = 'Present'
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
                    return @{
                        AdditionalProperties = @{
                            '@odata.type' = "#microsoft.graph.fido2AuthenticationMethodConfiguration"
                            keyRestrictions = @{
                                enforcementType = "allow"
                                aaGuids = @("FakeStringValue")
                            }
                        }
                        ExcludeTargets = @(
                            @{
                                TargetType = "user"
                                Id = "FakeStringValue"
                            }
                        )
                        Id = "FakeStringValue"
                        State = "enabled"
                    }
                }
            }

            It 'Should return Values from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should call the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
                    return @{
                        AdditionalProperties = @{
                            isAttestationEnforced = $True
                            '@odata.type' = "#microsoft.graph.fido2AuthenticationMethodConfiguration"
                            isSelfServiceRegistrationAllowed = $True
                            keyRestrictions = @{
                                aaGuids = @("FakeStringValue")
                                enforcementType = "allow"
                                isEnforced = $True
                            }
                        }
                        ExcludeTargets = @(
                            @{
                                TargetType = "user"
                                Id = "FakeStringValue"
                            }
                        )
                        Id = "FakeStringValue"
                        State = "enabled"

                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Export-TargetResource @testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
