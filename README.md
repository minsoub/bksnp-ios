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
#### 기능 리스트
- 아래 함수는 사용하지 않음.
```shell
    function CallCamera() {
        //window.bksnp.callCamera();
        window.webkit.messageHandlers.camera.postMessage('test1');
    }
    function CallAlbum() {
        //window.bksnp.callAlbum();
        window.webkit.messageHandlers.album.postMessage('test2');
    }
```

- 스토리지 저장하기
```shell
    function callWriteStorage(fileKey, data) {
        var Data = {
            'fileKey': fileKey,
            'data': data
        };
        window.webkit.messageHandlers.storage.postMessage(Data);
    }
```
- 스토리지 읽기
```shell
    function callReadStorage(fileKey) {
        window.webkit.messageHandlers.storage.postMessage(fileKey);
    }
    // 안드로이드 storage 파일의 read가 완료되었을 때 호출되는 메소드
    function setReadStorage(data) {
        console.log(data);
        alert(data);
    }    
```
- Device Key read
```shell
    // Device Key read
    function callDeviceKey() {
        window.webkit.messageHandlers.device.postMessage('');
        //window.bksnp.callDeviceKey();
    }
    function setDeviceKey(deviceId) {
        alert(deviceId);
        console.log(deviceId);
    }
```

- 아이폰에 Notification이 도착했을 때 호출
```shell    
    // Notification recieved data
    function receiveNotification(msg) {
        alert(msg);
        console.log(msg);
    }
```
- Cache write
```shell    
    // Cache write
    function callCacheFileWrite(fileKey, data) {
        var requestData = {
            'fileKey': fileKey,
            'data': data
        };
        window.webkit.messageHandlers.cache.postMessage(requestData);
    }
```
- Cache read
```shell
    // Cache read
    function callCacheFileRead(fileKey) {
        window.webkit.messageHandlers.cache.postMessage(fileKey);
    }
    // iphone에서 cache를 읽었을 때 호출
    function setReadCache(data) {
        console.log(data);
        alert(data);
    }
```
- Base64 data save
```shell
    // Base64 encoding data save
    function callBase64Save(fileKey, data) {
        var requestData = {
            'fileKey': fileKey,
            'data': data
        };
        window.webkit.messageHandlers.base64.postMessage(requestData);
    }
```
- Base64 data read
```shell
    // Base64 encoding data read
    function callBase64Read(fileKey) {
        window.webkit.messageHandlers.base64.postMessage(fileKey);
    }
    // iphone에서 cache를 읽었을 때 호출
    function setReadBase64(data) {
        console.log(data);
        //alert(data);
    }
```
- Firebase Token data get
```shell    
    // token data call
    function TokenData() {
        window.webkit.messageHandlers.token.postMessage('');
    }
    function setTokenData(data) {
        console.log(data);
        alert(data);
    }
```
- SNS 공유 요청하기
```shell
    // share
    function ShareLink() {
        var requestData = {
            'subject': '친구에게 공유하기',
            'link': 'http://teengle.co.kr',
            'image_link': 'https://backlog.com/git-tutorial/kr/img/post/stepup/capture_stepup2_3_2.png'
        };
        window.webkit.messageHandlers.share.postMessage(requestData);
    }
```

