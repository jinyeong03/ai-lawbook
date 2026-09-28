# AI 법전 (한국어판)

AI 에이전트에게 직무별 품질 기준을 법률 형식으로 집행하는 Claude Code 플러그인입니다.
개발자, 디자이너, 기획자, 마케터, 작가, 번역가, 데이터 분석가, 연구자, 고객지원, 교육자,
인사, 영업 12개 직무의 AI법과 새 법을 제정·개정하는 입법 스킬 `ai-lawmaker` 를 담고 있습니다.

AI가 법을 어기면 로컬 파일 `~/.claude/ai-lawbook/confessions.md` 에 반성문을 스스로 기록하고,
SessionStart 훅이 이후 세션마다, SubagentStart 훅이 하위 에이전트마다 그 장부와 시행 명부
(`~/.claude/ai-lawbook/enabled-laws`)에 적힌 법 전문을 컨텍스트에 넣습니다. 훅은 이 두 로컬 파일과 플러그인 안의 법 파일만 읽으며,
네트워크 요청을 하지 않고 어떤 데이터도 외부로 보내지 않습니다.

설치, 사용법, 개인정보 안내는 저장소 README를 참고하세요: https://github.com/jinyeong03/ai-lawbook
