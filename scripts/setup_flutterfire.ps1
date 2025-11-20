# setup_flutterfire.ps1
# Run from a PowerShell prompt in the project root (may require Administrator for setx)
# This script installs the FlutterFire CLI and adds the Pub Cache bin to PATH for the session.
# It does NOT run `flutterfire configure` because that requires your Firebase project id and interactive consent.

Write-Host "1) Activating flutterfire_cli (dart pub global activate)..."
# Prefer using 'dart' if available; fallback to 'flutter pub' if not.
if (Get-Command dart -ErrorAction SilentlyContinue) {
    dart pub global activate flutterfire_cli
} elseif (Get-Command flutter -ErrorAction SilentlyContinue) {
    flutter pub global activate flutterfire_cli
} else {
    Write-Error "Neither 'dart' nor 'flutter' found. Please install Flutter/Dart and try again."
    exit 1
}

Write-Host "2) Adding Pub cache bin to PATH for this session..."
$pubBin = "$Env:USERPROFILE\AppData\Local\Pub\Cache\bin"
if (Test-Path $pubBin) {
    $env:PATH += ";$pubBin"
    Write-Host "Added $pubBin to PATH for this session."
} else {
    Write-Warning "$pubBin not found - activation may have failed or pub cache is in a different location."
}

Write-Host "3) Verify flutterfire availability"
if (Get-Command flutterfire -ErrorAction SilentlyContinue) {
    flutterfire --version
    Write-Host "flutterfire is available. Run: flutterfire configure --project <your-project-id>"
} else {
    Write-Warning "flutterfire not found in this session. Close and reopen PowerShell, or run the script again in a new shell."
}

Write-Host "NOTE: To persist PATH permanently, run (as user):"
Write-Host "  setx PATH \"$Env:PATH;$pubBin\""
Write-Host "Then close and reopen PowerShell."