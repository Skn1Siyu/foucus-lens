param([Parameter(Mandatory)][string]$Version)
$ErrorActionPreference='Stop'
$work=$PSScriptRoot
function Log($text) { Add-Content "$work\checks.txt" $text }
function Require($ok, $msg) { if (!$ok) { throw $msg } }
function Invoke-Exe($file, $arguments) {
  Log "Starting: $(Split-Path $file -Leaf)"
  $p=Start-Process -FilePath $file -ArgumentList $arguments -PassThru
  if (!$p.WaitForExit(120000)) { $p.Kill(); throw "Timed out: $(Split-Path $file -Leaf)" }
  Require ($p.ExitCode -eq 0) "Exit $($p.ExitCode): $(Split-Path $file -Leaf)"
}
function Test-Runtime($root) {
  Invoke-Exe "$root\resources\parser\Deadlock.Parser.exe" '--self-test'
  $env:FOCUS_BIN=$root; $env:ELECTRON_RUN_AS_NODE='1'
  try { Invoke-Exe "$root\Deadlock Review.exe" "`"$work\runtime.cjs`"" } finally { Remove-Item Env:ELECTRON_RUN_AS_NODE }
}
function Registration {
  @(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like 'Deadlock Review*' })
}
try {
  $principal=[Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()); Require (!$principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) 'Test must use a standard user'
  # Secondary Logon can retain the parent process environment. Resolve known
  # folders from the logged-on account's profile, including its own temp path.
  $sid=[Security.Principal.WindowsIdentity]::GetCurrent().User.Value
  $profile=(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid").ProfileImagePath
  Require ((Split-Path $profile -Leaf) -like 'FocusSmoke*') 'Unexpected test user profile'
  $env:USERPROFILE=$profile; $env:APPDATA=Join-Path $profile 'AppData\Roaming'; $env:LOCALAPPDATA=Join-Path $profile 'AppData\Local'; $env:TEMP=Join-Path $env:LOCALAPPDATA 'Temp'; $env:TMP=$env:TEMP
  $null=New-Item -Force -ItemType Directory $env:TEMP
  $target="$env:LOCALAPPDATA\复盘 测试\Deadlock Review"; $uninstall="$target\Uninstall Deadlock Review.exe"; $env:FOCUS_VERSION=$Version
  @'
const p=require('node:path'), fs=require('node:fs');const dir=p.join(process.env.FOCUS_BIN,'resources','app.asar');
if(require(p.join(dir,'package.json')).version!==process.env.FOCUS_VERSION)throw Error('Version mismatch');const DB=require(p.join(dir,'node_modules','better-sqlite3'));const db=new DB(':memory:');if(db.prepare('select 42 as n').get().n!==42)throw Error('SQLite');db.close();
'@ | Set-Content "$work\runtime.cjs"
  Expand-Archive "$work\portable.zip" "$work\portable"
  Test-Runtime "$work\portable"; Log 'Portable: packaged parser and native SQLite passed.'
  $userData="$env:APPDATA\deadlock-review\matches"; $null=New-Item -Force -Type Directory $userData
  Set-Content "$userData\test-note.txt" 'sample-note'
  function Install { Invoke-Exe "$work\setup.exe" "/S /currentuser /D=$target"; $r=@(Registration); Require ($r.Count -eq 1 -and $r[0].DisplayVersion -eq $Version -and $r[0].UninstallString -eq "`"$uninstall`" /currentuser" -and (Test-Path $uninstall)) 'Installed app registration is incorrect' }
  function Uninstall { Invoke-Exe $uninstall '/currentuser /S'; $end=(Get-Date).AddSeconds(50); while ((@(Registration).Count -or (Test-Path "$target\Deadlock Review.exe")) -and (Get-Date) -lt $end) { Start-Sleep 1 }; Require (@(Registration).Count -eq 0 -and !(Test-Path "$target\Deadlock Review.exe")) 'Uninstall failed'; Require ((Get-Content "$userData\test-note.txt") -eq 'sample-note') 'User data changed' }
  Install; Test-Runtime $target; Uninstall; Log 'Install and normal uninstall in a non-ASCII path passed; local data retained.'
  Install; $original=(Get-FileHash $uninstall).Hash
  $bytes=[IO.File]::ReadAllBytes($uninstall); $bytes[-1]=$bytes[-1] -bxor 1; [IO.File]::WriteAllBytes($uninstall,$bytes)
  Require ((Get-FileHash $uninstall).Hash -ne $original) 'Failed to simulate damage'
  Install; Require ((Get-FileHash $uninstall).Hash -eq $original) 'Installer failed to restore verified uninstaller'; Uninstall
  Log 'Reinstall after a damaged uninstaller, restored digest, normal uninstall and saved data passed.'
  if ($Version -eq '0.7.2') {
    # Reproduce the 0.7.1 registered executable using only its public PE resource
    # differences. Do not distribute the old app archive or any user data.
    Install
    $exe="$target\Deadlock Review.exe"; $pe=[IO.File]::ReadAllBytes($exe)
    $legacyDigest=[Text.Encoding]::ASCII.GetBytes('b5e82b4859856055bb27a36d2b0f8b3b3ab307766bc79e3f32d1ac245e3b0233'); $legacyDigest.CopyTo($pe,209750751)
    $pe[209808214]=1; $pe[209808222]=1; $pe[209808516]=49; $pe[209808864]=49; [IO.File]::WriteAllBytes($exe,$pe)
    Require ((Get-FileHash $exe).Hash -eq 'ff5fb410266d7d90aed53c125be3381d96f80c31798c87b3f50fdf24496001d0') 'Legacy executable fingerprint mismatch'
    Set-ItemProperty (Registration).PSPath DisplayVersion '0.7.1'; [IO.File]::WriteAllBytes($uninstall,[byte[]](1,2,3,4))
    Install; Require ((Get-FileHash $uninstall).Hash -eq $original) 'Legacy repair digest mismatch'; Test-Runtime $target; Uninstall
    Log 'Simulated 0.7.1 registration, exact legacy EXE and truncated uninstaller: upgrade, runtime and normal uninstall passed.'
  }
  Set-Content "$work\result.txt" 'PASS'
} catch { Set-Content "$work\result.txt" "$($_.Exception.Message) (line $($_.InvocationInfo.ScriptLineNumber))"; exit 1 }
