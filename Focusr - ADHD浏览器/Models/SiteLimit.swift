//
//  SiteLimit.swift
//  Focusr - ADHD浏览器
//

import Foundation

struct SiteLimit: Identifiable, Codable {
    let id: UUID
    var domain: String
    var dailyLimitMinutes: Int
    var usedMinutesToday: Int
    var lastResetDate: Date
    
    init(id: UUID = UUID(), domain: String, dailyLimitMinutes: Int = 30) {
        self.id = id
        self.domain = domain
        self.dailyLimitMinutes = dailyLimitMinutes
        self.usedMinutesToday = 0
        self.lastResetDate = Date()
    }
    
    var isLocked: Bool {
        usedMinutesToday >= dailyLimitMinutes
    }
    
    var remainingMinutes: Int {
        max(0, dailyLimitMinutes - usedMinutesToday)
    }
    
    mutating func resetIfNeeded() {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastResetDate) {
            usedMinutesToday = 0
            lastResetDate = Date()
        }
    }
}
