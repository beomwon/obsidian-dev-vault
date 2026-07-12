---
tags:
  - meta
created: 2026-07-12
---

# Claude 연동 가이드

이 Vault를 Claude와 같이 쓰는 방법. 핵심은 두 가지다.

- 로컬 Vault 파일을 직접 읽고 쓸 수 있는 건 **Claude Code** (VSCode 확장/CLI)와 **데스크탑(MCP 세팅 시)** 뿐이다. 웹은 깃허브를 경유한다.
- [[CLAUDE]] 규칙이 자동으로 읽히는 건 Claude Code뿐이다. 나머지 환경에선 규칙을 한 번 심어줘야 한다.

| 환경 | 로컬 파일 접근 | 세팅 | 어울리는 용도 |
| --- | --- | --- | --- |
| VSCode 확장 / CLI | O | 없음 | 코딩하다 TIL·트러블슈팅 기록 (메인) |
| 클로드 데스크탑 | O (MCP 필요) | 중간 | 대화하면서 노트 검색·정리 |
| 클로드 웹 | X (깃허브 경유) | 낮음 | 외출 중 노트 읽기·원격 정리 |

## 1. VSCode 확장 / 터미널 — Claude Code

기본 환경. 추가 세팅이 필요 없다.

- Vault 폴더에서 Claude Code를 열면 CLAUDE.md가 자동 로드된다. "오늘 배운 거 TIL로 정리해줘"가 바로 통한다.
- 다른 프로젝트에서 코딩 중이라면 그 세션에서 Vault를 붙인다:

  ```
  /add-dir c:\Users\user\Desktop\이범원\옵시디언
  ```

- 매번 붙이기 귀찮으면 전역 설정(`~/.claude/CLAUDE.md`)에 한 줄 추가:

  > 옵시디언/노트 정리 요청이 오면 Vault는 `c:\Users\user\Desktop\이범원\옵시디언`, 규칙은 그 폴더의 CLAUDE.md를 따를 것.

## 2. 클로드 데스크탑

채팅 앱이라 기본적으로 로컬 파일을 못 본다. MCP 서버를 붙여서 해결한다.

**Filesystem MCP (간단, 이걸로 시작)**

설정 → 개발자 → MCP 서버 설정(`claude_desktop_config.json`)에 추가:

```json
{
  "mcpServers": {
    "obsidian-vault": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "c:\\Users\\user\\Desktop\\이범원\\옵시디언"
      ]
    }
  }
}
```

저장 후 데스크탑 앱을 재시작하면 채팅에서 "인박스 노트 읽고 분류해줘" 같은 게 가능해진다.

**Obsidian MCP (고급, 필요해지면)**

옵시디언에 Local REST API 플러그인을 설치하고 커뮤니티 `mcp-obsidian` 서버를 연결하면 옵시디언 자체 검색·태그 기능까지 쓸 수 있다.

**주의** — 데스크탑은 CLAUDE.md를 자동으로 안 읽는다. 프로젝트 기능으로 "옵시디언" 프로젝트를 만들고 CLAUDE.md 내용을 프로젝트 지침에 붙여넣어 둘 것.

## 3. 클로드 웹 (claude.ai)

로컬에는 손을 못 대지만 이 Vault는 [깃허브](https://github.com/beomwon/obsidian-dev-vault)에 있으므로 그걸 쓴다.

- **읽기 위주** — 깃허브 커넥터로 저장소를 연결하면 채팅에서 노트를 검색하고 질문할 수 있다.
- **쓰기까지** — claude.ai/code (웹판 Claude Code)에서 저장소를 열면 클라우드에서 노트를 편집하고 커밋·푸시한다. 저장소에 CLAUDE.md가 있으니 규칙도 자동 적용된다. 밖에서 폰으로 "오늘 배운 거 TIL로 올려줘"가 가능한 경로.

웹에서 수정한 건 깃허브에만 반영된다. 로컬과 맞추려면 Obsidian Git 플러그인에서 자동 pull/push 주기를 켜둘 것 — 이 자동 동기화가 세 환경을 하나로 묶는 접착제다.

## 넓혀가는 순서

1. 지금은 Claude Code만으로 충분
2. 노트가 쌓여서 대화하며 검색하고 싶어지면 → Filesystem MCP
3. 밖에서도 쓰고 싶어지면 → Obsidian Git 자동 동기화 + 클로드 웹
