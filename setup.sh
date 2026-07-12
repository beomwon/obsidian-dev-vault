#!/usr/bin/env bash
# obsidian-dev-vault 설치 스크립트 (macOS)
#
# 하는 일:
#   1. 옵시디언이 없으면 Homebrew로 설치
#   2. 커뮤니티 플러그인 다운로드
#   3. 옵시디언 실행
set -euo pipefail

VAULT_DIR="$(cd "$(dirname "$0")" && pwd)"

step() { printf '\033[36m==> %s\033[0m\n' "$1"; }

# 1. 옵시디언 설치
if [ ! -d "/Applications/Obsidian.app" ]; then
    if command -v brew >/dev/null 2>&1; then
        step "옵시디언 설치 중 (Homebrew)..."
        brew install --cask obsidian
    else
        echo "Homebrew가 없습니다. https://obsidian.md 에서 직접 설치해 주세요." >&2
    fi
else
    step "옵시디언이 이미 설치되어 있습니다."
fi

# 2. 커뮤니티 플러그인 다운로드
#    무조건 최신 릴리스를 받으면 안 된다. 플러그인 최신 버전이
#    설치된 옵시디언보다 높은 버전(minAppVersion)을 요구하면
#    "로드할 수 없음" 팝업이 뜨기 때문에, 릴리스를 최신부터 훑으며
#    설치된 옵시디언과 호환되는 첫 릴리스를 골라 받는다.
OBS_VERSION=""
if [ -d "/Applications/Obsidian.app" ]; then
    OBS_VERSION=$(defaults read /Applications/Obsidian.app/Contents/Info CFBundleShortVersionString 2>/dev/null || true)
fi
if [ -n "$OBS_VERSION" ]; then
    step "옵시디언 버전: $OBS_VERSION"
fi

compatible_tag() {
    python3 - "$1" "$OBS_VERSION" <<'PY'
import json, sys, urllib.request

repo, obs = sys.argv[1], sys.argv[2]

def ver(s):
    return tuple(int(x) for x in s.split(".") if x.isdigit())

url = f"https://api.github.com/repos/{repo}/releases?per_page=20"
releases = json.load(urllib.request.urlopen(url))
for r in releases:
    if r.get("draft") or r.get("prerelease"):
        continue
    # 프리릴리스 표시 없이 올라온 베타도 거른다 (예: 2.0.0-beta.2)
    if "-" in r["tag_name"]:
        continue
    assets = {a["name"]: a["browser_download_url"] for a in r["assets"]}
    if "manifest.json" not in assets:
        continue
    manifest = json.load(urllib.request.urlopen(assets["manifest.json"]))
    m = manifest.get("minAppVersion")
    if not obs or not m or ver(m) <= ver(obs):
        print(r["tag_name"])
        break
PY
}

plugins=(
    "dataview blacksmithgu/obsidian-dataview"
    "templater-obsidian SilentVoid13/Templater"
    "calendar liamcain/obsidian-calendar-plugin"
    "obsidian-git Vinzent03/obsidian-git"
)

for entry in "${plugins[@]}"; do
    id="${entry%% *}"
    repo="${entry##* }"
    tag=$(compatible_tag "$repo")
    if [ -z "$tag" ]; then
        echo "경고: $id 호환 릴리스를 찾지 못해 건너뜁니다." >&2
        continue
    fi
    dir="$VAULT_DIR/.obsidian/plugins/$id"
    mkdir -p "$dir"
    step "플러그인 다운로드: $id $tag"
    for file in main.js manifest.json styles.css; do
        url="https://github.com/$repo/releases/download/$tag/$file"
        if ! curl -fsSL "$url" -o "$dir/$file"; then
            # styles.css는 없는 플러그인도 있다
            if [ "$file" != "styles.css" ]; then
                echo "다운로드 실패: $url" >&2
                exit 1
            fi
            rm -f "$dir/$file"
        fi
    done
done

# 3. 실행
echo ""
printf '\033[32m완료. Vault 위치: %s\033[0m\n' "$VAULT_DIR"
echo "옵시디언에서 커뮤니티 플러그인 사용 여부를 물으면 '신뢰'를 선택하세요."

if [ -d "/Applications/Obsidian.app" ]; then
    open "obsidian://open?path=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$VAULT_DIR")" 2>/dev/null \
        || open -a Obsidian
    echo "처음이라면 'Open folder as vault'로 위 경로를 열어 주세요."
fi
