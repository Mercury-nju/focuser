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
        ZStack {
            // Background Gradient
            Theme.backgroundGradient(for: colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("MENU") // English styled header like HomeView
                        .font(Theme.Typography.headerMedium())
                        .tracking(4)
                        .foregroundStyle(Theme.Colors.text.opacity(0.8))
                    
                    Spacer()
                    
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(Theme.Colors.textTertiary)
                            .shadow(color: Theme.Shadows.small(for: colorScheme).color, radius: 4, y: 2)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 24)
                
                // Function List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Core Features Section
                        VStack(spacing: 6) {
                            MenuRow(icon: "star.fill", title: "书签", color: Theme.Colors.warning) {
                                onDismiss()
                                onNavigate(.bookmarks)
                            }
                            
                            MenuRow(icon: "clock.fill", title: "历史记录", color: Theme.Colors.accent) {
                                onDismiss()
                                onNavigate(.history)
                            }
                            
                            MenuRow(icon: "square.stack.fill", title: "会话", color: Theme.Colors.success) {
                                onDismiss()
                                onNavigate(.sessions)
                            }
                            
                            MenuRow(icon: "note.text", title: "笔记", color: Theme.Colors.error) {
                                onDismiss()
                                onNavigate(.notes)
                            }
                        }
                        .padding(12)
                        .glassCard(scheme: colorScheme)
                        
                        // Action Section
                        VStack(spacing: 6) {
                            MenuRow(icon: "star", title: "添加书签", color: Theme.Colors.warning) {
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                                viewModel.bookmarkCurrentPage()
                                onDismiss()
                            }
                            
                            MenuRow(icon: "house.fill", title: "返回首页", color: Theme.Colors.accent) {
                                viewModel.goHome()
                                onDismiss()
                            }
                            
                            // Divider Concept
                            Rectangle()
                                .fill(Theme.Colors.textTertiary.opacity(0.1))
                                .frame(height: 1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)

                            MenuRow(icon: "gearshape.fill", title: "设置", color: Theme.Colors.textSecondary) {
                                onDismiss()
                                onNavigate(.settings)
                            }
                        }
                        .padding(12)
                        .glassCard(scheme: colorScheme)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - Menu Row
struct MenuRow: View {
    let icon: String
    let title: String
    var color: Color = Theme.Colors.textSecondary
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon Container
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(color)
                }
                
                // Title
                Text(title)
                    .font(Theme.Typography.body())
                    .foregroundStyle(Theme.Colors.text)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.Colors.textTertiary.opacity(0.7))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isPressed ? Theme.Colors.text.opacity(0.05) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { isPressed = true } }
                .onEnded { _ in withAnimation(.easeOut(duration: 0.15)) { isPressed = false } }
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}
