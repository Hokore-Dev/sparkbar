# X / Twitter 게시 초안 — SparkBar

> 역할: **증폭 채널** (Claude/Anthropic 개발자 커뮤니티) + Show HN 런치 동반.
> 원칙: 실제 얼굴 프사 / 제품명 박은 bio / 단일 트윗+GIF / 링크는 첫 댓글 / 해시태그 1개.

---

## 알고리즘 현실 (2024~2026, 행동 지침)

- **본문 링크 = 도달 거의 0 (비-Premium).** → 링크는 **첫 답글**에. (2025-10 정책 일부 완화됐으나 불안정, 안전하게 첫 답글 유지)
- **답글(reply) 가중치가 압도적.** 좋아요(+0.5)보다 답글(+13.5), 답글에 작성자가 또 답하면(+75). → 답글 유발 훅 + 빠른 응답이 핵심.
- **미디어 > 텍스트 > 링크.** "영상 10배" 같은 마법 배수는 근거 없음 — dwell time과 답글이 진짜 레버. <6초 루핑 GIF가 최적.
- **Premium이 도달 ~10배** (median impressions: 무료 <100 / Premium ~600 / Premium+ >1,550) — 유료가 사실상 가장 확실한 레버.
- 해시태그 3개 이상 = 스팸 분류기 + 도달 ~40% 감소. **`#ClaudeCode` 1개만.**

## (a) Bio (계정: @hokore_) — 정통 OSS 개발자 톤, 제품 무관

```
Makes small macOS & iOS apps and Claude/AI tooling. Long-time game developer. Based in Seoul.
```
- **톤 원칙 (sindresorhus / antirez / tpope 참고):** 만드는 것을 *현재형·사실*로. "shipping in public 👇" 같은 그로스 훅, 팔로워 유도 이모지, 회사명 플렉스 전부 뺀다. 작업물로 말한다.
- **프사는 실제 얼굴.** 제품 전용 계정 아님 — 제품 키워드는 **고정 트윗**이 짊어진다.
- **Website 필드 = 포트폴리오(`hokore-dev.github.io`)**. 런치 주간엔 고정 트윗이 리포 링크 담당.
- 신뢰 이력(VRECORD CTO 등)은 bio가 아니라 고정글/Show HN 자기소개에서 자연스럽게 한 줄.

## (b) 런치 트윗 (단일, 데모 GIF 첨부)

```
I kept blowing past my Claude Code limit mid-task with zero warning.

So I built SparkBar — a tiny macOS menu bar app that shows your session + weekly
usage live, at a glance.

Native, free, open source. ⭐ it if it saves you a surprise cutoff 👇

[attach <6s 루핑 GIF: 메뉴 바 → 사용량 바 차감 → 한도 경고]
```

**첫 답글 (← 링크는 여기):**
```
GitHub (install + source): https://github.com/Hokore-Dev/sparkbar
Built in Swift, no telemetry, no account. Feature requests welcome in the replies 👇
```

## (c) 대안: 런치 스레드 (5트윗)

**1/ (훅 + GIF)**
```
Every Claude Code power user knows the feeling: deep in a task, and suddenly —
limit hit, no warning.

I built SparkBar so that never surprises you again. 🧵
[데모 GIF]
```
**2/ (문제)**
```
Claude Code shows usage somewhere, but not where you actually work. You context-switch,
you guess, you get cut off mid-flow.

I wanted my remaining session + weekly budget visible the same place I check the time:
the menu bar.
```
**3/ (솔루션 + 기능)**
```
SparkBar sits in your macOS menu bar and shows:
• Live session usage
• Weekly limit progress
• A heads-up before you hit the wall

Native Swift, lightweight, no account, no telemetry.
[두 번째 스크린샷: 드롭다운 상세]
```
**4/ (왜 무료/OSS + 신뢰)**
```
It's free and fully open source. I built it for myself first and use it every day.
Code's all there — audit it, fork it, send PRs. Roadmap is public.
```
**5/ (CTA)**
```
If a surprise cutoff has ever wrecked your flow, give it a try.
⭐ the repo, and tell me what you'd add 👇
(↳ GitHub 링크는 이 트윗 아래 답글에)
```

## (d) 고정 트윗 (Pinned)

평상시: **에버그린 데모 포스트** — 같은 <6s GIF + 한 줄 `"Your Claude Code usage & limits, live in your macOS menu bar. Free & open source."` + 별/설치 수(생기면). 링크는 첫 답글.
런치 주간만: 런치 트윗 고정 → 끝나면 에버그린으로 복귀.

## (e) 사전 워밍업용 답글 오프너 5종 (#ClaudeCode 대화에 진심 답글)

> 복붙 스팸 금지. 맥락 맞을 때만. 목표: 유용한 답글 → 프로필 클릭 → 팔로우.

1. ("또 한도 터졌다" 글에) *"The lack of a heads-up before the cutoff is the worst part — I started tracking mine in the menu bar just so I'd stop getting blindsided mid-task. Curious how others budget their weekly limit?"*
2. (워크플로/팁 스레드에) *"One that saved me a ton of frustration: keeping session + weekly usage visible at all times instead of finding out the hard way. Pacing matters more than people expect on the weekly cap."*
3. (Claude Code vs Cursor/Codex 비교에) *"Honestly the usage-limit transparency is an underrated axis here — Claude Code's limits are generous but invisible until you're against them. Anyone else wish the remaining budget was just… always on screen?"*
4. (Anthropic 기능요청/릴리스 스레드에) *"+1 on surfacing usage more clearly. In the meantime I've been keeping mine in the macOS menu bar — having the number always visible completely changed how I pace longer sessions."*
5. ("내 dev 메뉴 바 셋업" 글에) *"My menu bar essentials for AI coding: clipboard manager, a timer, and a live Claude Code usage readout so I never get cut off mid-flow. The usage one was the biggest QoL jump."*

## 런치 시퀀스 (Show HN 동반)

1. **~9 AM ET (12~17 UTC)** — 메인 트윗: GIF + 훅 + 소프트 CTA. 링크는 첫 답글.
2. 바로 reply-thread 추가: 문제 → 동작 방식 → 기술 스택 → 로드맵.
3. **Show HN 제출** (같은 UTC 창). 제목 예: `Show HN: SparkBar – Claude Code usage limits in your macOS menu bar (free, open source)`
4. Claude Developers Discord / claudecode.community / r/ClaudeAI / awesome-claude 리스트에 교차 공유.
5. 첫 1시간 모든 댓글 응답. 초기 지지자에게 리셰어 요청.
6. **D+1** — "설치/별 수 결과" 후속 트윗 (Karpathy식 launch+results 패턴).

## 태그 주의
- @AnthropicAI 무차별 태그 X. 대신 **"Claude Code 한도 불평 실제 스레드"를 인용(QT)** 하며 "I built the thing this thread is asking for."
- 커뮤니티 계정 **@claude_code** (서드파티 프로젝트 공유 목적)는 정당한 노출 창구.

---
## 출처
X 오픈소스 랭킹 가중치(github.com/twitter/the-algorithm-ml) · Buffer Premium 도달 연구(18.8M posts) · Buffer links-on-X · Musk 2024-11 "link in reply" · X Grok 랭커 오픈소스 2026-01 · arXiv 2511.04453(HN→GitHub stars) · CMU fake-star 연구
⚠️ 라이브 X 프로필/트윗은 봇 차단 — 게시 전 현재 문자열 직접 확인.
