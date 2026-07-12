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
plugins=(
    "dataview blacksmithgu/obsidian-dataview"
    "templater-obsidian SilentVoid13/Templater"
    "calendar liamcain/obsidian-calendar-plugin"
    "obsidian-git Vinzent03/obsidian-git"
)

for entry in "${plugins[@]}"; do
    id="${entry%% *}"
    repo="${entry##* }"
    dir="$VAULT_DIR/.obsidian/plugins/$id"
    mkdir -p "$dir"
    step "플러그인 다운로드: $id"
    for file in main.js manifest.json styles.css; do
        url="https://github.com/$repo/releases/latest/download/$file"
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
