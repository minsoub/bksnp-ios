#### 카메라 사용하기 위해서 
- Info 에서 Privacy-Camera Usage Description을 추가하고 Value에 Description 입력 (We need the camera permission)
#### iphone으로 테스트를 위해서 
- Xcode 메뉴에서 Preferece 메뉴를 선택하고 Account 등록 
-앱 배포시 설정 >> 일반 >> 기기관리에서 배포된 앱에 대해서 신뢰를 설정해야 한다. 
    
#### Apple 앱에 Firebase  추가하기
##### 앱등록 
- Apple Bundle ID :  bksnp.bksnpios
- App Name : BKSNP IOS
- App Store ID (Options) : App Store ID는 앱의 URL에서 확인
##### 구성파일 다운로드
- GoogleService-info.plist 다운로드 후 Xcode 프로젝트의 루트로 이동하여 대상 전체에 추가
       
##### Firebase SDK 추가
- Swift Package Manager를 사용해 Firebase 종속 항목을 설치하고 관리. 
- Xcode에서 File > Swift Pacakges > Add Package Dependency 로 이동 
- 메시지가 표시되면 Firebase iOS SDK 저장소 URL 입력 
- https://github.com/firebase/firebase-ios-sdk
- 사용할 SDK 버전 선택 
- 사용할 Firebase 라이브러리를 선택한다. 
- FirebaseAnalytics를 추가해야 한다. IDEA 수집 기능이 없는 애널리틱스의 경우 대신 FirebaseAnalyticsWithoutAdId를 추가한다. 
- Finish를 클릭하면 Xcode가 백그라운드에서 자동으로 종속 항목을 확인하고 다운로드하기 시작.
##### 초기화 코드 추가 

