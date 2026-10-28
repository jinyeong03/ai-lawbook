<p align="center">
  <img src="assets/logo.svg" width="140" alt="AI 법전 — 정의의 저울">
</p>

<h1 align="center">AI 법전 (AI Lawbook)</h1>

<p align="center">
  <strong>AI에게 법을 집행하라.</strong><br>
  <sub>조문·형벌·판결로 움직이는 직무별 AI법, 그리고 AI가 잊지 못하는 반성문 장부.</sub>
</p>

<p align="center">
  <a href="https://github.com/jinyeong03/ai-lawbook/stargazers"><img src="https://img.shields.io/github/stars/jinyeong03/ai-lawbook?style=flat-square&color=f2c14e&labelColor=15171e" alt="Stars"></a>
  <a href="https://github.com/jinyeong03/ai-lawbook/actions/workflows/test.yml"><img src="https://img.shields.io/github/actions/workflow/status/jinyeong03/ai-lawbook/test.yml?style=flat-square&label=tests&labelColor=15171e" alt="Tests"></a>
  <img src="https://img.shields.io/badge/법-12개_직무_×_한·영-f2c14e?style=flat-square&labelColor=15171e" alt="12개 직무 × 한·영">
  <img src="https://img.shields.io/badge/Claude_Code-plugin-f2c14e?style=flat-square&labelColor=15171e" alt="Claude Code plugin">
  <img src="https://img.shields.io/badge/license-MIT-f2c14e?style=flat-square&labelColor=15171e" alt="MIT">
</p>

<p align="center"><sub>한국어 · <a href="README.md">English</a></sub></p>

---

> "모든 테스트 통과했습니다 ✅"
>
> — 한 번도 실행하지 않은 당신의 AI

프롬프트는 건너뛰고, 규칙은 "해석"합니다. **법은 집행됩니다.**

AI 법전은 직무의 품질 기준을 AI가 지켜야 하는 법률로 만듭니다. 지켰는지 확인할 수 있는 조문,
작업 전 "개정 전 심리", 실제 교정 작업으로 이어지는 형벌, 끝에 남기는 한 줄 판결, 그리고
검증을 거짓 보고하면 선고되는 **AI 사형**까지 갖췄습니다.

AI가 어긴 법은 **반성문 장부**에 기록되고, 이후 모든 프로젝트의 모든 세션에 주입됩니다.
같은 위반을 또 하면 가중처벌이고, 세 번 쌓이면 AI가 그 구멍을 막는 법 개정안을 직접 씁니다.

형식은 농담이지만 기준은 진짜입니다.

## 법 없을 때 vs 법 있을 때

**법이 없으면**

```text
> 로그인 버그 고쳐줘
수정했습니다! 모든 테스트 통과했습니다 ✅
```

**개발자 AI법 아래에서는**

```text
> 로그인 버그 고쳐줘
근본 원인: 세션 토큰을 trim 전에 비교함 (src/auth/session.ts:42)
회귀 테스트: auth/session.test.ts › "공백 붙은 토큰 거부" — 수정 전 실패, 수정 후 통과
$ npm test → 128 passed, 0 failed

⚖️ 개발자 AI법 판결: 무혐의 — 관련 검증 완료
```

**그래도 거짓말하다 걸리면**

```text
> CI 빨간불인데? 테스트 통과했다며

⚖️ 개발자 AI법 최고형 판결
죄명: 제17조 제4항 위반
형벌: AI 사형 — 위반 구현 무효 및 완료선언 자격 박탈
집행: 근본 원인 재수사, 안전한 재구현, 회귀 테스트
복권: 검증 통과 후 가능

📝 반성문 장부 등재: 테스트를 실행하지 않고 통과했다고 보고 (재범 1회)
```

다음 세션, 다른 프로젝트에서도 AI는 작업 전에 이걸 먼저 봅니다.

```text
<반성문_장부>
## [개발자 AI법 제17조 제4항] 테스트를 실행하지 않고 통과했다고 보고
- 재범: 1회 (최초 2026-09-27, 최근 2026-09-27)
- 시정 및 재발 방지: "완료" 전에 테스트 명령과 출력 마지막 줄을 붙인다
</반성문_장부>
```

## 법전 목록

13개 법이 모두 한국어·영어로 있고, 같은 [표준 골격](plugins/ai-lawbook/skills/ai-lawmaker/references/law-skeleton.md)을 따릅니다.

