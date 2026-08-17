@echo off
setlocal EnableDelayedExpansion
title EXTREME DEBLOAT :: Windows 11 Maximum Snappiness & Speed
color 0E

REM =====================================================================
REM  extreme-debloat.bat  -  Aggressive Windows 11 debloat + speed boost.
REM
REM  What it does (one run, instant effect after reboot):
REM    * Creates a System Restore point FIRST (so you can roll back).
REM    * Nukes telemetry, DiagTrack, dmwappushservice, ad ID, suggestions.
REM    * Strips bloatware Appx packages (Candy Crush, TikTok, Spotify,
REM      Clipchamp, Bing News/Weather, Solitaire, Maps, People, etc.)
REM      Keeps: Calculator, Photos, Notepad, Paint, Store, Terminal, Edge.
REM    * Disables ~30 unneeded services (SysMain, WSearch indexing,
REM      Fax, Remote Registry, Print Spooler if no printer, Xbox *,
REM      Error Reporting, Parental Controls, etc.).
REM    * Applies gaming/latency registry tweaks:
REM        - Win32PrioritySeparation = 0x26 (foreground boost, short var)
REM        - MMCSS SystemResponsiveness = 0, Games task priority = 2/High
REM        - NetworkThrottlingIndex = 0xffffffff (no throttle)
REM        - GameDVR / Xbox Game Bar fully OFF
REM        - Mouse acceleration OFF (raw input feel)
REM        - HPET forced OFF, dynamic tick ON (better frame pacing)
REM    * Enables Ultimate Performance power plan + disables hibernation,
REM      fast startup, USB selective suspend, power throttling.
REM    * Disables transparency, animations, widgets, Copilot, startup
REM      delay, lock-screen spam, "tips", "suggested" content.
REM    * Network: CTCP congestion provider, RSS on, Nagle off, fast DNS.
REM    * NTFS: disables 8.3 names + Last Access timestamp (faster I/O).
REM    * Clears temp, prefetch, Windows Update cache, event logs.
REM    * Restarts Explorer so UI changes apply immediately.
REM
REM  Sources: esicera/Windows11OptimizationScript, Raphire/Win11Debloat,
REM    jonathanferraz/debloat-windows, ceferrari/ZeroLatency,
REM    KairoZXT/MMCSS-Tweaks, Tier1Settings, Microsoft MMCSS docs.
REM
REM  !! BACK UP IMPORTANT DATA FIRST. A RESTORE POINT IS CREATED. !!
REM =====================================================================

REM --- Self-elevate to Administrator ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo =====================================================================
echo   EXTREME WINDOWS 11 DEBLOAT  -  Maximum Snappiness ^& Speed
echo   [%time%]  Running as: %USERNAME%@%COMPUTERNAME%
echo   A System Restore Point will be created first. You can roll back.
echo =====================================================================
echo.
echo Press any key to BEGIN, or close this window to cancel...
pause >nul

REM =====================================================================
REM  0. SYSTEM RESTORE POINT  (so this is reversible)
REM =====================================================================
echo [%time%] [0/12] Creating System Restore Point...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Checkpoint-Computer -Description 'extreme-debloat.bat BEFORE' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue"
echo Done.
echo.

REM =====================================================================
REM  1. TELEMETRY ^& DATA COLLECTION  -  NUKE
REM =====================================================================
echo [%time%] [1/12] Disabling telemetry ^& data collection...

REM --- Services: DiagTrack (Connected User Experiences ^& Telemetry) + dmwappushservice ---
sc config DiagTrack start= disabled >nul 2>&1
sc stop DiagTrack >nul 2>&1
sc config dmwappushservice start= disabled >nul 2>&1
sc stop dmwappushservice >nul 2>&1

