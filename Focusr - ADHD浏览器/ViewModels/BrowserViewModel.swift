//
//  BrowserViewModel.swift
//  Focusr - ADHD浏览器
//

import SwiftUI
import Combine

@Observable
final class BrowserViewModel {
    var tabs: [Tab] = [Tab()]
    var currentTabIndex: Int = 0
    var urlInput: String = ""
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    var isLoading: Bool = false
    var showTabsView: Bool = false
    var showFocusMode: Bool = false
    var showReaderMode: Bool = false
    var showSiteLocked: Bool = false
    
    let focusTimer = FocusTimer()
    let webViewStore = WebViewStore()
    
    private let maxTabs = 10
    private var suspendTimer: Timer?
    private var siteUsageTimer: Timer?
    private var currentSiteStartTime: Date?
    
    private var dataStore: DataStore { DataStore.shared }
    private var settings: AppSettings { AppSettings.shared }
    
    var currentTab: Tab {
        get { tabs.indices.contains(currentTabIndex) ? tabs[currentTabIndex] : Tab() }
        set {
            if tabs.indices.contains(currentTabIndex) {
                tabs[currentTabIndex] = newValue
            }
        }
    }
    
    init() {
        startSuspendTimer()
        startSiteUsageTimer()
    }
    
    // MARK: - Navigation
    
    func navigate(to urlString: String) {
        var processedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !processedURL.isEmpty else { return }
        
        // 判断是否为搜索查询（不包含.或包含空格，且不是URL格式）
        let isSearchQuery = !processedURL.contains(".") || processedURL.contains(" ")
        
        if isSearchQuery {
            // 使用 URLComponents 正确编码搜索查询
            var components = URLComponents(string: "https://www.bing.com/search")!
            components.queryItems = [URLQueryItem(name: "q", value: processedURL)]
            guard let url = components.url else { return }
            processedURL = url.absoluteString
        } else if !processedURL.lowercased().hasPrefix("http://") && !processedURL.lowercased().hasPrefix("https://") {
            processedURL = "https://\(processedURL)"
        }
        
        guard let url = URL(string: processedURL) else { return }
        
        // 检查站点限制
        if let host = url.host, dataStore.isLocked(domain: host) {
            showSiteLocked = true
            settings.triggerHaptic(.heavy)
            return
        }
        
        recordSiteUsage()
        currentTab.url = url
        currentTab.lastAccessTime = Date()
        currentTab.isSuspended = false
        currentSiteStartTime = Date()
        urlInput = ""
    }
    
    func goHome() {
        if let url = URL(string: settings.homeURL) {
            recordSiteUsage()
            currentTab.url = url
            currentTab.lastAccessTime = Date()
            currentSiteStartTime = Date()
        }
    }
    
    func goBack() {
        webViewStore.goBack()
    }
    
    func goForward() {
        webViewStore.goForward()
    }
    
    func reload() {
        webViewStore.reload()
    }
    
    func updateCurrentTab(url: URL, title: String) {
        // 检查是否切换了域名
        let oldHost = currentTab.url?.host
        let newHost = url.host
        
        if oldHost != newHost {
            recordSiteUsage()
            currentSiteStartTime = Date()
            
            // 检查新站点是否被锁定
            if let host = newHost, dataStore.isLocked(domain: host) {
                showSiteLocked = true
                settings.triggerHaptic(.heavy)
                webViewStore.goBack()
                return
            }
        }
        
        currentTab.url = url
        currentTab.title = title.isEmpty ? url.host ?? "网页" : title
        currentTab.lastAccessTime = Date()
        dataStore.addHistoryItem(url: url, title: currentTab.title)
    }
    
    // MARK: - Tab Management
    
    func addTab() {
        guard tabs.count < maxTabs else {
            settings.triggerHaptic(.heavy)
            return
        }
        recordSiteUsage()
        tabs.append(Tab())
        currentTabIndex = tabs.count - 1
        currentSiteStartTime = nil
        settings.triggerHaptic()
    }
    
    func closeTab(at index: Int) {
        guard tabs.count > 1 else { return }
        
        if index == currentTabIndex {
            recordSiteUsage()
        }
        
        tabs.remove(at: index)
        if currentTabIndex >= tabs.count {
            currentTabIndex = tabs.count - 1
        }
        currentSiteStartTime = tabs[currentTabIndex].url != nil ? Date() : nil
        settings.triggerHaptic()
    }
    
    func selectTab(at index: Int) {
        guard index != currentTabIndex else {
            showTabsView = false
            return
        }
        
        recordSiteUsage()
        currentTabIndex = index
        tabs[index].lastAccessTime = Date()
        tabs[index].isSuspended = false
        currentSiteStartTime = tabs[index].url != nil ? Date() : nil
        showTabsView = false
        settings.triggerHaptic()
    }
    
    // MARK: - Session Management
    
    func saveCurrentSession(name: String) {
        let session = Session(name: name, tabs: tabs)
        dataStore.saveSession(session)
        settings.triggerHaptic(.medium)
    }
    
    func loadSession(_ session: Session) {
        recordSiteUsage()
        tabs = session.tabs.isEmpty ? [Tab()] : session.tabs
        currentTabIndex = 0
        currentSiteStartTime = tabs[0].url != nil ? Date() : nil
        
        var updatedSession = session
        updatedSession.lastAccessedAt = Date()
        dataStore.saveSession(updatedSession)
        settings.triggerHaptic()
    }
    
    // MARK: - Focus Mode
    
    func toggleFocusMode() {
        showFocusMode.toggle()
        if showFocusMode {
            focusTimer.startFocus()
        } else {
            focusTimer.stop()
        }
        settings.triggerHaptic(.medium)
    }
    
    // MARK: - Reader Mode
    
    func toggleReaderMode() {
        showReaderMode.toggle()
        settings.triggerHaptic()
    }
    
    // MARK: - Bookmarks
    
    func bookmarkCurrentPage() {
        guard let url = currentTab.url else { return }
        let bookmark = Bookmark(title: currentTab.title, url: url)
        dataStore.addBookmark(bookmark)
        settings.triggerHaptic(.medium)
    }
    
    // MARK: - Site Usage Tracking
    
    private func recordSiteUsage() {
        guard let startTime = currentSiteStartTime,
              let host = currentTab.url?.host else { return }
        
        let minutes = Int(Date().timeIntervalSince(startTime) / 60)
        if minutes > 0 {
            dataStore.updateSiteUsage(for: host, minutes: minutes)
        }
        currentSiteStartTime = nil
    }
    
    private func startSiteUsageTimer() {
        siteUsageTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.checkSiteLimit()
            }
        }
    }
    
    private func checkSiteLimit() {
        guard let host = currentTab.url?.host else { return }
        
        // 每分钟更新使用时间
        if currentSiteStartTime != nil {
            dataStore.updateSiteUsage(for: host, minutes: 1)
        }
        
        // 检查是否超限
        if dataStore.isLocked(domain: host) {
            showSiteLocked = true
            settings.triggerHaptic(.heavy)
        }
    }
    
    // MARK: - Tab Suspension
    
    private func startSuspendTimer() {
        suspendTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.checkAndSuspendTabs()
            }
        }
    }
    
    private func checkAndSuspendTabs() {
        for i in tabs.indices where i != currentTabIndex {
            if tabs[i].shouldSuspend && !tabs[i].isSuspended {
                tabs[i].isSuspended = true
            }
        }
    }
}
