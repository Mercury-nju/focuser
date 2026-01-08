//
//  Session.swift
//  Focusr - ADHD浏览器
//

import Foundation

struct Session: Identifiable, Codable {
    let id: UUID
    var name: String
    var tabs: [Tab]
    var createdAt: Date
    var lastAccessedAt: Date
    
    init(id: UUID = UUID(), name: String, tabs: [Tab] = [], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.tabs = tabs
        self.createdAt = createdAt
        self.lastAccessedAt = createdAt
    }
    
    var isExpired: Bool {
        Date().timeIntervalSince(lastAccessedAt) > 7 * 24 * 3600 // 7天
    }
}
