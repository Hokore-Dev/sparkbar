# 비주얼 자산 가이드 — SparkBar

> 데모 GIF 1개가 모든 채널 글의 성패 절반. **최우선 자산.**
> 세 채널 공통: 메뉴 바에서 사용량 바가 차감되고 한도 경고가 뜨는 **<6초 루핑 GIF**.

---

## 왜 자동화가 안 되나 (정직한 한계)

메뉴 바 팝오버는 **사용자가 직접 클릭해야 열리는 UI**라, 에이전트가 화면 녹화·클릭을 신뢰성 있게 재현하기 어렵습니다. 그래서 GIF 제작은 **사람 손 1~2분**이 필요합니다. 아래 절차/명령을 그대로 따라가면 됩니다.

## 1) 도구 설치 (택1)

현재 ffmpeg/gifski 둘 다 미설치 상태. GIF 변환에 하나 필요:

```bash
# gifski: 화질 최고 (추천)
brew install gifski

# 또는 ffmpeg: 범용
brew install ffmpeg
```

## 2) 화면 녹화 (macOS 내장)

1. SparkBar가 메뉴 바에서 **실제 숫자**를 보여주는 상태로 둔다 (Claude Code 로그인 필요).
2. `⇧⌘5` → "선택 부분 녹화" → 메뉴 바 아이콘 + 팝오버가 들어올 영역 지정.
3. 녹화 시작 → 아이콘 클릭으로 **팝오버 열기** → 세션/주간 게이지가 보이게 2~3초 → 녹화 종료.
4. 결과: `~/Desktop/화면 기록 ….mov`

> 팁: 임팩트를 위해 **사용량이 높은(주황/빨강) 상태**를 보여주는 게 페인을 잘 전달. 색 변화를 보여주려면 두 상태를 각각 짧게 녹화해 이어붙여도 됨.

## 3) MOV → GIF 변환

**gifski (추천, ~6초·고화질·소용량):**
```bash
# 먼저 mov에서 프레임 추출이 필요하면 ffmpeg 사용, 아니면 gifski가 mp4 직접 지원
gifski --fps 15 --width 900 -o sparkbar-demo.gif "input.mov"
```

**ffmpeg (팔레트 최적화로 깔끔한 GIF):**
```bash
ffmpeg -i input.mov -vf "fps=15,scale=900:-1:flags=lanczos,palettegen" palette.png
ffmpeg -i input.mov -i palette.png -vf "fps=15,scale=900:-1:flags=lanczos,paletteuse" sparkbar-demo.gif
```

- 목표: **<6초, 폭 ~900px, 2MB 내외**, 자연스러운 루프.
- 너무 크면 `--fps 12` / `scale=720`으로 줄이기.

## 4) 정지 스크린샷 (Reddit/README hero, X 2번째 이미지용)

```bash
# 인터랙티브 영역 선택 캡처 (팝오버 연 상태로)
screencapture -i ~/Desktop/sparkbar-popover.png
```
- 1장은 **메뉴 바 아이콘 클로즈업**, 1장은 **팝오버 전체(세션+주간 게이지)**.

## 5) 배치

- `docs/preview.svg`는 이미 README에 있음. 실제 GIF가 나오면 README 상단 hero로 추가/교체 고려.
- 마케팅 자산은 `docs/marketing/assets/`에 모으면 관리 편함 (예: `sparkbar-demo.gif`, `sparkbar-popover.png`).

## 채널별 자산 매핑
| 채널 | 1순위 | 2순위 |
|---|---|---|
| Reddit | hero GIF (본문 내) | 팝오버 스샷 |
| X | <6s 루핑 GIF (런치 트윗) | 드롭다운 스샷 (스레드 3/) |
| Threads | 메뉴 바 pill GIF | — |
| README | hero GIF (상단) | 팝오버 스샷 |

---
**상태:** ffmpeg/gifski 미설치 → 설치 후 위 절차로 1~2분 내 제작 가능. 녹화 단계만 사람 손 필요.
