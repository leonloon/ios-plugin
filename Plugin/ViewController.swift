//
//  ViewController.swift
//  Plugin
//
//  Created by Leon Mah Kean Loon on 26/12/2020.
//

import UIKit
import JavaScriptCore
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    
    private var count = 0
    private var wkWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWKWebview()
        loadPage()
    }
    
    private func loadPage() {
        guard let html = Bundle.main.path(forResource: "RequestCatcher", ofType: "html") else {
            return
        }
        let htmlString = try? String(contentsOfFile: html, encoding: String.Encoding.utf8)
        wkWebView.loadHTMLString(htmlString!, baseURL: nil)
        wkWebView.navigationDelegate = self
    }
    
    private func setupWKWebview() {
        self.wkWebView = WKWebView(frame: self.view.bounds, configuration: self.getWKWebViewConfiguration())
        self.view.addSubview(self.wkWebView)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame != true {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if count == 0 {
            count += 1
            return
        }
        
        webView.evaluateJavaScript("document.body.innerHTML") { (html, error) in
            guard let html = html as? String else {
                return
            }
            let alert = UIAlertController(title: "Page Body", message: html, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func getWKWebViewConfiguration() -> WKWebViewConfiguration {

        let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);"

        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        let userController = WKUserContentController()
        userController.addUserScript(script)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        return configuration
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("show: \(message)")
    }
}
