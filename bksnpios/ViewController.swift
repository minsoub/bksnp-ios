//
//  ViewController.swift
//  bksnpios
//
//  Created by hist on 2021/12/26.
//

import UIKit
import WebKit
import Firebase
import FirebaseMessaging
import FirebaseDynamicLinks


class ViewController: UIViewController, WKScriptMessageHandler, UIImagePickerControllerDelegate, WKNavigationDelegate
{
    
    private lazy var imagePicker: ImagePickerProtocol = {
            let imagePicker = ImagePicker(parentViewController: self)
            return imagePicker
        }()
    
    private var wkWebView: WKWebView? = nil
    private var popupWebView: WKWebView? = nil
    private var config: WKWebViewConfiguration? = nil
    //var imagePicker = ImagePicker!  // UIImagePickerController()
    //let db = Database.database().reference()
    private var mToken: String?
    private var mPathName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            //self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
              self.mToken = token
          }
        }
        
        
        // Do any additional setup after loading the view.
        let wkPreferences = WKPreferences()
        wkPreferences.javaScriptCanOpenWindowsAutomatically = true
        
        self.config = WKWebViewConfiguration.init()
        self.config?.userContentController = WKUserContentController.init()
        self.config?.preferences = wkPreferences
        
        // * WKWebView JS -> iOS 핸들러 추가
        self.config?.userContentController.add(self, name: "camera")
        self.config?.userContentController.add(self, name: "album")
        self.config?.userContentController.add(self, name: "storage")
        self.config?.userContentController.add(self, name: "device")
        self.config?.userContentController.add(self, name: "cache")
        self.config?.userContentController.add(self, name: "base64")
        self.config?.userContentController.add(self, name: "token")
        self.config?.userContentController.add(self, name: "share")
        self.config?.userContentController.add(self, name: "dir")
        self.config?.userContentController.add(self, name: "appexit")
        self.config?.userContentController.add(self, name: "teengle")
        
        // * WKWebView 구성
        //    - 여기서는 self.view 화면 전체를 WKWebView로 구성하였습니다.
        //    - 추가로 설정한 WKWebViewConfiguration를 WKWebView 구성 시에 넣어 줍니다.
        self.wkWebView = WKWebView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), configuration: self.config!)
        //self.wkWebView = WKWebView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), configuration: self.config!)
        //self.wkWebView = WKWebView.init(frame: self.view.bounds, configuration: self.config!)
        
        
        self.wkWebView?.contentMode = .scaleToFill  //  .scaleAspectFill
        self.wkWebView?.sizeToFit()
        self.wkWebView?.autoresizesSubviews = true
        self.wkWebView?.configuration.allowsInlineMediaPlayback = true
        // * WKWebView 화면 비율 맞춤 설정
        //self.wkWebView?.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
 
        // * WKWebView 여백 및 배경 부분 색 투명하게 변경
        self.wkWebView?.backgroundColor = UIColor.clear
        self.wkWebView?.isOpaque = false
        //self.wkWebView?.loadHTMLString("<body style=\"background-color: transparent\">", baseURL: nil)
        self.wkWebView?.uiDelegate = self
        self.wkWebView?.allowsBackForwardNavigationGestures = true
        self.wkWebView?.navigationDelegate = self
                
        // * WKWebView에 로딩할 URL 전달
        //    - 캐시 기본 정책 사용, 타임아웃은 10초로 지정하였습니다.
        let request: URLRequest = URLRequest.init(url: NSURL.init(string: Constants.webURL)! as URL, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
        self.wkWebView?.load(request)
        
        
//        let data = Bundle.main.url(forResource: "index", withExtension: "html")!
//        self.wkWebView?.loadFileURL(data, allowingReadAccessTo: data)
//        let request = URLRequest(url: data)
//        self.wkWebView?.load(request)
        
        
        // * WKWebView 화면에 표시
        self.view?.addSubview(self.wkWebView!)

        
        NotificationCenter.default.addObserver(self, selector: #selector(userNotifyMessage(_:)), name: NSNotification.Name(Constants.firebaseNotificationNameKey), object: nil)
        
        handleFirebaseDynamicLink()
        addNotificationObserver()  // 여러가지 Notification의 observer를 등록한다.
        
        //self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        let fileManager = FileManager.default
        let filePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Teengle")
        if !fileManager.fileExists(atPath: filePath.path) {
            do {
                try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print("Couldn't create document directory")
            }
        }
        mPathName = filePath.lastPathComponent
        print(mPathName)
    }
    
    deinit {
        removeNotificationObserver()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("called.. test \(navigationAction.request.url)")
        
//        guard navigationAction.targetFrame?.isMainFrame != false else {
//            print("??/")
//                decisionHandler(.allow)
//                return
//            }
//
//        decisionHandler(.cancel)
//        return;
        guard let requestURL = navigationAction.request.url?.absoluteString else { return }

        if requestURL.contains("teengle.co.kr"){
            print("here1")
            decisionHandler(.allow)
        }
        else {
            print("here2")
            decisionHandler(.allow)
        }
//        if let host = navigationAction.request.url?.host {
//            if host == "www.apple.com" {
//                decisionHandler(.allow)
//                return
//            }
//        }
//
//        decisionHandler(.cancel)
    }
    
    private func handleFirebaseDynamicLink() {
        if let urlString = Constants.firebaseDynamicLink {
            
            self.wkWebView?.load(URLRequest(url: URL(string: urlString)!))
            Constants.firebaseDynamicLink = nil
        }
    }
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationReceived(notification:)), name: Notification.Name(rawValue: "clickFirebaseDynamicLink"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(onAppStatusReceived(notification:)), name: Notification.Name(rawValue: Constants.activateMessageKey), object: nil)
        
        
    }
    
    private func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "clickFirebaseDynamicLink"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.firebaseNotificationNameKey), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.activateMessageKey), object: nil)
    }
    
    @objc func onNotificationReceived(notification: Notification) {
        if let urlString = notification.object as? String {
            
            //self.wkWebView?.load(URLRequest(url: URL(string: urlString)!))
            
            self.wkWebView?.evaluateJavaScript("setDirectLink('"+urlString+"');", completionHandler: nil)
           
        }
    }
    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        webView.evaluateJavaScript("document.readyState", completionHandler: { (_, _) in
//          webView.invalidateIntrinsicContentSize()
//        })
//      }
    
    // App 상태 메시지를 받았을 호출되는 메소드
    @objc func onAppStatusReceived(notification: Notification) {
        if let data = notification.object as? String {
            print(data)
            if data == "activate" {
                self.wkWebView?.evaluateJavaScript("setActivate();", completionHandler: nil)
            }else {
                self.wkWebView?.evaluateJavaScript("setDeactivate();", completionHandler: nil)
            }
        }
    }
    
    @objc func userNotifyMessage(_ notification: Notification) {
        print("userNotifyMessage called..")
        let getValue = notification.object as! String
        print(getValue)
        self.wkWebView?.evaluateJavaScript("receiveNotification('"+getValue+"');", completionHandler: nil)
    }
    // WKScriptMessageHandler : 등록한 헨들러가 호출될 경우 이벤트를 수신하는 함수
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        print("message name => \(message.name)")
        print("message body => \(message.body)")
        
        // 카메라 앱 호출
        if (message.name == "camera") {
            imagePicker.startImagePicker(withSourceType: .camera) { [weak self] image in
                        //self?.imageView.image = image
                let imageData:NSData = image.jpegData(compressionQuality: 0.50)! as NSData  //mage.pngData()! as NSData
                let strBase64:String = imageData.base64EncodedString(options:  .init(rawValue: 0))  // .lineLength64Characters)
                
                var index = 0
                var readLength = 500000
                var readData: String = ""
                print(strBase64.count)  // 결과값이 3이 더 많다.. 고민해야됨
                var cnt = 0
                repeat {
                    
                    if (strBase64.count > (index + 499999)) {
                        readData = strBase64.substring(from: index, to: readLength)
                        //print(readData)
                        // script call
                        print(cnt)
                        cnt += 1
                        self?.wkWebView?.evaluateJavaScript("addCameraData('"+readData+"');", completionHandler: nil)
                        index = readLength
                        readLength += 500000
                    }else {
                        readData = strBase64.lastsubstring(from: index, to: strBase64.count-1)
                        //print(readData)
                        // script call
                        self?.wkWebView?.evaluateJavaScript("addCameraData('"+readData+"');", completionHandler: nil)
                        break
                    }
                } while (strBase64.count > index)
                
                self?.wkWebView?.evaluateJavaScript("setCameraData('');", completionHandler: nil)
            }
        }else if(message.name == "album") {
            //imagePicker.allowsEditing = true
            //imagePicker.sourceType = .photoLibrary
            
            //present(imagePicker, animated: true, completion: nil)
            imagePicker.startImagePicker(withSourceType: .photoLibrary) { [weak self] image in
                        //self?.imageView.image = image
                let imageData:NSData = image.jpegData(compressionQuality: 0.50)! as NSData  //mage.pngData()! as NSData
                let strBase64:String = imageData.base64EncodedString(options:  .init(rawValue: 0))  // .lineLength64Characters)
                
                var index = 0
                var readLength = 500000
                var readData: String = ""
                print(strBase64.count)
                var cnt = 0
                repeat {
                    if (strBase64.count > (index + 499999)) {
                        readData = strBase64.substring(from: index, to: readLength)
                        // script call
                        print(cnt)
                        cnt += 1
                        self?.wkWebView?.evaluateJavaScript("addAlbumData('"+readData+"');", completionHandler: nil)
                        index = readLength
                        
                        readLength += 500000
                    }else {
                        readData = strBase64.lastsubstring(from: index, to: strBase64.count-1)
                        // script call
                        self?.wkWebView?.evaluateJavaScript("addAlbumData('"+readData+"');", completionHandler: nil)
                        break
                    }
                } while (strBase64.count > index)
                
                self?.wkWebView?.evaluateJavaScript("setAlbumData('');", completionHandler: nil)
            }
        }else if(message.name == "storage") {
            if let getdata: [String: String] = message.body as? Dictionary {
                print("callWriteStorage called..")
                print("fileKey : " + getdata["fileKey"]!)
                print("data : " + getdata["data"]!)
                
                let defaults = UserDefaults.standard
                defaults.set(getdata["data"], forKey: getdata["fileKey"]!)
                
            }else {
                print("callReadStorage called..")
                print("fileKey : \(message.body)")
                
                // storage 읽어서 데이터를 javascript에 보낸다.
                let defaults = UserDefaults.standard
                if let readData = defaults.string(forKey: message.body as! String) {
                    self.wkWebView?.evaluateJavaScript("setReadStorage('"+readData+"');", completionHandler: nil)
                }else {
                    self.wkWebView?.evaluateJavaScript("setReadStorage('Not found data');", completionHandler: nil)
                }
            }
        }else if(message.name == "device") {
            let deviceid = UIDevice.current.identifierForVendor?.uuidString
            self.wkWebView?.evaluateJavaScript("setDeviceKey('"+deviceid!+"');", completionHandler: nil)
        }else if(message.name == "dir") {
            print("dirname => " + self.mPathName!)
            self.wkWebView?.evaluateJavaScript("setDirectory('"+self.mPathName!+"');", completionHandler: nil)
        }else if(message.name == "appexit") {
            print("app exit call")
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }else if(message.name == "cache") {
            print("cache called......")
            print(message.body)
            if let getdata: [String: String] = message.body as? Dictionary {
                print("callCacheFileWrite called..")
                print("fileKey : " + getdata["fileKey"]!)
                print("data : " + getdata["data"]!)
                
                let fileManager = FileManager.default
                let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
                let cachesDirectoryUrl = urls[0]
                let fileUrl = cachesDirectoryUrl.appendingPathComponent(getdata["fileKey"]!)
                let filePath = fileUrl.path
                if !fileManager.fileExists(atPath: filePath) {  // 파일이 존재하지 않으면..
                    //let contents = getdata["data"]
                    let contents: Data? = getdata["data"]?.data(using: .utf8)
                    
                    fileManager.createFile(atPath: filePath, contents: contents)
                }else {
                    let contents: Data? = getdata["data"]?.data(using: .utf8)
                    
                    fileManager.createFile(atPath: filePath, contents: contents)
                }
                //let defaults = UserDefaults.standard
                //defaults.set(getdata["data"], forKey: getdata["fileKey"]!)
                
            }else {
                print("callCacheFileRead called..")
                print("fileKey : \(message.body)")
                
                let fileManager = FileManager.default
                let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
                let cachesDirectoryUrl = urls[0]
                let fileUrl = cachesDirectoryUrl.appendingPathComponent(message.body as! String)
                do {
                    let text = try String(contentsOf: fileUrl, encoding: .utf8)
                    print(text)
                    self.wkWebView?.evaluateJavaScript("setReadCache('"+text+"');", completionHandler: nil)
                }catch let e {
                    print(e.localizedDescription)
                    self.wkWebView?.evaluateJavaScript("setReadCache('Not found data');", completionHandler: nil)
                }
            }
        }else if(message.name == "base64") {
            print("base64 called......")
            print(message.body)
            if let getdata: [String: String] = message.body as? Dictionary {
                print("callBase64Save called..")
                print("fileKey : " + getdata["fileKey"]!)
                print("data : " + getdata["data"]!)
                
                let fileManager = FileManager.default
                let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
                let cachesDirectoryUrl = urls[0]
                let fileUrl = cachesDirectoryUrl.appendingPathComponent(getdata["fileKey"]!)
                let filePath = fileUrl.path
                if !fileManager.fileExists(atPath: filePath) {  // 파일이 존재하지 않으면..
                    //let contents = getdata["data"]
                    let contents: Data? = getdata["data"]?.data(using: .utf8)
                    
                    fileManager.createFile(atPath: filePath, contents: contents)
                }else {
                    let contents: Data? = getdata["data"]?.data(using: .utf8)
                    
                    fileManager.createFile(atPath: filePath, contents: contents)
                }
                //let defaults = UserDefaults.standard
                //defaults.set(getdata["data"], forKey: getdata["fileKey"]!)
                
            }else {
                print("callBase64Read called..")
                print("fileKey : \(message.body)")
                
                let fileManager = FileManager.default
                let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
                let cachesDirectoryUrl = urls[0]
                let fileUrl = cachesDirectoryUrl.appendingPathComponent(message.body as! String)
                do {
                    let text = try String(contentsOf: fileUrl, encoding: .utf8)
                    print(text)
                    self.wkWebView?.evaluateJavaScript("setReadBase64('"+text+"');", completionHandler: nil)
                }catch let e {
                    print(e.localizedDescription)
                    self.wkWebView?.evaluateJavaScript("setReadBase64('Not found data');", completionHandler: nil)
                }
            }
        // Teengle directory
        }else if(message.name == "teengle") {
            print("teengle directory base64 called......")
            print(message.body)
            if let getdata: [String: String] = message.body as? Dictionary {
                print("teengle directory callBase64Save called..")
                print("fileKey : " + getdata["fileKey"]!)
                print("data : " + getdata["data"]!)
                
                let fileManager = FileManager.default
                let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Teengle")
                let fileUrl = urls.appendingPathComponent(getdata["fileKey"]!)
                let filePath = fileUrl.path
                print("filePath =>\(filePath)")
                if !fileManager.fileExists(atPath: filePath) {  // 파일이 존재하지 않으면..
                    //let contents = getdata["data"]
                    let contents: Data? = getdata["data"]?.data(using: .utf8)
                    
                    fileManager.createFile(atPath: filePath, contents: contents)
                }else {
                    let contents: Data? = getdata["data"]?.data(using: .utf8)
                    
                    fileManager.createFile(atPath: filePath, contents: contents)
                }
                
            }else {
                print("teengle callBase64Read called..")
                print("fileKey : \(message.body)")
                
                let fileManager = FileManager.default
                let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Teengle")
                let fileUrl = urls.appendingPathComponent(message.body as! String)
                let filePath = fileUrl.path
                print("fileUrl =>\(fileUrl)")
                print("filePath =>\(filePath)")
                do {
                    let text = try String(contentsOf: fileUrl, encoding: .utf8)
                    print(text)
                    self.wkWebView?.evaluateJavaScript("setTeengleReadBase64('"+text+"');", completionHandler: nil)
                }catch let e {
                    print(e.localizedDescription)
                    self.wkWebView?.evaluateJavaScript("setTeengleReadBase64('Not found data');", completionHandler: nil)
                }
            }
        }else if(message.name == "token") {
            self.wkWebView?.evaluateJavaScript("setTokenData('"+mToken!+"');", completionHandler: nil)
        }else if(message.name == "share") {
            if let getdata: [String: String] = message.body as? Dictionary {
                print("share called..")
                print("subject : " + getdata["subject"]!)
                print("link : " + getdata["link"]!)
                print("image_link : " + getdata["image_link"]!)
                
                // dynamiclink를 통한 공유하기
                let link = URL(string: getdata["link"]!)
                let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: Constants.dynamicLinkDomainUrl)  // "https://ohnion.page.link")
                                
                // iOS 설정
                referralLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: "bksnp.ohnion")
                referralLink?.iOSParameters?.minimumAppVersion = "1.0.1"
                referralLink?.iOSParameters?.appStoreID = Constants.appStoreID  // "1440705745" //나중에 수정하세요
                                                           
                // Android 설정
                referralLink?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.bksnp")
                referralLink?.androidParameters?.minimumVersion = 811
                
                // Social
                referralLink?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
                referralLink?.socialMetaTagParameters?.title = getdata["subject"]!
                referralLink?.socialMetaTagParameters?.imageURL = URL(string: getdata["image_link"]!)
                
                // 단축 URL 생성
                referralLink?.shorten { (shortURL, warnings, error) in
                   if let error = error {
                       print(error.localizedDescription)
                           return
                    }
                    print(shortURL)
                                       
                    var objectsToShare = [Any]()
                    objectsToShare.append(shortURL)
                    
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    activityVC.popoverPresentationController?.sourceView = self.view
                    self.present(activityVC, animated: true, completion: nil)
                 }
                
                ////////////////
            }
            
        }
    }
    
}

