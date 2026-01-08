//
//  MenuView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI
import UIKit

struct MenuView: View {
    @Bindable var viewModel: BrowserViewModel
    var onNavigate: (BrowserView.SheetType) -> Void
    var onDismiss: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator Spacer (Optional, keep for layout consistency or remove)
            Spacer().frame(height: 8)
            
            // Header
            HStack {
                Text("Menu")
                    .font(Theme.Typography.body())
                    .foregroundStyle(Theme.Colors.text)
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Text("Done")
                        .font(Theme.Typography.button())
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Main Functions Grid
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    MenuCard(
                        icon: "star",
                        title: "Bookmarks",
                        color: Theme.Colors.warning,
                        scheme: colorScheme
                    ) {
                        onDismiss()
                        onNavigate(.bookmarks)
                    }
                    
                    MenuCard(
                        icon: "clock",
                        title: "History",
                        color: Theme.Colors.accent,
                        scheme: colorScheme
                    ) {
                        onDismiss()
                        onNavigate(.history)
                    }
                }
                
                HStack(spacing: 12) {
                    MenuCard(
                        icon: "bubble.left.and.bubble.right",
                        title: "Sessions",
                        color: Theme.Colors.success,
                        scheme: colorScheme
                    ) {
                        onDismiss()
                        onNavigate(.sessions)
                    }
                    
                    MenuCard(
                        icon: "note.text",
                        title: "Notes",
                        color: Theme.Colors.error, // Or custom color for notes
                        scheme: colorScheme
                    ) {
                        onDismiss()
                        onNavigate(.notes)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer().frame(height: 28)
            
            // Divider
            Rectangle()
                .fill(Theme.Colors.surface)
                .frame(height: 1)
                .padding(.horizontal, 24)
            
            Spacer().frame(height: 20)
            
            // Quick Actions
            VStack(spacing: 4) {
                MenuRow(icon: "star.fill", title: "Add Bookmark") {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    viewModel.bookmarkCurrentPage()
                    onDismiss()
                }
                
                MenuRow(icon: "house", title: "Go Home") {
                    viewModel.goHome()
                    onDismiss()
                }
                
                MenuRow(icon: "gearshape", title: "Settings") {
                    onDismiss()
                    onNavigate(.settings)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Menu Card
struct MenuCard: View {
    let icon: String
    let title: String
    let color: Color
    let scheme: ColorScheme
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(color)
                    .frame(height: 30)
                
                Text(title)
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .glassCard(scheme: scheme)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(MenuCardPressStyle(isPressed: $isPressed))
    }
}

struct MenuCardPressStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, pressed in
                withAnimation(.easeOut(duration: 0.1)) {
                    isPressed = pressed
                }
            }
    }
}

// MARK: - Menu Row
struct MenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.surface)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                
                Text(title)
                    .font(Theme.Typography.body())
                    .foregroundStyle(Theme.Colors.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Color.white.opacity(0.001)) // Hit testing
        }
    }
}
