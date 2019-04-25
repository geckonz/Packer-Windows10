$packerWindowsDir = 'C:\Windows\packer'
New-Item -Path $packerWindowsDir -ItemType Directory -Force

# final shutdown command
$shutdownCmd = @"
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new action=block
ECHO "Starting Sysprep..."
C:\windows\system32\sysprep\sysprep.exe /generalize /oobe /unattend:C:\Windows\packer\unattended.xml /quiet /shutdown
ECHO "Sysprep complete."
"@

# unattend XML to run on first boot after sysprep
$unattendedXML = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>0409:00000409</InputLocale>
            <SystemLocale>en-NZ</SystemLocale>
            <UILanguage>en-NZ</UILanguage>
            <UILanguageFallback>en-US</UILanguageFallback>
            <UserLocale>en-NZ</UserLocale>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <OOBE>
                <VMModeOptimizations>
                    <SkipAdministratorProfileRemoval>true</SkipAdministratorProfileRemoval>
                </VMModeOptimizations>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <ProtectYourPC>1</ProtectYourPC>
                <UnattendEnableRetailDemo>false</UnattendEnableRetailDemo>
            </OOBE>
            <UserAccounts>
              <AdministratorPassword>
                  <Value>ChangeMePleas3!</Value>
                  <PlainText>true</PlainText>
              </AdministratorPassword>
            </UserAccounts>
            <TimeZone>New Zealand Standard Time</TimeZone>
            <RegisteredOrganization>Clever Buggers Inc.</RegisteredOrganization>
            <RegisteredOwner>Builder</RegisteredOwner>
            <ShowPowerButtonOnStartScreen>true</ShowPowerButtonOnStartScreen>
            <AutoLogon>
                <Password>
                    <Value>ChangeMePleas3!</Value>
                    <PlainText>true</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <Username>Administrator</Username>
            </AutoLogon>
        </component>
    </settings>
    <cpi:offlineImage cpi:source="wim://win-3ggv6lglt8v/public/software/windows10/sources/install.wim#Windows 10 Enterprise Evaluation" xmlns:cpi="urn:schemas-microsoft-com:cpi" />
</unattend>
"@

Set-Content -Path "$($packerWindowsDir)\PackerShutdown.bat" -Value $shutdownCmd
Set-Content -Path "$($packerWindowsDir)\unattended.xml" -Value $unattendedXML

# will run on first boot
# https://technet.microsoft.com/en-us/library/cc766314(v=ws.10).aspx
$setupComplete = @"
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new action=allow
"@

New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force
Set-Content -path "C:\Windows\Setup\Scripts\SetupComplete.cmd" -Value $setupComplete
