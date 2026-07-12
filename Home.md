---
tags:
  - meta
---

# Home

이 Vault의 시작점입니다. 왼쪽 파일 탐색기가 낯설다면 여기서부터.

## 어떻게 쓰나

1. 뭐든 떠오르면 `Ctrl+N` — 새 노트는 자동으로 `00_Inbox`에 생깁니다. 분류 고민은 나중에.
2. 하루의 시작은 `Ctrl+P` → "Open today's daily note".
3. 새로 배운 건 `30_TIL`에, 삽질 기록은 `40_Troubleshooting`에. `Ctrl+P` → "Insert template"로 양식을 불러올 수 있습니다.
4. 노트끼리는 `[[노트 이름]]`으로 연결합니다. 연결이 쌓이면 그래프 뷰(`Ctrl+G`)가 재밌어집니다.

## 최근에 만진 노트

```dataview
TABLE file.mtime AS "수정"
FROM ""
WHERE file.name != "Home"
SORT file.mtime DESC
LIMIT 10
```

## 진행 중인 프로젝트

```dataview
LIST
FROM #project
WHERE status = "active"
```

## 해결 못 한 문제

```dataview
LIST
FROM #troubleshooting
WHERE resolved = false
```
