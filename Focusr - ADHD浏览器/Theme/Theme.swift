//
//  Theme.swift
//  Focusr - ADHD浏览器
//
//  Unified Theme System
//

import SwiftUI
import UIKit

// MARK: - Theme System
struct Theme {
    
    // MARK: - Colors
    struct Colors {
        // Semantic Colors
        static var primary: Color { Color("Primary") } // Need to add to asset catalog if not present, fallback to system
        static var background: Color { Color(.systemBackground) }
        static var surface: Color { Color(.secondarySystemBackground) }
        static var text: Color { Color.primary }
        static var textSecondary: Color { Color(.secondaryLabel) }
        static var textTertiary: Color { Color(.tertiaryLabel) }
        
        // Brand Colors (Soft & Premium)
        static let accent = Color(hex: 0x5E5CE6) // Soft Indigo
        static let success = Color(hex: 0x34C759)
        static let warning = Color(hex: 0xFF9500)
        static let error = Color(hex: 0xFF3B30)
        
        // Glass Tints
        static func glassTint(for scheme: ColorScheme) -> Color {
            scheme == .dark ? Color.black.opacity(0.4) : Color.white.opacity(0.6)
        }
    }
    
    // MARK: - Typography
    struct Typography {
        static func headerLarge() -> Font {
            .system(size: 34, weight: .thin, design: .serif)
        }
        
        static func headerMedium() -> Font {
            .system(size: 22, weight: .light, design: .default)
        }
        
        static func body() -> Font {
            .system(size: 17, weight: .regular, design: .default)
        }
        
        static func caption() -> Font {
            .system(size: 13, weight: .medium, design: .default)
        }
        
        static func button() -> Font {
            .system(size: 15, weight: .medium, design: .rounded)
        }
    }
    
    // MARK: - Shadows
    struct Shadows {
        static func small(for scheme: ColorScheme) -> ShadowStyle {
            ShadowStyle(
                color: scheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.05),
                radius: 4, y: 2
            )
        }
        
        static func medium(for scheme: ColorScheme) -> ShadowStyle {
            ShadowStyle(
                color: scheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.08),
                radius: 12, y: 6
            )
        }
        
        static func large(for scheme: ColorScheme) -> ShadowStyle {
            ShadowStyle(
                color: scheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.12),
                radius: 24, y: 12
            )
        }
        
        struct ShadowStyle {
            let color: Color
            let radius: CGFloat
            let y: CGFloat
        }
    }
    
    // MARK: - Gradients
    static func backgroundGradient(for scheme: ColorScheme) -> LinearGradient {
        let colors = scheme == .dark ?
            [Color(hex: 0x1A1A1A), Color(hex: 0x121212), Color(hex: 0x000000)] :
            [Color(hex: 0xFDFDFD), Color(hex: 0xF5F5F7), Color(hex: 0xECECEE)]
        
        return LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - View Modifiers
extension View {
    func glassCard(scheme: ColorScheme) -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Theme.Colors.glassTint(for: scheme))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(scheme == .dark ? 0.2 : 0.6),
                                Color.white.opacity(scheme == .dark ? 0.05 : 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Theme.Shadows.medium(for: scheme).color,
                radius: Theme.Shadows.medium(for: scheme).radius,
                y: Theme.Shadows.medium(for: scheme).y
            )
    }
    
    func glassCapsule(scheme: ColorScheme) -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        Color.white.opacity(scheme == .dark ? 0.15 : 0.4),
                        lineWidth: 0.5
                    )
            )
            .shadow(
                color: Theme.Shadows.small(for: scheme).color,
                radius: Theme.Shadows.small(for: scheme).radius,
                y: Theme.Shadows.small(for: scheme).y
            )
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
