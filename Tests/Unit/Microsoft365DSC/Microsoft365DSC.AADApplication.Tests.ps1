[CmdletBinding()]
param(
    [Parameter()]
    [string]
    $CmdletModule = (Join-Path -Path $PSScriptRoot `
            -ChildPath "..\Stubs\Microsoft365.psm1" `
            -Resolve)
)
$GenericStubPath = (Join-Path -Path $PSScriptRoot `
    -ChildPath "..\Stubs\Generic.psm1" `
    -Resolve)
Import-Module -Name (Join-Path -Path $PSScriptRoot `
        -ChildPath "..\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "AADApplication" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        $secpasswd = ConvertTo-SecureString "test@password1" -AsPlainText -Force
        $GlobalAdminAccount = New-Object System.Management.Automation.PSCredential ("tenantadmin", $secpasswd)


        Mock -CommandName Test-MSCloudLogin -MockWith {

        }

        Mock -CommandName Get-PSSession -MockWith {

        }

        Mock -CommandName Remove-PSSession -MockWith {

        }

        Mock -CommandName Set-AzureADApplication -MockWith {

        }

        Mock -CommandName Remove-AzureADApplication -MockWith {

        }

        Mock -CommandName New-AzureADApplication -MockWith {

        }

        Mock -CommandName Get-AzureADApplication -MockWith {
            return @{
                DisplayName                   = "App1"
                AvailableToOtherTenants       = $false
                GroupMembershipClaims         = "0"
                Homepage                      = "https://app.contoso.com"
                IdentifierUris                = "https://app.contoso.com"
                KnownClientApplications       = ""
                LogoutURL                     = "https://app.contoso.com/logout"
                Oauth2AllowImplicitFlow       = $false
                Oauth2AllowUrlPathMatching    = $false
                Oauth2RequirePostResponse     = $false
                PublicClient                  = $false
                ReplyURLs                     = "https://app.contoso.com"
                SamlMetadataUrl               = ""
            }
        }

        # Test contexts
        Context -Name "The application should exist but it does not" -Fixture {
            $testParams = @{
                DisplayName                   = "App1"
                AvailableToOtherTenants       = $false
                GroupMembershipClaims         = "0"
                Homepage                      = "https://app.contoso.com"
                IdentifierUris                = "https://app.contoso.com"
                KnownClientApplications       = ""
                LogoutURL                     = "https://app.contoso.com/logout"
                Oauth2AllowImplicitFlow       = $false
                Oauth2AllowUrlPathMatching    = $false
                Oauth2RequirePostResponse     = $false
                PublicClient                  = $false
                ReplyURLs                     = "https://app.contoso.com"
                SamlMetadataUrl               = ""
                Ensure                        = "Present"
                GlobalAdminAccount            = $GlobalAdmin
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credential"
            }

            Mock -CommandName Get-AzureADApplication -MockWith {
                return $null
            }

            It "Should return values from the get method" {
                (Get-TargetResource @testParams).Ensure | Should be 'Absent'
                Assert-MockCalled -CommandName "Get-AzureADApplication" -Exactly 1
            }
            $Script:calledOnceAlready = $false
            It 'Should return false from the test method' {
                Test-TargetResource @testParams | Should Be $false
            }
            $Script:calledOnceAlready = $false
            It 'Should create the application from the set method' {
                Set-TargetResource @testParams
                Assert-MockCalled -CommandName "New-AzureADApplication" -Exactly 1
            }
        }

        Context -Name "The application exists but it should not" -Fixture {
            $testParams = @{
                DisplayName                   = "App1"
                AvailableToOtherTenants       = $false
                GroupMembershipClaims         = "0"
                Homepage                      = "https://app.contoso.com"
                IdentifierUris                = "https://app.contoso.com"
                KnownClientApplications       = ""
                LogoutURL                     = "https://app.contoso.com/logout"
                Oauth2AllowImplicitFlow       = $false
                Oauth2AllowUrlPathMatching    = $false
                Oauth2RequirePostResponse     = $false
                PublicClient                  = $false
                ReplyURLs                     = "https://app.contoso.com"
                SamlMetadataUrl               = ""
                Ensure                        = "Absent"
                GlobalAdminAccount            = $GlobalAdmin
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credential"
            }

            Mock -CommandName Get-AzureADApplication -MockWith {
                $AADApp = New-Object PSCustomObject
                $AADApp | Add-Member -MemberType NoteProperty -Name DisplayName -Value "App1"
                $AADApp | Add-Member -MemberType NoteProperty -Name ObjectID -Value "5dcb2237-c61b-4258-9c85-eae2aaeba9d6"
                $AADApp | Add-Member -MemberType NoteProperty -Name AvailableToOtherTenants -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name GroupMembershipClaims -Value 0
                $AADApp | Add-Member -MemberType NoteProperty -Name Homepage -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name IdentifierUris -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name KnownClientApplications -Value ""
                $AADApp | Add-Member -MemberType NoteProperty -Name LogoutURL -Value "https://app.contoso.com/logout"
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2AllowImplicitFlow -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2AllowUrlPathMatching -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2RequirePostResponse -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name PublicClient -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name ReplyURLs -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name SamlMetadataUrl -Value ""
                return $AADApp
                
               # $AADApp = @{
               #     DisplayName                   = "App1"
               #     ObjectID                      = "5dcb2237-c61b-4258-9c85-eae2aaeba9d6"
               #     AvailableToOtherTenants       = $false
               #     GroupMembershipClaims         = "0"
               #     Homepage                      = "https://app.contoso.com"
               #     IdentifierUris                = "https://app.contoso.com"
               #     KnownClientApplications       = ""
               #     LogoutURL                     = "https://app.contoso.com/logout"
               #     Oauth2AllowImplicitFlow       = $false
               #     Oauth2AllowUrlPathMatching    = $false
               #     Oauth2RequirePostResponse     = $false
               #     PublicClient                  = $false
               #     ReplyURLs                     = "https://app.contoso.com"
               #     SamlMetadataUrl               = ""
               # }
               # return $AADApp 
            }

            It "Should return values from the get method" {
                (Get-TargetResource @testParams).Ensure | Should be 'Present'
                Assert-MockCalled -CommandName "Get-AzureADApplication" -Exactly 1
            }

            It 'Should return false from the test method' {
                Test-TargetResource @testParams | Should Be $false
            }

            It 'Should remove the app from the set method' {
                Set-TargetResource @testParams
                Assert-MockCalled -CommandName "Remove-AzureADApplication" -Exactly 1
            }
        }
        Context -Name "The app exists and values are already in the desired state" -Fixture {
            $testParams = @{
                DisplayName                   = "App1"
                AvailableToOtherTenants       = $false
                GroupMembershipClaims         = "0"
                Homepage                      = "https://app.contoso.com"
                IdentifierUris                = "https://app.contoso.com"
                KnownClientApplications       = ""
                LogoutURL                     = "https://app.contoso.com/logout"
                Oauth2AllowImplicitFlow       = $false
                Oauth2AllowUrlPathMatching    = $false
                Oauth2RequirePostResponse     = $false
                PublicClient                  = $false
                ReplyURLs                     = "https://app.contoso.com"
                SamlMetadataUrl               = ""
                Ensure                        = "Present"
                GlobalAdminAccount            = $GlobalAdmin
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credential"
            }

            Mock -CommandName Get-AzureADApplication -MockWith {
                $AADApp = New-Object PSCustomObject
                $AADApp | Add-Member -MemberType NoteProperty -Name DisplayName -Value "App1"
                $AADApp | Add-Member -MemberType NoteProperty -Name ObjectID -Value "5dcb2237-c61b-4258-9c85-eae2aaeba9d6"
                $AADApp | Add-Member -MemberType NoteProperty -Name AvailableToOtherTenants -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name GroupMembershipClaims -Value 0
                $AADApp | Add-Member -MemberType NoteProperty -Name Homepage -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name IdentifierUris -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name KnownClientApplications -Value ""
                $AADApp | Add-Member -MemberType NoteProperty -Name LogoutURL -Value "https://app.contoso.com/logout"
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2AllowImplicitFlow -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2AllowUrlPathMatching -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2RequirePostResponse -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name PublicClient -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name ReplyURLs -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name SamlMetadataUrl -Value ""
                return $AADApp
            }

            It "Should return Values from the get method" {
                Get-TargetResource @testParams
                Assert-MockCalled -CommandName "Get-AzureADApplication" -Exactly 1
            }

            It 'Should return true from the test method' {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "Values are not in the desired state" -Fixture {
            $testParams = @{
                DisplayName                   = "App1"
                AvailableToOtherTenants       = $false
                GroupMembershipClaims         = "0"
                Homepage                      = "https://app1.contoso.com" #drift
                IdentifierUris                = "https://app.contoso.com"
                KnownClientApplications       = ""
                LogoutURL                     = "https://app.contoso.com/logout"
                Oauth2AllowImplicitFlow       = $false
                Oauth2AllowUrlPathMatching    = $false
                Oauth2RequirePostResponse     = $false
                PublicClient                  = $false
                ReplyURLs                     = "https://app.contoso.com"
                SamlMetadataUrl               = ""
                Ensure                        = "Present"
                GlobalAdminAccount            = $GlobalAdmin
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credential"
            }

            Mock -CommandName Get-AzureADApplication -MockWith {
                $AADApp = New-Object PSCustomObject
                $AADApp | Add-Member -MemberType NoteProperty -Name DisplayName -Value "App1"
                $AADApp | Add-Member -MemberType NoteProperty -Name ObjectID -Value "5dcb2237-c61b-4258-9c85-eae2aaeba9d6"
                $AADApp | Add-Member -MemberType NoteProperty -Name AvailableToOtherTenants -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name GroupMembershipClaims -Value 0
                $AADApp | Add-Member -MemberType NoteProperty -Name Homepage -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name IdentifierUris -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name KnownClientApplications -Value ""
                $AADApp | Add-Member -MemberType NoteProperty -Name LogoutURL -Value "https://app.contoso.com/logout"
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2AllowImplicitFlow -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2AllowUrlPathMatching -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2RequirePostResponse -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name PublicClient -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name ReplyURLs -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name SamlMetadataUrl -Value ""
                return $AADApp
            }

            It "Should return values from the get method" {
                Get-TargetResource @testParams
                Assert-MockCalled -CommandName "Get-AzureADApplication" -Exactly 1
            }

            It 'Should return false from the test method' {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled -CommandName 'Set-AzureADApplication' -Exactly 1
            }
        }

        Context -Name "ReverseDSC tests" -Fixture {
            $testParams = @{
                GlobalAdminAccount = $GlobalAdminAccount
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credential"
            }

            Mock -CommandName Get-AzureADApplication -MockWith {
                $AADApp = New-Object PSCustomObject
                $AADApp | Add-Member -MemberType NoteProperty -Name DisplayName -Value "App1"
                $AADApp | Add-Member -MemberType NoteProperty -Name ObjectID -Value "5dcb2237-c61b-4258-9c85-eae2aaeba9d6"
                $AADApp | Add-Member -MemberType NoteProperty -Name AvailableToOtherTenants -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name GroupMembershipClaims -Value 0
                $AADApp | Add-Member -MemberType NoteProperty -Name Homepage -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name IdentifierUris -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name KnownClientApplications -Value ""
                $AADApp | Add-Member -MemberType NoteProperty -Name LogoutURL -Value "https://app.contoso.com/logout"
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2AllowImplicitFlow -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2AllowUrlPathMatching -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name Oauth2RequirePostResponse -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name PublicClient -Value $false
                $AADApp | Add-Member -MemberType NoteProperty -Name ReplyURLs -Value "https://app.contoso.com"
                $AADApp | Add-Member -MemberType NoteProperty -Name SamlMetadataUrl -Value ""
                return $AADApp
            }

            It "Should reverse engineer resource from the export method" {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
