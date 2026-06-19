# Threads 게시 초안 — SparkBar

> 역할: **보조 채널 (~15~20% 노력)** — build-in-public 지속용. 출시 1순위 아님.
> 원칙: 대화체/질문형(X 톤 금지) / 링크는 첫 답글 / 토픽 태그 1개 / 답글이 도달 엔진.

---

## 플랫폼 성격 (정직한 판정)

- **톤이 X와 정반대.** X = 빠르고 단정적, Threads = 느리고 호기심·대화 중심. X식 단정 선언·번호 메가스레드는 묻힘. **개인적 관찰 + 질문**이 먹힘.
- **답글이 핵심 엔진.** Mosseri: "성장하려면 게시보다 답글을 훨씬 많이 하라." 첫 ~60분 본인 답글이 글 수명 연장.
- **링크는 본문에 넣으면 도달 억제** → 첫 답글로. (X와 동일 패턴, Threads에선 더 자연스러움)
- **토픽 태그 1개** (# 없이, 스택 금지). 같은 콘텐츠가 X보다 도달 2~3배 (경쟁 적음).
- **판정: 정당한 보조 채널.** 단위 노력당 유기 도달은 X보다 높지만 구매 의도는 X/HN/Reddit/GitHub가 더 강함. → 출시 1순위로 삼지는 말 것. **노력 ~15~20%.**

## (a) Bio 추천 — 정통 OSS 개발자 톤 (제품 무관)
```
Makes small macOS & iOS apps and Claude/AI tooling. Long-time game developer. Based in Seoul.
🔗 hokore-dev.github.io
```
- 만드는 것을 사실로 서술 (sindresorhus 스타일). 그로스 훅·플렉스 없음.
- Instagram 계정 연결 필수. **bio 링크 = 포트폴리오**(여러 프로젝트 허브). 개별 제품 링크는 각 포스트 첫 댓글로.

## (b) 런치 포스트 (영문, Threads 네이티브 톤)
```
I kept blowing through my Claude Code limit mid-task and never knew until it just… stopped.

So I built a tiny menu-bar app that shows my session + weekly usage at a glance. Glance up,
see how much I've got left, keep going.

It's free and open source. Mac only.

What do you all use to keep an eye on your usage right now? 👇

[이미지/GIF: 메뉴 바 pill 카운트다운]
```
**첫 답글:** `Repo's here if you want it: github.com/Hokore-Dev/sparkbar — would love feedback / issues.`

구조: 페인 훅 → 무엇인지 → 캐주얼 고지 → 진짜 질문 → 링크는 답글.

## (c) 한국어 변형 (네이티브 1발 실험 가치 있음)
```
Claude Code 쓰다가 한도 다 쓴 줄도 모르고 작업하다 멈춰버린 적, 저만 그런가요 😅

그래서 메뉴바에서 세션/주간 사용량 바로 보이는 작은 앱을 만들었어요. 위로 슬쩍 보고
남은 양 확인하고 계속 작업.

무료에 오픈소스예요. 맥 전용입니다.

다들 사용량 어떻게 체크하세요? 👇

[이미지/GIF]
```
**첫 댓글:** `깃허브 링크예요: github.com/Hokore-Dev/sparkbar — 피드백/이슈 환영합니다 🙏`

> 번역체 금지, 네이티브 `~요` 대화체. 1발만 던지고 트랙션 있으면 더블다운. (KR Threads에 개발/인디 메이커 활동 실재)

## (d) 후속 build-in-public 아이디어
1. **결정 공유 (공지 아님):** *"Spent the evening deciding whether the menu bar should show a number or a bar. Went with a bar — a number made me anxious every time I looked up. Tiny thing, big difference. Numbers or bars for stuff like this?"* (+스크린샷)
2. **실제 유저 반응:** *"Someone opened an issue asking for a weekly-reset countdown and honestly it's a better idea than what I shipped. Adding it this weekend. This is why I build in public."* (+이슈 스샷)
3. **공감 페인 (제품 상단 노출 X):** *"Genuinely the most-checked number in my day is now 'how much Claude Code do I have left.' When did usage limits become a personality trait 😅"* — SparkBar는 댓글에서 자연 노출.

## (e) 노력 배분 판정
- **출시 1순위:** X / Show HN / Reddit r/ClaudeAI / GitHub README·topics.
- **Threads = 강한 보조, 저~중 노력.** 최적 ROI는 *지속 build-in-public*: 주 2~4회 대화형 글 + 매일 답글. 한 포스트가 터지면 그때 더블다운.

---
## 출처
recurpost(Threads 알고리즘) · Postory(2026 works/flops) · PostEverywhere(viral/algorithm) · Conbersa(Threads vs X) · QuickCreator · Sendible · TECHsWILL(Threads API) · LinkedIn/Brunch(KR Threads 전략)
⚠️ 라이브 페이지 봇 차단 — 게시 전 현재 UI/규칙 직접 확인.
