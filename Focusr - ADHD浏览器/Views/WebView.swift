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
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator  // 添加 UI 代理处理新窗口
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        // 存储引用
        DispatchQueue.main.async {
            self.webViewStore.webView = webView
        }
        context.coordinator.webView = webView
        context.coordinator.setupObservers(for: webView)
        
        if let url = url {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // 只在外部 URL 变化且与当前 WebView URL 不同时才加载
        // 这样不会干扰 WebView 内部的链接点击导航
        guard let url = url else { return }
        
        // 如果是用户从外部设置的新 URL（比如地址栏输入），才加载
        // WebView 内部点击链接导航时，不需要重新加载
        if webView.url == nil || (webView.url?.absoluteString != url.absoluteString && context.coordinator.lastExternalURL != url) {
            context.coordinator.lastExternalURL = url
            webView.load(URLRequest(url: url))
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        weak var webView: WKWebView?
        var lastExternalURL: URL?
        private var canGoBackObservation: NSKeyValueObservation?
        private var canGoForwardObservation: NSKeyValueObservation?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func setupObservers(for webView: WKWebView) {
            // 实时监听导航状态变化
            canGoBackObservation = webView.observe(\.canGoBack, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.canGoBack = webView.canGoBack
                }
            }
            canGoForwardObservation = webView.observe(\.canGoForward, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.canGoForward = webView.canGoForward
                }
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
            }
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            // 页面开始渲染时更新状态
            DispatchQueue.main.async {
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
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
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
            }
        }
        
        // 处理新窗口链接 (target="_blank")
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // 如果是新窗口请求（target="_blank"），在当前窗口打开
            if navigationAction.targetFrame == nil, let request = navigationAction.request.url {
                webView.load(URLRequest(url: request))
                decisionHandler(.cancel)  // 取消原始请求，因为我们已经手动加载了
                return
            }
            decisionHandler(.allow)
        }
        
        // 处理 window.open() 等新窗口请求
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // 在当前 WebView 中加载，而不是创建新窗口
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
    }
}

// 用于存储WebView引用以便外部控制
final class WebViewStore: ObservableObject {
    weak var webView: WKWebView?
    
    func goBack() { webView?.goBack() }
    func goForward() { webView?.goForward() }
    func reload() { webView?.reload() }
    func stopLoading() { webView?.stopLoading() }
}
