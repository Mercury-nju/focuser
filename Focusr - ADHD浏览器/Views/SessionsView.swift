//
//  SessionsView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI

struct SessionsView: View {
    @ObservedObject var viewModel: BrowserViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var dataStore: DataStore { DataStore.shared }
    
    var body: some View {
        NavigationStack {
            Group {
                if dataStore.sessions.isEmpty {
                    EmptyStateView(
                        icon: "folder",
                        title: "暂无保存的会话",
                        subtitle: "在标签页视图中点击「保存」来保存当前标签组"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(dataStore.sessions) { session in
                                SessionCard(session: session) {
                                    viewModel.loadSession(session)
                                    dismiss()
                                } onDelete: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        dataStore.deleteSession(session)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color(white: 0.96))
            .navigationTitle("会话管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("完成")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(white: 0.45))
                    }
                }
            }
        }
    }
}

// MARK: - Session Card
struct SessionCard: View {
    let session: Session
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // 头部
                HStack {
                    Text(session.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(white: 0.2))
                    
                    Spacer()
                    
                    // 标签数量
                    Text("\(session.tabs.count)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(white: 0.94))
                        )
                    
                    // 删除按钮
                    Button(action: onDelete) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(white: 0.55))
                            .frame(width: 26, height: 26)
                            .background(
                                Circle()
                                    .fill(Color(white: 0.94))
                            )
                    }
                }
                
                // 创建时间
                Text(session.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(white: 0.55))
                
                // 标签预览
                HStack(spacing: 6) {
                    ForEach(session.tabs.prefix(3)) { tab in
                        Text(tab.url?.host ?? "新标签")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color(white: 0.5))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(white: 0.94))
                            )
                            .lineLimit(1)
                    }
                    
                    if session.tabs.count > 3 {
                        Text("+\(session.tabs.count - 3)")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color(white: 0.6))
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.8), lineWidth: 0.5)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(CardPressStyle(isPressed: $isPressed))
    }
}
