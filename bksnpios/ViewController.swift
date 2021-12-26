//
//  ViewController.swift
//  bksnpios
//
//  Created by hist on 2021/12/26.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler, UIImagePickerControllerDelegate  {
    private var wkWebView: WKWebView? = nil
    private var config: WKWebViewConfiguration? = nil
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.config = WKWebViewConfiguration.init()
        self.config?.userContentController = WKUserContentController.init()
        
        // * WKWebView JS -> iOS 핸들러 추가
        self.config?.userContentController.add(self, name: "camera")
        self.config?.userContentController.add(self, name: "album")
        self.config?.userContentController.add(self, name: "storage")
        self.config?.userContentController.add(self, name: "device")
        
        
        // * WKWebView 구성
        //    - 여기서는 self.view 화면 전체를 WKWebView로 구성하였습니다.
        //    - 추가로 설정한 WKWebViewConfiguration를 WKWebView 구성 시에 넣어 줍니다.
        self.wkWebView = WKWebView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), configuration: self.config!)
       
        // * WKWebView 화면 비율 맞춤 설정
        self.wkWebView?.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
 
        // * WKWebView 여백 및 배경 부분 색 투명하게 변경
        self.wkWebView?.backgroundColor = UIColor.clear
        self.wkWebView?.isOpaque = false
        self.wkWebView?.loadHTMLString("<body style=\"background-color: transparent\">", baseURL: nil)
           
        // * WKWebView에 로딩할 URL 전달
        //    - 캐시 기본 정책 사용, 타임아웃은 10초로 지정하였습니다.
//        let request: URLRequest = URLRequest.init(url: NSURL.init(string: "https://sosoingkr.tistory.com/19")! as URL, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
//
//        self.wkWebView?.load(request)
        
        self.wkWebView?.uiDelegate = self
        
        let data = Bundle.main.url(forResource: "index", withExtension: "html")!
        self.wkWebView?.loadFileURL(data, allowingReadAccessTo: data)
        let request = URLRequest(url: data)
        self.wkWebView?.load(request)
        
        
        // * WKWebView 화면에 표시
        self.view?.addSubview(self.wkWebView!)

    }
    
    // WKScriptMessageHandler : 등록한 헨들러가 호출될 경우 이벤트를 수신하는 함수
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        print("message name => \(message.name)")
        print("message body => \(message.body)")
        
        if (message.name == "camera") {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            
            present(imagePicker, animated: true, completion: nil)
        }else if(message.name == "album") {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            
            present(imagePicker, animated: true, completion: nil)
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
        }
    }
}

extension ViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "test", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            completionHandler()
        }
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "test", message: message, preferredStyle: .alert)
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
}


