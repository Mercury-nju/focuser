//
//  AppSettings.swift
//  Focusr - ADHD浏览器
//

import SwiftUI

@Observable
final class AppSettings: @unchecked Sendable {
    static let shared = AppSettings()
    
    var homeURL: String {
        get { UserDefaults.standard.string(forKey: "homeURL") ?? "https://www.google.com" }
        set { UserDefaults.standard.set(newValue, forKey: "homeURL") }
    }
    
    var adBlockEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "adBlockEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "adBlockEnabled") }
    }
    
    var fontSize: Double {
        get { 
            let val = UserDefaults.standard.double(forKey: "fontSize")
            return val > 0 ? val : 16
        }
        set { UserDefaults.standard.set(newValue, forKey: "fontSize") }
    }
    
    var highContrastMode: Bool {
        get { UserDefaults.standard.bool(forKey: "highContrastMode") }
        set { UserDefaults.standard.set(newValue, forKey: "highContrastMode") }
    }
    
    var colorBlindMode: Bool {
        get { UserDefaults.standard.bool(forKey: "colorBlindMode") }
        set { UserDefaults.standard.set(newValue, forKey: "colorBlindMode") }
    }
    
    var readerModeAutoEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "readerModeAutoEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "readerModeAutoEnabled") }
    }
    
    var hapticFeedback: Bool {
        get { 
            if UserDefaults.standard.object(forKey: "hapticFeedback") == nil { return true }
            return UserDefaults.standard.bool(forKey: "hapticFeedback")
        }
        set { UserDefaults.standard.set(newValue, forKey: "hapticFeedback") }
    }
    
    private init() {}
    
    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard hapticFeedback else { return }
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #endif
    }
}
