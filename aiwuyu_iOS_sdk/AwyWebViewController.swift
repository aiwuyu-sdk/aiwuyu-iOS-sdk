//
//  WYWebViewController.swift
//  aiwuyu_iOS_sdk
//
//  Created by QC on 2019/4/9.
//  Copyright © 2019 awy. All rights reserved.
//

import UIKit
import WebKit


class AwyWebViewController: UIViewController {
    
    
    static let userAgent:String = "Mobile/\(AwySDK_iPhoneType) AwySDK/\(AwySDK_Version)"
    
    lazy var webView:WKWebView = {
        let config = WKWebViewConfiguration()
        let pref = WKPreferences()
        pref.javaScriptEnabled = true
        pref.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = pref
        config.userContentController = WKUserContentController()
        let web = WKWebView(frame: CGRect(x: 0, y: Awy_NavTopHeight, width: Awy_Screen_Width, height: Awy_Screen_Height-Awy_TabBarHeight), configuration: config)
        web.uiDelegate = self
        web.navigationDelegate = self
        return web
    }()
    
    lazy var progressView:UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.isHidden = false
        progress.tintColor = Awy_Color01
        progress.frame = CGRect(x: 0, y: Awy_NavTopHeight, width: Awy_Screen_Width, height: 2)
        progress.setProgress(0.5, animated: true)
        return progress
    }()
    var authInfo:(()->Void)?
    
    var isToLogin = false
    var rightItemFuncName = ""
    var currentPageUrl = ""
    let urlString:String
    public init(_ url:String) {
        urlString = url
        currentPageUrl = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let v = UIView()
        view.addSubview(v)
        if #available(iOS 11.0, *){
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }else{
            self.automaticallyAdjustsScrollViewInsets = false
        }
        setLeftNav()
        view.backgroundColor = UIColor.white
        view.addSubview(webView)
        
        view.addSubview(progressView)
        
        addObserver()
        if let url = URL(string: urlString){
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            webView.load(request)
        }
        
        AwySDK.log("进入SDK Web")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isToLogin {
            isToLogin = false
            
            if AwySDK.shared.delegate?.isAppAuth?() == true{
                AwyUnionAuth.shared.getUserInfo {[weak self] in
                    
                    self?.authInfo?()
                }
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AwyUnionAuth.shared.stopTimer()
        
    }
    
    
    func setLeftNav()  {
        
        let left = UIBarButtonItem(image: awy_image("btn_arrow_left_black@2x")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backClick))
        let close = UIBarButtonItem(image: awy_image("btn_navi_close@2x")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(closeClick))
        
        self.navigationItem.leftBarButtonItems = [left,close]
    }
    
    @objc func backClick()  {
        if webView.canGoBack{
            webView.goBack()
        }else{
            let newUserAgent = AwySDK.shared.appUserAgent
            let dic = ["UserAgent":newUserAgent]
            UserDefaults.standard.register(defaults: dic)
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    @objc func closeClick(){
        let newUserAgent = AwySDK.shared.appUserAgent
        let dic = ["UserAgent":newUserAgent]
        UserDefaults.standard.register(defaults: dic)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func setErrorView()  {
        if let _ = self.view.viewWithTag(6666) as? AwyNetErrorView {
            return
        }
        let errorView = AwyNetErrorView(frame: self.view.bounds)
        errorView.tag = 6666
        errorView.resetClick = { [weak self] in
            guard let self = self else {
                return
            }
            if let url = URL(string: self.currentPageUrl){
                var request = URLRequest(url: url)
                request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                self.webView.load(request)
            }
            
        }
        self.view.addSubview(errorView)
    }
    
    
    func addObserver()  {
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
            self.progressView.isHidden = false
            if self.progressView.progress == 1{
                self.progressView.isHidden = true
            }
        }else if keyPath == "title"{
            self.title = self.webView.title
        }
    }
    
    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView.removeObserver(self, forKeyPath: "title")
        AwyUnionAuth.shared.userId = ""
        AwyUnionAuth.shared.token = ""
        AwyUnionAuth.shared.stopTimer()
    }
    
    
    func setRightItem(_ title:String,funcName:String)  {
        rightItemFuncName = funcName
        
        setRightButton { () -> UIBarButtonItem in
            let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(AwyWebViewController.rightItemAction))
            return item
        }
        
    }
    
    func setRightItem(_ image:UIImage?,funcName:String)  {
        rightItemFuncName = funcName
        setRightButton { () -> UIBarButtonItem in
            let img = image?.resizeImage(20)?.withRenderingMode(.alwaysOriginal)
            let item = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(AwyWebViewController.rightItemAction))
            return item
        }
    }
    
    private func setRightButton(item:(()->UIBarButtonItem)?) {
        
        self.navigationItem.rightBarButtonItem = item?()
        
    }
    
    
    @objc func rightItemAction() {
        guard rightItemFuncName != "" else {
            return
        }
        invokeJS(rightItemFuncName)
    }
    
    func invokeJS(_ jsFuncName:String)  {
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(jsFuncName, completionHandler: { (result, error) in
                
            })
        }
    }
    
    func toToast(_ str:String)  {
        guard str != "" else {
            return
        }
        DispatchQueue.main.async {
            let size = str.sizeOfFont(14, Awy_Screen_Width - 60)
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: size.width+20, height: size.height+20))
            label.center = self.view.center
            label.textColor = UIColor.white
            label.text = str
            label.textAlignment = .center
            label.numberOfLines = 0
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            label.backgroundColor = UIColor(0x000000).withAlphaComponent(0.7)
            self.view.addSubview(label)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                guard let _ = self else {return}
                label.removeFromSuperview()
            }
        }
        
        
        
        
        
    }
    
}


extension AwyWebViewController:WKNavigationDelegate{
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        
        guard let url = navigationAction.request.url,let component = NSURLComponents(string: url.absoluteString) else{
            decisionHandler(.cancel)
            return
        }
        
        if component.scheme == "aiwuyu"{
            AwySDK.log("正在js交互url: \(url.absoluteString)")
            AwySchemeTool.urlAnalysis(urlString: url.absoluteString, webVC: self)
            
            decisionHandler(.cancel)
        }else if component.scheme != "http" && component.scheme != "https"{
            decisionHandler(.cancel)
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.openURL(url)
            }
        }else{
            currentPageUrl = url.absoluteString
            decisionHandler(.allow)
        }
        
    }
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error){
        self.setErrorView()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        self.setErrorView()
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            //适配https
            if let trust = challenge.protectionSpace.serverTrust, challenge.previousFailureCount == 0 {
                let credential = URLCredential(trust: trust)
                completionHandler(URLSession
                    .AuthChallengeDisposition.useCredential,credential)
            }else{
                completionHandler(URLSession
                    .AuthChallengeDisposition.cancelAuthenticationChallenge,nil)
            }
        }else{
            completionHandler(URLSession
                .AuthChallengeDisposition.cancelAuthenticationChallenge,nil)
        }
        
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';") { (result, error) in
            
            
        }
        
    }
    
    
}


extension AwyWebViewController:WKUIDelegate{
    //    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void){
    ////        print(111111)
    ////        completionHandler(nil)
    //    }
    //
    //    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void){
    ////        print(2222222)
    ////        completionHandler()
    //    }
    //    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void){
    ////        print(3333333)
    ////        completionHandler(true)
    //    }
}
