//
//  WebView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL?
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var isLoading: Bool
    @Binding var currentURL: URL?
    @Binding var pageTitle: String
    var onNavigate: ((URL, String) -> Void)?
    var webViewStore: WebViewStore
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = [.all]
        
        // Application of AdBlock
        if AppSettings.shared.adBlockEnabled {
            ContentBlocker.shared.apply(to: config)
        }
        
        // Inject Appearance Scripts
        let userContentController = config.userContentController
        
        // Font Size Script
        let fontSizeScript = WKUserScript(source: """
            var style = document.createElement('style');
            style.innerHTML = 'body { -webkit-text-size-adjust: \(Int(AppSettings.shared.fontSize))0%; }';
            document.head.appendChild(style);
        """, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(fontSizeScript)
        
        // High Contrast Script
        if AppSettings.shared.highContrastMode {
            let contrastScript = WKUserScript(source: """
                var style = document.createElement('style');
                style.innerHTML = 'html { filter: contrast(1.2) saturate(1.1); }';
                document.head.appendChild(style);
            """, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            userContentController.addUserScript(contrastScript)
        }
        
        // Color Blind Mode (Grayscale/Filter)
        if AppSettings.shared.colorBlindMode {
            let cbScript = WKUserScript(source: """
                var style = document.createElement('style');
                style.innerHTML = 'html { filter: grayscale(0.2) sepia(0.1); }';
                document.head.appendChild(style);
            """, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            userContentController.addUserScript(cbScript)
        }
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        // 存储引用
        DispatchQueue.main.async {
            self.webViewStore.webView = webView
        }
        context.coordinator.webView = webView
        
        if let url = url {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // 只在URL真正变化时加载
        if let url = url {
            // 检查是否需要加载新URL
            let currentURLString = webView.url?.absoluteString
            let newURLString = url.absoluteString
            
            if currentURLString != newURLString {
                webView.load(URLRequest(url: url))
            }
        }
        
        // Dynamic Appearance Update (via Evaluate JS)
        let settings = AppSettings.shared
        
        let js = """
            document.body.style.webkitTextSizeAdjust = '\(Int(settings.fontSize))0%';
            var filters = [];
            if (\(settings.highContrastMode)) filters.push('contrast(1.2) saturate(1.1)');
            if (\(settings.colorBlindMode)) filters.push('grayscale(0.2) sepia(0.1)');
            document.documentElement.style.filter = filters.join(' ');
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        weak var webView: WKWebView?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
                self.parent.currentURL = webView.url
                self.parent.pageTitle = webView.title ?? ""
                
                if let url = webView.url {
                    self.parent.onNavigate?(url, webView.title ?? "")
                }
            }
            
            // Re-apply appearance on finish load
            let settings = AppSettings.shared
            let js = """
                document.body.style.webkitTextSizeAdjust = '\(Int(settings.fontSize))0%';
                var filters = [];
                if (\(settings.highContrastMode)) filters.push('contrast(1.2) saturate(1.1)');
                if (\(settings.colorBlindMode)) filters.push('grayscale(0.2) sepia(0.1)');
                document.documentElement.style.filter = filters.join(' ');
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        // 处理新窗口链接
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // 允许所有导航
            decisionHandler(.allow)
        }
    }
}

// 用于存储WebView引用以便外部控制
@Observable
final class WebViewStore {
    weak var webView: WKWebView?
    
    func goBack() { webView?.goBack() }
    func goForward() { webView?.goForward() }
    func reload() { webView?.reload() }
    func stopLoading() { webView?.stopLoading() }
}
