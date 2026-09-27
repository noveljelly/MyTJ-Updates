# MyTJ Updates

MyTJ Android 앱의 업데이트 배포용 저장소입니다.

## 고정 업데이트 manifest 주소

`https://github.com/noveljelly/MyTJ-Updates/releases/latest/download/update.json`

Cloudflare Worker의 `UPDATE_MANIFEST_URL`에는 위 주소를 사용합니다.

## update.json 형식

```json
{
  "schemaVersion": 1,
  "packageId": "com.example.mytj",
  "versionCode": 5,
  "versionName": "0.5.0",
  "apkUrl": "https://github.com/noveljelly/MyTJ-Updates/releases/download/v5/MyTJ-0.5.0-5.apk",
  "sha256": "<APK SHA-256 64자리>",
  "sizeBytes": 12345678,
  "minSdk": 26,
  "notes": "업데이트 내용"
}
```

APK URL은 `latest` 주소가 아니라 해당 버전 Release의 고정 URL이어야 합니다.

## 배포

저장소의 `publish-update.ps1`은 APK에서 SHA-256과 파일 크기를 계산하고 `update.json`을 생성한 뒤 GitHub Release에 APK와 manifest를 함께 올립니다.

예:

```powershell
.\publish-update.ps1 -ApkPath "C:\path\to\app-release.apk" -VersionCode 5 -VersionName "0.5.0" -Notes "테마 기능 및 사용성 개선"
```

앱은 다운로드한 APK의 패키지명, versionCode/versionName, minSdk, 파일 크기, SHA-256, 서명 인증서를 검증하므로 기존 설치본과 같은 서명 키를 유지해야 합니다.
