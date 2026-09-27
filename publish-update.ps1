param(
    [Parameter(Mandatory=$true)][string]$ApkPath,
    [Parameter(Mandatory=$true)][int]$VersionCode,
    [Parameter(Mandatory=$true)][string]$VersionName,
    [string]$Notes = "사용성과 안정성을 개선했습니다."
)

$ErrorActionPreference = "Stop"
$Repo = "noveljelly/MyTJ-Updates"
$PackageId = "com.example.mytj"
$MinSdk = 26
$Tag = "v$VersionCode"

if (-not (Test-Path $ApkPath -PathType Leaf)) {
    throw "APK를 찾을 수 없습니다: $ApkPath"
}
if ($VersionCode -lt 1) { throw "VersionCode는 1 이상이어야 합니다." }
if ([string]::IsNullOrWhiteSpace($VersionName) -or $VersionName.Length -gt 40) {
    throw "VersionName을 확인하세요."
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI(gh)가 필요합니다. https://cli.github.com/ 에서 설치한 뒤 gh auth login을 실행하세요."
}

gh auth status | Out-Null
if ($LASTEXITCODE -ne 0) { throw "먼저 'gh auth login'으로 GitHub에 로그인하세요." }

gh release view $Tag --repo $Repo *> $null
if ($LASTEXITCODE -eq 0) {
    throw "Release $Tag 가 이미 존재합니다. 기존 versionCode를 재사용하지 말고 새 versionCode로 빌드하세요."
}

$work = Join-Path $env:TEMP "mytj-release-$VersionCode"
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Path $work | Out-Null

$apkName = "MyTJ-$VersionName-$VersionCode.apk"
$releaseApk = Join-Path $work $apkName
Copy-Item $ApkPath $releaseApk

$size = (Get-Item $releaseApk).Length
if ($size -lt 1 -or $size -gt 157286400) {
    throw "APK 크기는 1 byte 이상 150 MiB 이하여야 합니다."
}
$sha = (Get-FileHash $releaseApk -Algorithm SHA256).Hash.ToLowerInvariant()
$escapedName = [uri]::EscapeDataString($apkName)
$apkUrl = "https://github.com/$Repo/releases/download/$Tag/$escapedName"

$manifest = [ordered]@{
    schemaVersion = 1
    packageId = $PackageId
    versionCode = $VersionCode
    versionName = $VersionName
    apkUrl = $apkUrl
    sha256 = $sha
    sizeBytes = $size
    minSdk = $MinSdk
    notes = $Notes
}

$manifestPath = Join-Path $work "update.json"
$manifest | ConvertTo-Json -Depth 4 | Set-Content $manifestPath -Encoding utf8

Write-Host ""
Write-Host "=== update.json ==="
Get-Content $manifestPath
Write-Host ""
Write-Host "GitHub Release 생성 중..."

gh release create $Tag $releaseApk $manifestPath --repo $Repo --title "MyTJ $VersionName" --notes $Notes --latest
if ($LASTEXITCODE -ne 0) { throw "GitHub Release 생성에 실패했습니다." }

Write-Host ""
Write-Host "완료:"
Write-Host "Manifest: https://github.com/$Repo/releases/latest/download/update.json"
Write-Host "APK:      $apkUrl"
Write-Host ""
Write-Host "이제 MyTJ 관리자 앱에서 '새 빌드 확인'을 누른 뒤 업데이트 알림을 발행하세요."
