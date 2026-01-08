//
//  ContentBlocker.swift
//  Focusr - ADHD浏览器
//

import WebKit

final class ContentBlocker: @unchecked Sendable {
    static let shared = ContentBlocker()
    private var contentRuleList: WKContentRuleList?
    private var isCompiled = false
    
    private let blockRulesJSON = """
    [
        {
            "trigger": { "url-filter": ".*", "resource-type": ["popup"] },
            "action": { "type": "block" }
        },
        {
            "trigger": { "url-filter": ".*ads.*" },
            "action": { "type": "block" }
        },
        {
            "trigger": { "url-filter": ".*doubleclick.*" },
            "action": { "type": "block" }
        },
        {
            "trigger": { "url-filter": ".*googlesyndication.*" },
            "action": { "type": "block" }
        },
        {
            "trigger": { "url-filter": ".*adservice.*" },
            "action": { "type": "block" }
        },
        {
            "trigger": { "url-filter": ".*facebook.*/plugins.*" },
            "action": { "type": "block" }
        },
        {
            "trigger": { "url-filter": ".*twitter.*/widgets.*" },
            "action": { "type": "block" }
        },
        {
            "trigger": { "url-filter": ".*taboola.*" },
            "action": { "type": "block" }
        },
        {
            "trigger": { "url-filter": ".*outbrain.*" },
            "action": { "type": "block" }
        }
    ]
    """
    
    private init() {}
    
    func compileRules() async throws {
        guard !isCompiled else { return }
        contentRuleList = try await WKContentRuleListStore.default()
            .compileContentRuleList(forIdentifier: "FocusrBlocker", encodedContentRuleList: blockRulesJSON)
        isCompiled = true
    }
    
    func apply(to configuration: WKWebViewConfiguration) {
        if let rules = contentRuleList {
            configuration.userContentController.add(rules)
        }
    }
}
