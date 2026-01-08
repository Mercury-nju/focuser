//
//  Tab.swift
//  Focusr - ADHD浏览器
//

import Foundation

struct Tab: Identifiable, Codable, Hashable {
    let id: UUID
    var url: URL?
    var title: String
    var lastAccessTime: Date
    var isSuspended: Bool
    
    init(id: UUID = UUID(), url: URL? = nil, title: String = "新标签页", lastAccessTime: Date = Date(), isSuspended: Bool = false) {
        self.id = id
        self.url = url
        self.title = title
        self.lastAccessTime = lastAccessTime
        self.isSuspended = isSuspended
    }
    
    var shouldSuspend: Bool {
        Date().timeIntervalSince(lastAccessTime) > 300 // 5分钟
    }
}
