<div align="center">

# obsidian-dev-vault

**개발 노트용 옵시디언 Vault 템플릿 — 클론해서 열면 끝**

[![License](https://img.shields.io/github/license/beomwon/obsidian-dev-vault?color=8b5cf6)](LICENSE)
[![Obsidian](https://img.shields.io/badge/Obsidian-purple?logo=obsidian&logoColor=white&color=7c3aed)](https://obsidian.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-a78bfa.svg)](https://github.com/beomwon/obsidian-dev-vault/pulls)
[![Stars](https://img.shields.io/github/stars/beomwon/obsidian-dev-vault?style=social)](https://github.com/beomwon/obsidian-dev-vault/stargazers)

[시작하기](#시작하기) ·
[구조](#구조) ·
[템플릿](#템플릿) ·
[플러그인](#플러그인) ·
[Claude와 쓰기](#claude-code와-같이-쓰기)

</div>

---

옵시디언은 처음 켜면 빈 폴더 하나가 전부입니다. 폴더 구조는 어떻게 잡을지, 데일리 노트는 어디에 쌓을지, 플러그인은 뭘 깔아야 할지 이런 걸 검색하다 보면 정작 노트는 한 줄도 못 쓰고 하루가 갑니다. 그래서 그 결정들을 미리 해둔 저장소를 만들었습니다. 클론해서 열면 바로 쓸 수 있고, 쓰다가 마음에 안 드는 부분은 고치면 됩니다.

## 시작하기

### Windows

PowerShell에서 아래 한 줄이면 됩니다. 옵시디언 설치(winget) → 플러그인 다운로드 → Vault 등록까지 알아서 진행됩니다.

```powershell
irm https://raw.githubusercontent.com/beomwon/obsidian-dev-vault/main/setup.ps1 | iex
```

이미 클론해뒀다면 저장소 폴더에서:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

### macOS

```bash
git clone https://github.com/beomwon/obsidian-dev-vault.git
cd obsidian-dev-vault
./setup.sh
```

### 수동으로

스크립트가 내키지 않으면 직접 해도 똑같습니다.

1. [obsidian.md](https://obsidian.md)에서 옵시디언 설치
2. 이 저장소 클론
3. 옵시디언에서 **Open folder as vault**로 클론한 폴더 열기
4. 설정 → 커뮤니티 플러그인에서 아래 플러그인 설치

처음 열 때 커뮤니티 플러그인을 신뢰할지 물어보는데, 플러그인을 쓰려면 신뢰를 선택해야 합니다.

## 구조

```
00_Inbox/            일단 여기에 씁니다. 분류는 나중에
10_Daily/            데일리 노트 (YYYY-MM-DD.md)
20_Projects/         프로젝트별 노트
30_TIL/              오늘 배운 것
40_Troubleshooting/  삽질 기록. 같은 삽질을 두 번 하지 않기 위해
90_Templates/        노트 템플릿
99_Attachments/      이미지, 첨부파일 (자동으로 여기 저장됨)
```

숫자 접두어는 정렬용입니다. 자주 쓰는 폴더가 위로 오고, 나중에 사이에 새 폴더를 끼워 넣기도 쉽습니다.

## 들어있는 노트

| 파일                                            | 내용                                                                                                                   |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| [Home](Home.md)                                 | 시작 노트. Vault 사용법 안내와 함께 최근 수정한 노트, 진행 중인 프로젝트, 아직 못 푼 문제가 Dataview로 자동 집계됩니다 |
| [Claude 연동 가이드](Claude%20연동%20가이드.md) | 클로드 웹 / 데스크탑 / VSCode 확장 각각에서 이 Vault를 쓰는 방법. 데스크탑용 MCP 설정 예시 포함                        |
| [CLAUDE.md](CLAUDE.md)                          | Claude Code용 Vault 규칙. 폴더 용도, 파일명·frontmatter 형식, 자주 하는 요청("TIL로 정리해줘" 등)의 처리 방법          |

## 템플릿

`Ctrl+P` → **Insert template**으로 불러옵니다.

| 템플릿                                             | 용도                                                                             |
| -------------------------------------------------- | -------------------------------------------------------------------------------- |
| [Daily](90_Templates/Daily.md)                     | 데일리 노트. 할 일, 메모, 오늘 배운 것                                           |
| [TIL](90_Templates/TIL.md)                         | 배운 것 + 어떤 맥락에서 알게 됐는지                                              |
| [Troubleshooting](90_Templates/Troubleshooting.md) | 증상 / 원인 / 해결 / 재발 방지. 에러 메시지는 원문 그대로 넣어서 나중에 검색되게 |
| [Project](90_Templates/Project.md)                 | 개요, 링크, 할 일, 날짜별 로그                                                   |

## 플러그인

| 플러그인                                                         | 왜 넣었나                                                      |
| ---------------------------------------------------------------- | -------------------------------------------------------------- |
| [Dataview](https://github.com/blacksmithgu/obsidian-dataview)    | 노트를 쿼리해서 목록으로. Home의 자동 집계가 이걸로 동작합니다 |
| [Calendar](https://github.com/liamcain/obsidian-calendar-plugin) | 사이드바 달력. 날짜를 클릭하면 그날 데일리 노트로 이동         |
| [Templater](https://github.com/SilentVoid13/Templater)           | 코어 템플릿보다 유연한 템플릿. 당장은 몰라도 됩니다            |
| [Obsidian Git](https://github.com/Vinzent03/obsidian-git)        | Vault를 깃으로 자동 백업                                       |

플러그인 본체는 저장소에 포함하지 않습니다. setup 스크립트가 각 플러그인의 최신 릴리스를 받아옵니다.

## Claude Code와 같이 쓰기

[CLAUDE.md](CLAUDE.md)에 이 Vault의 규칙(폴더 용도, 파일명, frontmatter 형식, 자주 하는 요청의 처리 방법)이 정리되어 있습니다. Vault 폴더에서 Claude Code를 열면 "어제 삽질한 거 트러블슈팅으로 정리해줘" 같은 요청을 매번 설명 없이 시킬 수 있습니다. 안 쓰면 지워도 됩니다.

옵시디언을 만든 [kepano의 Agent Skills](https://github.com/kepano/obsidian-skills) 중 셋(obsidian-markdown, obsidian-bases, json-canvas)을 `.claude/skills/`에 포함해뒀습니다(MIT). 덕분에 클론만 하면 Claude Code가 콜아웃·임베드·속성 같은 옵시디언 문법과 Bases, Canvas 파일을 바로 다룰 줄 압니다.

클로드 웹이나 데스크탑 앱에서 쓰는 방법은 [Claude 연동 가이드](Claude%20연동%20가이드.md)에 정리했습니다.

## 기여

오타 수정부터 템플릿 제안까지 뭐든 환영합니다. [이슈](https://github.com/beomwon/obsidian-dev-vault/issues)로 먼저 얘기해 주셔도 되고, 바로 PR을 보내셔도 됩니다.

이 템플릿이 세팅 시간을 아껴줬다면 ⭐ 하나 눌러주세요. 다음 사람이 이 저장소를 찾는 데 큰 도움이 됩니다.

## 라이선스

[MIT](LICENSE) — 마음껏 가져다 쓰세요.
