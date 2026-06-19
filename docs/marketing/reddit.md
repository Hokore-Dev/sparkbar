# Reddit 게시 초안 — SparkBar

> 역할: **초기 별(star) 1순위 채널.** 정확한 타겟이 밀집.
> 원칙: 개인 핸들 / value-first 본문 / 링크는 첫 댓글 / 사이드바 규칙 게시 직전 재확인.

---

## 제목 옵션 (택1, 1번 추천)

1. `I kept blowing through my Claude Code session limit mid-task, so I built a free menu bar app that shows it at a glance [open source]`
2. `Made a tiny macOS menu bar app that shows your Claude Code session + weekly usage — free & open source`
3. `Tired of guessing how much Claude Code budget I had left, so I built SparkBar (native menu bar, MIT, no telemetry)`

→ **1번**: 개인 페인 훅 + 과장어 없음 + 무료/OSS 명시. r/ClaudeAI에 최적.

## 본문 (text-post, r/ClaudeAI value-first 톤)

```
The problem: I use Claude Code all day, and I kept getting surprised by my limits —
burning my 5-hour session budget halfway through a refactor, or not realizing I was
close to the weekly cap until it cut me off. There's no quick way to *see* where you
stand without breaking flow.

So I built SparkBar — a small native macOS menu bar app that just shows your Claude
Code usage at a glance:

- Current session usage (the rolling 5-hour window) right in the menu bar
- Weekly limit progress so you can pace longer projects
- A dropdown with the breakdown — no app to switch to, no browser tab

It's a tiny native Swift menu-bar app (lightweight, no Electron), and it's free and
open source — no account, no telemetry, nothing leaves your machine. I built it for
myself first, so it's deliberately minimal.

Honest current state: it's early (v0.x), the menu UI still has rough edges, and I'd
love sanity-checks on how it reads usage on different plans.

[hero GIF: 메뉴 바에 실제 session + weekly 숫자가 보이는 모습]

Question for heavy users: what's the one number you actually want glanceable —
session reset time, weekly remaining, or something the CLI doesn't surface at all?
Trying to keep it minimal but useful.
```

**첫 댓글 (작성자):**
```
Author here — repo + screenshots: https://github.com/Hokore-Dev/sparkbar
Free & MIT, no telemetry. Happy to answer anything, and feature requests welcome 👇
```

## 서브레딧 타겟 순서

1. **r/ClaudeAI** — 정확한 타겟, 최고 의도. 여기 먼저, 화~목 오전(ET). flair 필수 여부 / 주간 스레드 강제 여부 게시 전 확인.
2. **r/macapps** — 네이티브 메뉴 바 앱에 완벽. developer/showcase flair, "Showcase Saturday" 강제면 그날.
3. **r/SideProject** — 가장 관대, 별·피드백용. 2~4일 뒤 "혼자 만든 사이드 프로젝트" 앵글로 본문 재작성.
4. **r/opensource** — 무료/no-telemetry/MIT 앵글이 먹힘. 본문을 OSS·프라이버시 프레이밍으로 시작.
   - (r/programming은 구현 자체가 인상적일 때만 — 진입장벽 높음)

> ⚠️ 같은 글 복붙 금지. 서브레딧마다 본문 재작성 (복붙은 스팸 신호).

## 사전 체크리스트
- [ ] 개인 핸들 계정 (브랜드 핸들 X), r/ClaudeAI·r/macapps에서 1~2주 진심 댓글
- [ ] 계정 활동 중 홍보 비중 10% 미만
- [ ] 각 타겟 서브 사이드바 + flair + 주간 스레드 강제 여부 확인
- [ ] 리포: README 상단 GIF, 라이선스, 설치법, "no telemetry" 명시
- [ ] 메뉴 바에 실제 숫자 나오는 hero GIF
- [ ] 화~목 8~11 AM ET 게시 (서브가 주말 스레드 강제면 예외)
- [ ] 본문에 작성자 공개 + 무료/OSS 명시, 링크는 첫 댓글
- [ ] 게시 후 2~3시간 댓글 전부 응답 시간 확보

## 예상 비판 댓글 + 솔직한 대응

**1) "Claude Code CLI / `/status`가 이미 사용량 보여주잖아?"**
> Fair — the CLI does surface it, but you have to stop and run a command. SparkBar's
> whole point is glanceability: the number lives in your menu bar so you never break
> flow to check. If the CLI's view is enough for you, you genuinely don't need this.

**2) "어떻게 사용량을 읽지? 내 Anthropic 계정 스크래핑하거나 데이터 보내는 거 아냐?"**
> No account, no network calls to me — it reads the local Claude Code login on your
> machine and nothing leaves your Mac. It's open source so you can verify exactly what
> it touches: [link to source file]. If anything looks off, I want to know.

**3) "또 메뉴 바 앱? 그냥 스크립트로 하면 되는 거 아냐?"**
> Totally valid — a script works if you're comfortable wiring one up. This is for people
> who want it always-visible with zero setup. It's free and MIT, so if you'd rather fork
> the logic into your own script, the parsing code is right there to lift.

---
## 출처
- IndieHackers 500-subreddit/50k-post 분석 · MediaFast r/SideProject 플레이북 · shipwithai 4-step · ReplyAgent 자기홍보 규칙 · JetThoughts · Tereza Tizkova(best subreddits) · GummySearch r/ClaudeAI
- ⚠️ Reddit은 봇 차단이라 라이브 사이드바 규칙은 게시 직전 직접 확인 필수.
