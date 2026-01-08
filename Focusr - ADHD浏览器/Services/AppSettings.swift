//
//  AppSettings.swift
//  Focusr - ADHD浏览器
//

import SwiftUI
import UIKit

enum SearchEngine: String, CaseIterable {
    case baidu = "baidu"
    case google = "google"
    case bing = "bing"
    
    var displayName: String {
        switch self {
        case .baidu: return "百度"
        case .google: return "Google"
        case .bing: return "Bing"
        }
    }
    
    var searchURL: String {
        switch self {
        case .baidu: return "https://www.baidu.com/s"
        case .google: return "https://www.google.com/search"
        case .bing: return "https://www.bing.com/search"
        }
    }
    
    var queryParam: String {
        switch self {
        case .baidu: return "wd"
        case .google, .bing: return "q"
        }
    }
}

final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var homeURL: String
    @Published var searchEngine: SearchEngine
    @Published var adBlockEnabled: Bool
    @Published var fontSize: Double
    @Published var highContrastMode: Bool
    @Published var colorBlindMode: Bool
    @Published var hapticFeedback: Bool
    
    private init() {
        let defaults = UserDefaults.standard
        self.homeURL = defaults.string(forKey: "homeURL") ?? "https://www.bing.com"
        let engineRaw = defaults.string(forKey: "searchEngine") ?? "bing"
        self.searchEngine = SearchEngine(rawValue: engineRaw) ?? .bing
        self.adBlockEnabled = defaults.bool(forKey: "adBlockEnabled")
        let fontVal = defaults.double(forKey: "fontSize")
        self.fontSize = fontVal == 0 ? 16.0 : fontVal
        self.highContrastMode = defaults.bool(forKey: "highContrastMode")
        self.colorBlindMode = defaults.bool(forKey: "colorBlindMode")
        self.hapticFeedback = defaults.object(forKey: "hapticFeedback") == nil ? true : defaults.bool(forKey: "hapticFeedback")
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(homeURL, forKey: "homeURL")
        defaults.set(searchEngine.rawValue, forKey: "searchEngine")
        defaults.set(adBlockEnabled, forKey: "adBlockEnabled")
        defaults.set(fontSize, forKey: "fontSize")
        defaults.set(highContrastMode, forKey: "highContrastMode")
        defaults.set(colorBlindMode, forKey: "colorBlindMode")
        defaults.set(hapticFeedback, forKey: "hapticFeedback")
    }
    
    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard hapticFeedback else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
