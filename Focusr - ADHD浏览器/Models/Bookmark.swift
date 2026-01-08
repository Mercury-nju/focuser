//
//  Bookmark.swift
//  Focusr - ADHD浏览器
//

import Foundation

struct Bookmark: Identifiable, Codable {
    let id: UUID
    var title: String
    var url: URL
    var createdAt: Date
    var folder: String?
    
    init(id: UUID = UUID(), title: String, url: URL, folder: String? = nil) {
        self.id = id
        self.title = title
        self.url = url
        self.createdAt = Date()
        self.folder = folder
    }
}
