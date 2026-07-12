# obsidian-dev-vault 설치 스크립트 (Windows)
#
# 하는 일:
#   1. 옵시디언이 없으면 winget으로 설치
#   2. 커뮤니티 플러그인(Dataview, Templater, Calendar, Obsidian Git) 다운로드
#   3. 이 Vault를 옵시디언에 등록하고 실행
#
# 실행 방법:
#   저장소 폴더에서:  powershell -ExecutionPolicy Bypass -File .\setup.ps1
#   클론 없이 바로:   irm https://raw.githubusercontent.com/beomwon/obsidian-dev-vault/main/setup.ps1 | iex

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepoUrl = "https://github.com/beomwon/obsidian-dev-vault"

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }

# ---------------------------------------------------------------
# 1. Vault 경로 결정
#    스크립트가 저장소 안에서 실행됐으면 그 폴더를 쓰고,
#    irm | iex 로 실행됐으면 저장소를 문서 폴더에 내려받는다.
# ---------------------------------------------------------------
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot ".obsidian"))) {
    $VaultPath = $PSScriptRoot
} else {
    $VaultPath = Join-Path $HOME "Documents\obsidian-dev-vault"
    if (Test-Path (Join-Path $VaultPath ".obsidian")) {
        Write-Step "이미 받아둔 Vault를 사용합니다: $VaultPath"
    } else {
        Write-Step "저장소 다운로드: $VaultPath"
        $zip = Join-Path $env:TEMP "obsidian-dev-vault.zip"
        Invoke-WebRequest "$RepoUrl/archive/refs/heads/main.zip" -OutFile $zip -UseBasicParsing
        $extract = Join-Path $env:TEMP "obsidian-dev-vault-extract"
        if (Test-Path $extract) { Remove-Item $extract -Recurse -Force }
        Expand-Archive $zip -DestinationPath $extract
        $inner = Get-ChildItem $extract -Directory | Select-Object -First 1
        Move-Item $inner.FullName $VaultPath
        Remove-Item $zip -Force
        Remove-Item $extract -Recurse -Force
    }
}

# ---------------------------------------------------------------
# 2. 옵시디언 설치
# ---------------------------------------------------------------
function Find-Obsidian {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Obsidian\Obsidian.exe"),
        (Join-Path $env:LOCALAPPDATA "Obsidian\Obsidian.exe")
    )
    return $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

$obsidianExe = Find-Obsidian
if ($obsidianExe) {
    Write-Step "옵시디언이 이미 설치되어 있습니다."
} else {
    Write-Step "옵시디언 설치 중 (winget)..."
    winget install --id Obsidian.Obsidian -e --silent --accept-source-agreements --accept-package-agreements
    $obsidianExe = Find-Obsidian
}

# ---------------------------------------------------------------
# 3. 커뮤니티 플러그인 다운로드
#    무조건 최신 릴리스를 받으면 안 된다. 플러그인 최신 버전이
#    설치된 옵시디언보다 높은 버전(minAppVersion)을 요구하면
#    "로드할 수 없음" 팝업이 뜨기 때문에, 릴리스를 최신부터 훑으며
#    설치된 옵시디언과 호환되는 첫 릴리스를 골라 받는다.
# ---------------------------------------------------------------
function Get-ObsidianVersion($exe) {
    if (-not $exe) { return $null }
    $v = (Get-Item $exe).VersionInfo.ProductVersion
    if ($v -match '^\d+\.\d+\.\d+') { return $Matches[0] }
    return $null
}

function Get-CompatibleRelease($repo, $obsVersion) {
    $releases = Invoke-RestMethod "https://api.github.com/repos/$repo/releases?per_page=20" -UseBasicParsing
    foreach ($r in $releases) {
        if ($r.draft -or $r.prerelease) { continue }
        # 프리릴리스 표시 없이 올라온 베타도 거른다 (예: 2.0.0-beta.2)
        if ($r.tag_name -match "-") { continue }
        $manifestAsset = $r.assets | Where-Object name -eq "manifest.json"
        if (-not $manifestAsset) { continue }
        try { $manifest = Invoke-RestMethod $manifestAsset.browser_download_url -UseBasicParsing } catch { continue }
        $min = $manifest.minAppVersion
        # 옵시디언 버전을 모르거나 플러그인이 요구 버전을 안 적었으면 그냥 통과
        if (-not $obsVersion -or -not $min -or ([version]$min -le [version]$obsVersion)) {
            return $r
        }
    }
    return $null
}

