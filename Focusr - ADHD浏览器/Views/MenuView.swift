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
            // Header - 带安全区域间距
            HStack {
                Text("菜单")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.Colors.text)
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Theme.Colors.textTertiary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60) // 避开顶部状态栏
            .padding(.bottom, 20)
            
            // 分隔线
            Rectangle()
                .fill(Theme.Colors.surface)
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            // 功能列表 - 统一横条布局
            ScrollView {
                VStack(spacing: 4) {
                    // 主要功能
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
                    
                    // 分隔
                    Rectangle()
                        .fill(Theme.Colors.surface)
                        .frame(height: 1)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 4)
                    
                    // 快捷操作
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
                    
                    MenuRow(icon: "gearshape.fill", title: "设置", color: Theme.Colors.textSecondary) {
                        onDismiss()
                        onNavigate(.settings)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            
            Spacer()
        }
        .background(Theme.Colors.background)
    }
}

// MARK: - Menu Row (统一横条样式)
struct MenuRow: View {
    let icon: String
    let title: String
    var color: Color = Theme.Colors.textSecondary
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(color)
                }
                
                // 标题
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Theme.Colors.text)
                
                Spacer()
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isPressed ? Theme.Colors.surface : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.15)) {
                        isPressed = false
                    }
                }
        )
    }
}
