//
//  Note.swift
//  Focusr - ADHD浏览器
//

import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    var content: String
    var sourceURL: URL?
    var createdAt: Date
    var tags: [String]
    
    init(id: UUID = UUID(), content: String, sourceURL: URL? = nil, tags: [String] = []) {
        self.id = id
        self.content = content
        self.sourceURL = sourceURL
        self.createdAt = Date()
        self.tags = tags
    }
}