$obsVersion = Get-ObsidianVersion $obsidianExe
if ($obsVersion) { Write-Step "옵시디언 버전: $obsVersion" }

$plugins = @(
    @{ Id = "dataview";           Repo = "blacksmithgu/obsidian-dataview" },
    @{ Id = "templater-obsidian"; Repo = "SilentVoid13/Templater" },
    @{ Id = "calendar";           Repo = "liamcain/obsidian-calendar-plugin" },
    @{ Id = "obsidian-git";       Repo = "Vinzent03/obsidian-git" }
)

foreach ($p in $plugins) {
    $release = Get-CompatibleRelease $p.Repo $obsVersion
    if (-not $release) {
        Write-Host "경고: $($p.Id) 호환 릴리스를 찾지 못해 건너뜁니다." -ForegroundColor Yellow
        continue
    }
    Write-Step "플러그인 다운로드: $($p.Id) $($release.tag_name)"
    $dir = Join-Path $VaultPath ".obsidian\plugins\$($p.Id)"
    New-Item -ItemType Directory -Force $dir | Out-Null
    foreach ($file in "main.js", "manifest.json", "styles.css") {
        $asset = $release.assets | Where-Object name -eq $file
        if (-not $asset) {
            # styles.css는 없는 플러그인도 있다
            if ($file -ne "styles.css") { throw "릴리스에 $file 이 없습니다: $($p.Repo) $($release.tag_name)" }
            continue
        }
        Invoke-WebRequest $asset.browser_download_url -OutFile (Join-Path $dir $file) -UseBasicParsing
    }
}

# ---------------------------------------------------------------
# 4. Vault를 옵시디언에 등록
#    %APPDATA%\obsidian\obsidian.json 의 vaults 목록에 추가한다.
# ---------------------------------------------------------------
$obsConfigDir = Join-Path $env:APPDATA "obsidian"
New-Item -ItemType Directory -Force $obsConfigDir | Out-Null
$obsConfigPath = Join-Path $obsConfigDir "obsidian.json"

if (Test-Path $obsConfigPath) {
    $config = Get-Content $obsConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
} else {
    $config = [pscustomobject]@{}
}
if (-not $config.PSObject.Properties["vaults"]) {
    $config | Add-Member -NotePropertyName "vaults" -NotePropertyValue ([pscustomobject]@{})
}

$registered = $false
foreach ($v in $config.vaults.PSObject.Properties) {
    if ($v.Value.path -eq $VaultPath) { $registered = $true }
}

if ($registered) {
    Write-Step "Vault가 이미 등록되어 있습니다."
} else {
    Write-Step "Vault 등록: $VaultPath"
    $hex = "0123456789abcdef"
    $id = -join (1..16 | ForEach-Object { $hex[(Get-Random -Maximum 16)] })
    $entry = [pscustomobject]@{
        path = $VaultPath
        ts   = [long][datetimeoffset]::Now.ToUnixTimeMilliseconds()
    }
    $config.vaults | Add-Member -NotePropertyName $id -NotePropertyValue $entry
    $json = $config | ConvertTo-Json -Depth 10
    [IO.File]::WriteAllText($obsConfigPath, $json, (New-Object System.Text.UTF8Encoding $false))
}

# ---------------------------------------------------------------
# 5. 실행
# ---------------------------------------------------------------
Write-Host ""
Write-Host "완료. Vault 위치: $VaultPath" -ForegroundColor Green
Write-Host "옵시디언에서 커뮤니티 플러그인 사용 여부를 물으면 '신뢰'를 선택하세요." -ForegroundColor Yellow

if ($obsidianExe) {
    Start-Process $obsidianExe
} else {
    Write-Host "옵시디언 실행 파일을 찾지 못했습니다. 직접 실행한 뒤 'Open folder as vault'로 위 경로를 여세요."
}