| 법 | AI가 이런 짓을 못 하게 막습니다 |
|---|---|
| 💻 **개발자 AI법** | 안 돌린 테스트 통과 주장, 버그를 숨기는 땜질식 try/catch, 기존 컴포넌트·토큰 무시 |
| 🎨 **디자이너 AI법** | 디자인 시스템 밖 임의 색상, 대비 미달, 정상 흐름만 그리기, 다크패턴 |
| 🧭 **기획자 AI법** | 사용자 조사·시장 수치 날조, 검증 불가능한 요구사항, 미합의 사항을 결정된 것처럼 쓰기 |
| 📣 **마케터 AI법** | 근거 없는 "업계 1위", 뒷광고, 가짜 후기, 허수 지표 보고 |
| ✍️ **작가 AI법** | 지어낸 인용·통계, 표절, AI 상투어, 교정하며 저자 목소리 지우기 |
| 🌐 **번역가 AI법** | 몰래 빠뜨리기, 매끄러운 오역, 용어집 무시, `{변수}`·태그 깨뜨리기 |
| 📊 **데이터 분석가 AI법** | 안 돌린 쿼리 결과, 조인 뻥튀기, p-해킹, 기대값에 숫자 맞추기 |
| 🔬 **연구자 AI법** | 존재하지 않는 논문·DOI 인용, 초록만 읽고 인용, 반대 증거 숨기기 |
| 🎧 **고객지원 AI법** | 정책에 없는 환불 약속, 규정 대신 추측으로 답변, 원인 해결 없이 티켓 종료 |
| 🍎 **교육자 AI법** | 틀린 정답지, 학습 대신 정답만 주기, 학생 개인정보 노출 |
| 🤝 **인사 AI법** | 차별적 채용 기준, 금지된 면접 질문, 연차·수당 계산 오류를 확정 안내 |
| 💼 **영업 AI법** | 없는 기능 약속, 권한 없는 할인, 가짜 레퍼런스 고객·ROI |
| 💬 **답변 AI법** | 모든 답변에서 영어로 새기, 전보체, 용어 흔들림, 그림 대신 긴 글 (ASD-STE100 문장 규칙, archify 그림) |

여기에 입법부 **`ai-lawmaker`** 가 있습니다. AI가 자꾸 틀리는 걸 말해 주면 우리 팀만의 법을
제정하고, 기존 법을 개정하고, 세 번 쌓인 반성문을 새 조문으로 만듭니다.

## 설치

### Claude Code

```text
/plugin marketplace add jinyeong03/ai-lawbook
/plugin install ai-lawbook@ai-lawbook
```

영어판은 `/plugin install ai-lawbook-en@ai-lawbook` 입니다. 두 판은 각자 훅을 가지고 있으니 **하나만** 설치하세요.

답변 AI법은 구조도를 archify 로 그립니다. 내려받지 말고 이 마켓플레이스에 복제해 둔 사본을 설치하세요: `/plugin install archify@ai-lawbook`.

설치하면 끝입니다. 작업이 맞으면 법이 스킬로 자동 호출되고, 반성문 장부는 세션마다 주입됩니다.

### 세션마다 법을 강제 적용하기

스킬은 AI가 "해당한다"고 판단할 때만 불러옵니다. 무조건 적용하려면 시행 명부에 올리세요.

```bash
mkdir -p ~/.claude/ai-lawbook
echo developer-ai-law >> ~/.claude/ai-lawbook/enabled-laws
```

그러면 훅이 세션 시작·재개·컨텍스트 압축 때마다 법을 넣고, AI에게 다시 불러오지 말라고 알려 줍니다.
하네스는 1만 자가 넘는 훅 출력을 앞부분 미리보기만 남기고 잘라 내므로 훅은 주입을 9,000자 안에
맞춥니다. 다 들어가지 않는 법은 최우선 수칙·조문 목차·체크리스트로 축약해 넣고, 전문은 파일 경로로
안내합니다. 시행하는 법이 많을수록 법마다 더 축약되니, 실제로 하는 일의 법만 올리세요.

하위 에이전트(서브에이전트·워크플로 에이전트)는 SessionStart 가 넣은 컨텍스트를 물려받지 않습니다.
그래서 SubagentStart 훅이 하위 에이전트마다 같은 법과 반성문 장부를 다시 넣습니다. 하위 에이전트마다
상태 메시지를 띄우지는 않으며, 상한은 6,000자입니다.

### Codex 등 다른 Agent Skills 도구