extension ViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Ohnion", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            completionHandler()
        }
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "Ohnion", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
            popupWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            popupWebView!.navigationDelegate = self
            popupWebView!.uiDelegate = self
            view.addSubview(popupWebView!)
            return popupWebView!
        
//        let loadUrl : String = navigationAction.request.url!.absoluteString
//
//        if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame == false {
//            webView.load(navigationAction.request)
//        }else {
//            if (loadUrl.contains("https://")) {
//                if #available(iOS 10.0,*) {
//                    if let aString = URL(string:(navigationAction.request.url?.absoluteString )!) {
//                        UIApplication.shared.open(aString, options:[:], completionHandler: { success in
//                        })
//                    }
//                } else {
//                    if let aString = URL(string:(navigationAction.request.url?.absoluteString )!) {
//                        UIApplication.shared.openURL(aString)
//                    }
//                }
//            } else {
//                if let aString = URL(string:(navigationAction.request.url?.absoluteString )!) {
//                    UIApplication.shared.openURL(aString)
//                }
//            }
//        }
//        print("here.......")
//        return nil
    }
    
//
//    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame == false {
//            webView.load(navigationAction.request)
//        }
//        return nil
//    }
    
    func webViewDidClose(_ webView: WKWebView) {
      if webView == popupWebView {
        popupWebView?.removeFromSuperview()
        popupWebView = nil
      }
    }
    
    func webViewDidFinishLoad(_ webView: WKWebView) {
         webView.frame.size.height = 1
         let height = webView.scrollView.contentSize.height
         var wvRect = webView.frame
         wvRect.size.height = height
         webView.frame = wvRect
    }
        
    
}

extension String {
    func substring(from: Int, to: Int) -> String {
      guard from < count, to >= 0, to - from >= 0 else {
          return ""
      }
                        
      // Index 값 획득
      let startIndex = index(self.startIndex, offsetBy: from)
      let endIndex = index(self.startIndex, offsetBy: to + 1) // '+1'이 있는 이유: endIndex는 문자열의 마지막 그 다음을 가리키기 때문
                        
      // 파싱
      return String(self[startIndex ..< endIndex])
    }
    
    func lastsubstring(from: Int, to: Int) -> String {
      guard from < count, to >= 0, to - from >= 0 else {
          return ""
      }
                        
      // Index 값 획득
      let startIndex = index(self.startIndex, offsetBy: from)
              
      // 파싱
      return String(self[startIndex ..< self.endIndex])
    }
}
