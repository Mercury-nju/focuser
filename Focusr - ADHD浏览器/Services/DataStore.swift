//
//  DataStore.swift
//  Focusr - ADHD浏览器
//

import Foundation
import SwiftUI

final class DataStore: ObservableObject {
    static let shared = DataStore()
    
    @Published var bookmarks: [Bookmark] = []
    @Published var sessions: [Session] = []
    @Published var notes: [Note] = []
    @Published var siteLimits: [SiteLimit] = []
    @Published var history: [HistoryItem] = []
    
    private let bookmarksKey = "focusr_bookmarks"
    private let sessionsKey = "focusr_sessions"
    private let notesKey = "focusr_notes"
    private let siteLimitsKey = "focusr_site_limits"
    private let historyKey = "focusr_history"
    
    private init() {
        load()
    }
    
    func load() {
        bookmarks = loadData(forKey: bookmarksKey) ?? []
        sessions = loadData(forKey: sessionsKey) ?? []
        notes = loadData(forKey: notesKey) ?? []
        siteLimits = loadData(forKey: siteLimitsKey) ?? defaultSiteLimits()
        history = loadData(forKey: historyKey) ?? []
        cleanExpiredSessions()
    }
    
    func save() {
        saveData(bookmarks, forKey: bookmarksKey)
        saveData(sessions, forKey: sessionsKey)
        saveData(notes, forKey: notesKey)
        saveData(siteLimits, forKey: siteLimitsKey)
        saveData(history, forKey: historyKey)
    }
    
    private func loadData<T: Codable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private func saveData<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func defaultSiteLimits() -> [SiteLimit] {
        [
            SiteLimit(domain: "twitter.com", dailyLimitMinutes: 30),
            SiteLimit(domain: "x.com", dailyLimitMinutes: 30),
            SiteLimit(domain: "facebook.com", dailyLimitMinutes: 30),
            SiteLimit(domain: "instagram.com", dailyLimitMinutes: 30),
            SiteLimit(domain: "tiktok.com", dailyLimitMinutes: 20),
            SiteLimit(domain: "reddit.com", dailyLimitMinutes: 30)
        ]
    }
    
    private func cleanExpiredSessions() {
        sessions.removeAll { $0.isExpired }
    }
    
    func addBookmark(_ bookmark: Bookmark) {
        bookmarks.append(bookmark)
        save()
    }
    
    func removeBookmark(_ bookmark: Bookmark) {
        bookmarks.removeAll { $0.id == bookmark.id }
        save()
    }
    
    func saveSession(_ session: Session) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }
        save()
    }
    
    func deleteSession(_ session: Session) {
        sessions.removeAll { $0.id == session.id }
        save()
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        save()
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        save()
    }
    
    func deleteSiteLimit(_ limit: SiteLimit) {
        siteLimits.removeAll { $0.id == limit.id }
        save()
    }
    
    func addHistoryItem(url: URL, title: String) {
        let item = HistoryItem(url: url, title: title)
        history.insert(item, at: 0)
        if history.count > 500 { history = Array(history.prefix(500)) }
        save()
    }
    
    func clearHistory() {
        history.removeAll()
        save()
    }
    
    func updateSiteUsage(for domain: String, minutes: Int) {
        if let index = siteLimits.firstIndex(where: { domain.contains($0.domain) }) {
            siteLimits[index].resetIfNeeded()
            siteLimits[index].usedMinutesToday += minutes
            save()
        }
    }
    
    func isLocked(domain: String) -> Bool {
        if let index = siteLimits.firstIndex(where: { domain.contains($0.domain) }) {
            siteLimits[index].resetIfNeeded()
            save()
            return siteLimits[index].isLocked
        }
        return false
    }
}

struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let url: URL
    let title: String
    let visitedAt: Date
    
    init(id: UUID = UUID(), url: URL, title: String) {
        self.id = id
        self.url = url
        self.title = title
        self.visitedAt = Date()
    }
}