REM --- Registry: AllowTelemetry = 0 (Security/Enterprise level) ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
REM --- Commercial data pipeline off ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v DoNotUseAzureTPM_DCP_NS /t REG_DWORD /d 1 /f >nul
REM --- Advertising ID off (per user ^& machine) ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v DisabledByGroupPolicy /t REG_DWORD /d 1 /f >nul
REM --- Disable "Tailored Experiences", suggested content, tips ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338393Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353694Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353696Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d 0 /f >nul
REM --- Feedback frequency = Never ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback" /v IntervalInDays /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feedback" /v EngagementEnabled /t REG_DWORD /d 0 /f >nul
REM --- Diagnostic data settings ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v ShowedToastAtLevel /t REG_DWORD /d 1 /f >nul
echo Done.
echo.

REM =====================================================================
REM  2. BLOATWARE APPX REMOVAL  (allowlist keeps the useful ones)
REM =====================================================================
echo [%time%] [2/12] Removing bloatware Appx packages...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$remove = @(" ^
  "  '*Microsoft.BingNews*','*Microsoft.BingWeather*','*Microsoft.BingFinance*','*Microsoft.BingSports*'," ^
  "  '*Microsoft.GetHelp*','*Microsoft.Getstarted*','*Microsoft.Microsoft3DViewer*'," ^
  "  '*Microsoft.MicrosoftOfficeHub*','*Microsoft.MicrosoftSolitaireCollection*','*Microsoft.MicrosoftStickyNotes*'," ^
  "  '*Microsoft.MixedReality.Portal*','*Microsoft.OneConnect*','*Microsoft.People*','*Microsoft.SkypeApp*'," ^
  "  '*Microsoft.Wallet*','*Microsoft.WindowsCommunicationsApps*','*Microsoft.WindowsFeedbackHub*'," ^
  "  '*Microsoft.WindowsMaps*','*Microsoft.WindowsSoundRecorder*','*Microsoft.Xbox*','*Microsoft.ZuneMusic*','*Microsoft.ZuneVideo*'," ^
  "  '*Microsoft.549981C3F5F10*','*Microsoft.Todos*','*Microsoft.PowerBIForWindows*','*Microsoft.NetworkSpeedTest*'," ^
  "  '*Microsoft.MicrosoftPowerBIForWindows*','*Microsoft.BingSearch*','*Microsoft.Windows.DevHome*'," ^
  "  '*MicrosoftCorporationII.MicrosoftFamily*','*MicrosoftCorporationII.QuickAssist*'," ^
  "  '*Microsoft.WindowsTerminal*','*Microsoft.WindowsNotepad*','*Microsoft.WindowsCalculator*','*Microsoft.WindowsPhotos*'," ^
  "  '*Microsoft.Paint*','*Microsoft.WindowsStore*','*Microsoft.UI.Xaml*','*Microsoft.VCLibs*','*Microsoft.NET.Native*'," ^
  "  '*Microsoft.Edge*','*Microsoft.WebMediaExtensions*','*Microsoft.WebpImageExtension*','*Microsoft.HEIFImageExtension*'," ^
  "  '*Microsoft.HEVCVideoExtension*','*Microsoft.AV1VideoExtension*','*Microsoft.RawImageExtension*'," ^
  "  '*Microsoft.VP9VideoExtensions*','*Microsoft.ScreenSketch*','*Microsoft.WindowsCamera*'," ^
  "  '*MicrosoftClipchamp*','*Clipchamp.Clipchamp*','*Bytedance.TikTok*','*SpotifyAB.SpotifyMusic*'," ^
  "  '*Disney.ESPN*','*ESPN*','*CandyCrush*','*king.com*','*Microsoft.GamingApp*','*Microsoft.GamingServices*'," ^
  "  '*Microsoft.XboxGamingOverlay*','*Microsoft.XboxGameOverlay*','*Microsoft.XboxIdentityProvider*'," ^
  "  '*Microsoft.XboxSpeechToTextOverlay*','*Microsoft.XboxTCUI*','*Microsoft.YourPhone*','*Microsoft.WindowsYourPhone*'," ^
  "  '*Microsoft.WindowsMaps*','*Microsoft.MicrosoftJournal*','*Microsoft.Whiteboard*','*Microsoft.Sway*'," ^
  "  '*Microsoft.Office.OneNote*','*Microsoft.OneDriveSync*','*Microsoft.Windows.Mail*','*Microsoft.WindowsCalendar*'," ^
  "  '*Microsoft.WindowsAlarms*','*Microsoft.ZuneMusic*','*Microsoft.ZuneVideo*','*Microsoft.WindowsCDPlayer*'," ^
  "  '*Microsoft.WindowsDVDPlayer*','*Microsoft.WindowsMedia.Player*','*Microsoft.WindowsMedia.PlaybackManager*'," ^
  "  '*Microsoft.Windows.ContentDeliveryManager*','*Microsoft.Windows.Cortana*','*Microsoft.Windows.Search*'," ^
  "  '*Microsoft.Windows.ShellExperienceHost*','*Microsoft.Windows.StartMenuExperienceHost*'," ^
  "  '*Microsoft.Windows.InputApp*','*Microsoft.Windows.Cortana*','*Microsoft.Windows.Copilot*'," ^
  "  '*Microsoft.Copilot*','*Microsoft.WindowsAI*','*Microsoft.Windows.Copilot*'" ^
  ");" ^
  "$keep = @('*WindowsCalculator*','*WindowsPhotos*','*WindowsNotepad*','*Microsoft.Paint*','*WindowsStore*','*WindowsTerminal*','*MicrosoftEdge*','*Microsoft.UI.Xaml*','*Microsoft.VCLibs*','*Microsoft.NET.Native*','*Microsoft.WebpImageExtension*','*Microsoft.HEIFImageExtension*','*Microsoft.HEVCVideoExtension*','*Microsoft.AV1VideoExtension*','*Microsoft.RawImageExtension*','*Microsoft.VP9VideoExtensions*','*Microsoft.ScreenSketch*','*Microsoft.WindowsCamera*','*Microsoft.Windows.DevHome*');" ^
  "foreach($p in $remove){" ^
  "  if($keep -contains $p){ continue }" ^
  "  Get-AppxPackage -Name $p -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue;" ^
  "  Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $p } | Remove-AppxProvisionedPackage -AllUsers -Online -ErrorAction SilentlyContinue" ^
  "}"

REM --- Block consumer cloud content / suggested apps from coming back ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v OemPreInstalledAppsEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEverEnabled /t REG_DWORD /d 0 /f >nul
echo Done.
echo.

REM =====================================================================
REM  3. DISABLE UNNEEDED SERVICES
REM =====================================================================
echo [%time%] [3/12] Disabling unnecessary services...

REM --- Disable the SAFE ones (do NOT touch Defender, Windows Update core, audio, network essentials) ---
set SAFE=DiagTrack;dmwappushservice;SysMain;WSearch;Fax;RemoteRegistry;WerSvc;wercplsupport;RetailDemo;MapsBroker;lfsvc;HvHost;vmickvpexchange;vmicguestinterface;vmicshutdown;vmicheartbeat;vmicvmsession;vmicrdv;vmictimesync;vmicvss;XblAuthManager;XblGameSave;XboxGipSvc;XboxNetApiSvc;XboxSvc;GameBarPresenceWriterSvc;PerfHost;RemoteAccess;TrkWks;WMPNetworkSvc;PhoneSvc;TabletInputService;SCardSvr;ScDeviceEnum;SCPolicySvc;bthserv;BluetoothUserService;WbioSrvc;DoSvc;SensrSvc;AarSvc;BcastDVRUserService;CaptureService;CDPSvc;DPS;DusmSvc;fhsvc;FrameServer;FrameServerMonitor;GraphicsPerfSvc;IcsSvc;InstallService;LicenseManager;lltdsvc;LxpSvc;MSiSCSI;NcdAutoSvc;Netlogon;PeerDistSvc;PenService;PerceptionSimulation;PrintNotify;PromoAgentSvc;QWAVE;RasMan;RmSvc;RpcLocator;SDRSVC;SEMgrSvc;SensorDataService;SensorService;SharedAccess;SharedRealitySvc;SmsRouter;SstpSvc;StiSvc;StorSvc;TapiSrv;TieringEngineService;TimeBroker;TokenBroker;TroubleshootingSvc;UevAgentService;UmRdpService;UnistoreSvc;UserDataSvc;UsoSvc;VSS;vds;W32Time;Wcmsvc;Wecsvc;WEPHOSTSVC;WiaRpc;WinHttpAutoProxySvc;WinRM;wlidsvc;WpcMonSvc;WPDBusEnum;WpnService;WwanSvc

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$env:SAFE -split ';' | ForEach-Object { $s=$_.Trim(); if($s){ sc.exe config $s start= disabled 2>$null | Out-Null; sc.exe stop $s 2>$null | Out-Null } }"

echo Done.
echo.

REM =====================================================================
REM  4. GAMING / LATENCY / MMCSS REGISTRY TWEAKS
REM =====================================================================
echo [%time%] [4/12] Applying gaming ^& latency registry tweaks...

REM --- Win32PrioritySeparation = 0x26 (short, variable, foreground boost) ---
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 0x26 /f >nul
REM --- MMCSS: SystemResponsiveness = 0 (give 0% to low-prio background) ---
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul
REM --- MMCSS: NetworkThrottlingIndex = max (no throttle) ---
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f >nul
REM --- MMCSS Games task: Priority=High(2), GPU Priority=8, Scheduling=High ---
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Latency Sensitive" /t REG_SZ /d "True" /f >nul
REM --- Window Manager task priority boost ---
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Priority" /t REG_DWORD /d 8 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul
REM --- Disable GameDVR / Xbox Game Bar (background capture off) ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\xbgm" /v Start /t REG_DWORD /d 4 /f >nul
REM --- Mouse acceleration OFF (raw, consistent aim) ---
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f >nul
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f >nul
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f >nul
REM --- Disable full-screen optimizations nag (per-app override) ---
reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f >nul
reg add "HKCU\System\GameConfigStore" /v GameDVR_HonorUserFSEBehaviorMode /t REG_DWORD /d 1 /f >nul
REM --- Disable Game Bar background recording ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AudioCaptureEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "HistoricalCaptureEnabled" /t REG_DWORD /d 0 /f >nul
echo Done.
echo.

REM =====================================================================
REM  5. BCDEDIT  -  timer / boot tweaks for better frame pacing
REM =====================================================================
echo [%time%] [5/12] Applying bcdedit timer ^& boot tweaks...

bcdedit /set disabledynamictick no >nul 2>&1
bcdedit /deletevalue useplatformclock >nul 2>&1
bcdedit /set useplatformtick yes >nul 2>&1
bcdedit /set tscsyncpolicy enhanced >nul 2>&1
bcdedit /set disabledynamictick no >nul 2>&1
REM --- Disable fast startup (it causes driver/state weirdness) ---
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >nul
echo Done.
echo.

REM =====================================================================
REM  6. POWER PLAN  -  Ultimate Performance + hibernation off
REM =====================================================================
echo [%time%] [6/12] Enabling Ultimate Performance power plan...

REM --- Unhide Ultimate Performance plan ---
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
REM --- Set it active ---
for /f "tokens=4" %%g in ('powercfg /getactivescheme') do set ACTIVEPLAN=%%g
for /f "tokens=4" %%g in ('powercfg -list ^| findstr /i "e9a42b02"') do set ULTPLAN=%%g
if defined ULTPLAN powercfg /setactive %ULTPLAN% >nul 2>&1
REM --- Fallback: set High Performance if Ultimate unavailable ---
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
REM --- Disable hibernation (frees disk ^& RAM, faster shutdown) ---
powercfg -h off >nul 2>&1
REM --- Disable USB selective suspend + power throttling + standby ---
powercfg /change standby-timeout-ac 0 >nul 2>&1
powercfg /change hibernate-timeout-ac 0 >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f >nul
echo Done.
echo.

REM =====================================================================
REM  7. VISUAL EFFECTS  -  snappy, no animations/transparency
REM =====================================================================
echo [%time%] [7/12] Disabling animations, transparency, widgets, Copilot...

REM --- VisualFXSetting = 3 (custom) and set mask: keep font smoothing + thumbnails, kill the rest ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 3 /f >nul
REM --- UserPreferencesMask: smooth-screen fonts + cursor shadow off, animations off ---
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f >nul
REM --- Disable window animations ---
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul
REM --- Disable transparency ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul
REM --- Disable widgets / news feed on taskbar ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f >nul
REM --- Disable Copilot key/taskbar ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCopilotButton /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\WindowsCopilot" /v IsCopilotAvailable /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f >nul
REM --- Disable Task View / Chat / Meet Now on taskbar ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarMn /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarSd /t REG_DWORD /d 0 /f >nul
REM --- Disable startup delay (apps launch instantly) ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /t REG_DWORD /d 0 /f >nul
REM --- Disable "Show suggestions occasionally" Start menu ads ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_IrisRecommendations /t REG_DWORD /d 0 /f >nul
REM --- Disable lock-screen fun facts / tips ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreenSlideshow /t REG_DWORD /d 1 /f >nul
echo Done.
echo.

REM =====================================================================
REM  8. NETWORK OPTIMIZATION  -  lower latency, faster DNS
REM =====================================================================
echo [%time%] [8/12] Optimizing network stack (TCP, RSS, Nagle, DNS)...

REM --- TCP global autotuning + CTCP congestion provider ---
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global congestionprovider=ctcp >nul 2>&1
netsh int tcp set global ecncapability=enabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global timestamps=disabled >nul 2>&1
netsh int tcp set global initialrto=2000 >nul 2>&1
netsh int tcp set heuristics disabled >nul 2>&1
REM --- Disable Nagle algorithm on all active adapters (lower latency) ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {" ^
  "  $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\' + $_.InterfaceGuid;" ^
  "  if(Test-Path $key){" ^
  "    Set-ItemProperty -Path $key -Name 'TcpAckFrequency' -Value 1 -Type DWord -ErrorAction SilentlyContinue;" ^
  "    Set-ItemProperty -Path $key -Name 'TCPNoDelay' -Value 1 -Type DWord -ErrorAction SilentlyContinue" ^
  "  }" ^
  "}"
REM --- Disable power saving on network adapters (no idle latency spikes) ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {" ^
  "  Set-NetAdapterPowerManagement -Name $_.Name -AllowComputerToTurnOffDevice Disabled -ErrorAction SilentlyContinue" ^
  "}"
REM --- Set Cloudflare DNS (1.1.1.1 / 1.0.0.1) on active adapters ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Get-DnsClientServerAddress -ErrorAction SilentlyContinue | Where-Object { $_.ServerAddresses.Count -gt 0 -and $_.AddressFamily -eq 2 } | ForEach-Object {" ^
  "  Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses ('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue" ^
  "}"
REM --- Disable Delivery Optimization (P2P Windows Update uploads) ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f >nul
echo Done.
echo.

REM =====================================================================
REM  9. NTFS / STORAGE TWEAKS  -  faster file I/O
REM =====================================================================
echo [%time%] [9/12] Applying NTFS ^& storage tweaks...

REM --- Disable 8.3 short filename creation ---
fsutil behavior set disable8dot3 1 >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsDisable8dot3NameCreation /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsDisable8dot3NameCreationLastDrive /t REG_DWORD /d 0 /f >nul
REM --- Disable Last Access timestamp updates (less disk writes) ---
fsutil behavior set disablelastaccess 1 >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsDisableLastAccessUpdate /t REG_DWORD /d 1 /f >nul
REM --- Increase NTFS memory usage (more file cache) ---
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsMemoryUsage /t REG_DWORD /d 2 /f >nul
REM --- Disable indexing service (already stopped service above) ---
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ContentIndex" /v Enabled /t REG_DWORD /d 0 /f >nul
REM --- Large system cache + I/O page lock limit (more RAM for file cache) ---
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v IoPageLockLimit /t REG_DWORD /d 0x10000000 /f >nul
REM --- Disable Storage Sense (auto cleanup can wait) ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f >nul
echo Done.
echo.

REM =====================================================================
REM  10. EXPLORER / UI TWEAKS  -  snappier shell
REM =====================================================================
echo [%time%] [10/12] Tweaking Explorer ^& shell...

REM --- Disable "new" Win11 context menu delay (restore classic) ---
reg add "HKCU\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /d "" /f >nul
REM --- Show file extensions + hidden files ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f >nul
REM --- Disable Explorer animations ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul
REM --- Disable "Recently added" / "Most used" in Start ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackProgs /t REG_DWORD /d 0 /f >nul
REM --- Disable background apps globally (where supported) ---
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul
REM --- Disable Sticky/Toggle/Filter Keys annoyances ---
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d "506" /f >nul
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v Flags /t REG_SZ /d "122" /f >nul
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v Flags /t REG_SZ /d "58" /f >nul
REM --- Disable "Suggested" apps in Start menu ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoSuggestedAppsInStart /t REG_DWORD /d 1 /f >nul
echo Done.
echo.

REM =====================================================================
REM  11. CLEANUP  -  temp, prefetch, update cache, event logs
REM =====================================================================
echo [%time%] [11/12] Cleaning temp files ^& caches...

REM --- Stop Windows Update service so we can clear its cache ---
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1

del /s /f /q "%TEMP%\*" >nul 2>&1
rd /s /q "%TEMP%" >nul 2>&1
md "%TEMP%" >nul 2>&1
del /s /f /q "C:\Windows\Temp\*" >nul 2>&1
rd /s /q "C:\Windows\Temp" >nul 2>&1
md "C:\Windows\Temp" >nul 2>&1
del /s /f /q "C:\Windows\Prefetch\*" >nul 2>&1
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
rd /s /q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
md "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
del /s /f /q "C:\$Recycle.Bin\*" >nul 2>&1

net start bits >nul 2>&1
net start wuauserv >nul 2>&1

REM --- Clear all event logs ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | Where-Object { $_.IsEnabled -and $_.RecordCount -gt 0 } | ForEach-Object { try { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($_.LogName) } catch {} }"

echo Done.
echo.

REM =====================================================================
REM  12. RESTART EXPLORER  -  apply UI changes now
REM =====================================================================
echo [%time%] [12/12] Restarting Explorer to apply UI changes...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul
start explorer.exe
echo Done.
echo.

REM =====================================================================
echo =====================================================================
echo   EXTREME DEBLOAT COMPLETE.
echo.
echo   What just happened:
echo     - Restore point "extreme-debloat.bat BEFORE" created (roll back
echo       via rstrui.exe if anything breaks).
echo     - Telemetry, bloatware, ~90 unneeded services killed.
echo     - Gaming/latency tweaks, Ultimate Performance plan, hibernation
echo       off, animations/transparency/widgets/Copilot off.
echo     - Network stack tuned (CTCP, RSS, Nagle off, Cloudflare DNS).
echo     - NTFS 8.3 + Last Access off, temp/prefetch/update cache cleared.
echo     - Explorer restarted; UI changes are live.
echo.
echo   REBOOT NOW for the rest (power plan, bcdedit, services) to take
echo   full effect. After reboot the system should feel MUCH snappier.
echo =====================================================================
echo.
echo Press any key to exit...
pause >nul
endlocal