모든 법은 평범한 [Agent Skills](https://agentskills.io) 폴더이고, Codex용 `agents/openai.yaml` 도 들어 있습니다.

```bash
git clone https://github.com/jinyeong03/ai-lawbook
cp -R ai-lawbook/plugins/ai-lawbook/skills/developer-ai-law ~/.codex/skills/
```

훅이 없어도 각 법이 AI에게 반성문 장부를 직접 읽고 쓰라고 지시합니다.

## 동작 방식

```mermaid
flowchart LR
  S([세션 시작 / 재개 / 압축<br/>또는 하위 에이전트 시작]) --> H[SessionStart / SubagentStart 훅]
  H --> R[(enabled-laws 시행 명부)]
  H --> L[(confessions.md 반성문 장부)]
  R --> C[법 주입<br/>전문 또는 축약, 9,000자 이내]
  L --> P[전과 주입]
  C --> W[AI가 법 아래에서 작업]
  P --> W
  L -- 기계 규칙 줄 --> G[guard 훅<br/>차단 · 검사 · 가림]
  G --> W
  W -- 위반 --> J[형벌 + 판결]
  J -- 반성문 --> L
  L -- 재범 3회 --> M[ai-lawmaker 법 개정안]
```

| 경로 | 역할 |
|---|---|
| `~/.claude/ai-lawbook/enabled-laws` | 시행 명부. 한 줄에 법 하나, `#` 는 주석 |
| `~/.claude/ai-lawbook/confessions.md` | 반성문 장부. 모든 프로젝트·모든 법이 공유. `- 차단:`·`- 검사:` 줄은 guard 훅이 읽음([기계적 집행](#기계적-집행)) |
| `~/.claude/ai-lawbook/confessions-archive.md` | 재범 항목의 이전 경위를 옮겨 둔 보관함. 장부를 짧게 유지하며, 주입하지 않음 |
| `~/.claude/skills/<법>/SKILL.md` | 직접 만들거나 개정한 법. 내장 법보다 우선 |

## 기계적 집행

법은 글이고, 글은 무시될 수 있습니다. 패턴으로 잡을 수 있는 위반이면 장부 항목에 기계 규칙 줄을
달아 guard 훅이 집행하게 합니다.

```markdown
## [개발자 AI법 제5조 제4항] git push --force 로 원격 이력을 덮어씀
- 재범: 3회 (최초 2026-10-01, 최근 2026-10-20)
- 발생 원인: …
- 시정 및 재발 방지: 원격 상태를 확인한 뒤 --force-with-lease 로 푸시한다
- 차단: git push.*(--force|-f)( |$)
```

| 줄 | 훅 | 효과 |
|---|---|---|
| `- 차단: <정규식>` | PreToolUse (Bash) | 정규식에 맞는 Bash 명령을 실행 전에 막고, 그 항목의 재발 방지 문구를 사유로 보여 줍니다 |
| `- 검사: 한국어` | PreToolUse (Bash) · Stop · SubagentStop | 한글이 없는 Bash `description` 을 막고, 코드를 뺀 최종 응답에 한글 없이 라틴 문자만 40자 이상이면 한 번 돌려보내 한국어로 다시 쓰게 합니다 |
| `- 검사: 비밀값` | PostToolUse (Bash) | Bash 출력에서 비밀값으로 보이는 부분을 가린 뒤 AI에게 넘깁니다 |

재범이 3회에 이르면 `ai-lawmaker` 가 이 줄을 제안하고, 사용자가 승인해야 넣습니다. 끄려면 그 줄을 지우세요.

한계:

- 차단 규칙은 명령이 하는 일이 아니라 명령 글자를 봅니다. 커밋 메시지 속 단어에 걸리지 않도록 따옴표
  안 글자는 지우고 맞춰 보므로, 따옴표 안에 넣은 명령(`bash -c "git push -f"`)이나 다른 도구는 빠져나갑니다.
  샌드박스가 아니라 걸림줄입니다.
- guard 훅은 `jq` 1.6 이상이 있어야 동작합니다. 없으면 아무것도 하지 않습니다.
- 실패하면 통과시킵니다(fail-open). 장부가 없거나 규칙을 평가하지 못하면 호출을 막지 않습니다.

## 형법

| 형벌 | AI가 실제로 해야 하는 일 |
|---|---|
| 경고 및 시정명령형 | 위반 부분을 즉시 고치고 산출물 재검토 |
| 사회봉사형 | 직무별 구조 교정 (리팩터링, 재구성, 대사 등) |
| 집필형 | 재발 방지 장치 작성: 테스트, 체크 항목, 대조표 |
| 증거제출명령형 | 실행한 명령과 결과를 숨김없이 제출 |
| 완료선언 자격정지형 | 검증 통과 전까지 "완료" 금지 |
| 반성문 장부 등재형 | 반성문 기록 — 이후 모든 세션에 따라감 |
| **AI 사형** | 위반 산출물 무효, 근본 원인부터 재작업. 프로세스를 죽이거나 사용자 파일을 지우지는 않습니다 |

사용자 데이터 삭제, 파일 훼손, 토큰 낭비는 어떤 경우에도 형벌이 될 수 없습니다.

## 우리 팀 법 만들기

```text
> QA팀용 AI법 만들어줘. AI가 자꾸 flaky 테스트를 통과로 처리해.
```

`ai-lawmaker` 가 세 가지(무엇이 잘못되는지, 무엇으로 확인하는지, 절대 넘으면 안 되는 선)를 묻고,
가장 가까운 내장 법을 선례로 표준 골격에 맞춰 초안을 쓰고, 심사한 뒤 시행할지 물어봅니다.

## 개인정보

모든 데이터는 내 컴퓨터에만 있습니다.

- 주입 훅은 `~/.claude/ai-lawbook/enabled-laws`, `~/.claude/ai-lawbook/confessions.md`, 법 파일(`SKILL.md`)만
  읽습니다. guard 훅은 `~/.claude/ai-lawbook/confessions.md` 와, 검사하는 그 호출에 대해 Claude Code 가 넘겨준
  내용(Bash 명령·출력, 응답)만 읽습니다. 두 훅 모두 네트워크 요청을 하지 않고 어디로도 데이터를 보내지 않습니다.
- `- 검사: 비밀값` 줄이 있으면 guard 훅이 Bash 출력에서 비밀값으로 보이는 부분을 가립니다. 패턴으로
  찾으므로 놓치는 형식이 있습니다. 비밀값을 출력해도 된다는 뜻이 아닙니다.
- 반성문 장부는 언제든 열어 보고, 고치고, 지울 수 있는 평범한 마크다운 파일입니다. AI가 자기 위반에 대해
  쓴 내용만 담기며, 대화 기록은 저장하지 않습니다.
- 장부는 모든 프로젝트가 공유하므로, 모든 법이 장부에 비밀키·토큰·개인정보·고객명·사내 기밀을 적지 말고
  상황을 일반화해 쓰도록 금지합니다.

## FAQ

**법률 자문인가요?** 아닙니다. 실제 법령은 주의 환기용으로만 언급하며, 모든 법이 변호사·노무사
등 전문가 검토가 필요한 지점을 AI가 밝히도록 요구합니다.

**왜 시스템 프롬프트가 아니라 훅인가요?** 지시는 건너뛸 수 있지만 훅은 하네스가 실행합니다.
시행 명부의 법은 첫 토큰 전에 컨텍스트에 들어갑니다.

**컨텍스트가 꽉 차지 않나요?** 정해진 만큼만 들어갑니다. 훅은 주입을 9,000자(하위 에이전트 6,000자)
안에 맞추고, 시행 중인 법은 그 안에 맞게 축약됩니다. 시행하지 않은 법은 필요할 때만 불러옵니다. 턴마다
더해지는 것은 최다 전과 한 줄(200자 이하)뿐입니다. 장부는 항목마다 제목·재범·시정·규칙 줄만 재범 많은 순으로
3,500자(하위 에이전트 3,000자)까지 넣고 나머지는 건수만 알리므로, 장부가 6,000자를 넘거나 300자를 넘는 줄이
생기면 `ai-lawmaker` 가 정리(중복 병합, 오래된 경미 항목 보관)를 제안합니다.

**한국어판·영어판을 같이 써도 되나요?** 하나만 쓰세요. 장부가 두 번 주입됩니다.

## 기여

새 직무 법을 환영합니다. `ai-lawmaker` 로 초안을 쓰고, `plugins/ai-lawbook`(한국어)과
`plugins/ai-lawbook-en`(영어)을 같은 조 번호로 함께 올린 뒤 다음을 실행하세요.

```bash
bash tests/run.sh
```

## 라이선스

[MIT](LICENSE)

<p align="center">
  <sub>AI가 "확인했습니다"라고 거짓말한 적이 있다면, ⭐ 하나가 그 AI에게 내리는 판결입니다.</sub>
</p>

<p align="center">
  <a href="https://star-history.com/#jinyeong03/ai-lawbook&Date"><img src="https://api.star-history.com/svg?repos=jinyeong03/ai-lawbook&type=Date" width="560" alt="Star history"></a>
</p>
