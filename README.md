# MyTJ Updates

MyTJ Android 앱의 업데이트 배포용 저장소입니다.

## 고정 업데이트 manifest 주소

`https://github.com/noveljelly/MyTJ-Updates/releases/latest/download/update.json`

MyTJ의 Cloudflare Worker에서 위 주소를 `UPDATE_MANIFEST_URL`로 사용합니다.

## 배포 구조

각 앱 버전은 GitHub Release로 배포하며 Release asset에는 다음 파일을 둡니다.

- `update.json` — 앱이 읽는 최신 버전 정보
- APK 파일 — 실제 설치 파일

`update.json`의 필드 구조는 MyTJ 앱/Worker 소스가 요구하는 형식을 확인한 뒤 확정합니다. 잘못된 manifest가 최신 Release로 노출되지 않도록 임의 형식의 파일은 게시하지 않습니다.
