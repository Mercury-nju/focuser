//
//  HistoryView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI
import UIKit

struct HistoryView: View {
    @ObservedObject var viewModel: BrowserViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showClearConfirm = false
    
    private var dataStore: DataStore { DataStore.shared }
    
    var body: some View {
        NavigationStack {
            Group {
                if dataStore.history.isEmpty {
                    EmptyStateView(
                        icon: "clock",
                        title: "暂无历史记录",
                        subtitle: "浏览过的页面会显示在这里"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(groupedHistory, id: \.0) { date, items in
                                VStack(alignment: .leading, spacing: 10) {
                                    // Date Header
                                    Text(date)
                                        .font(Theme.Typography.caption())
                                        .foregroundStyle(Theme.Colors.textTertiary)
                                        .textCase(.uppercase)
                                        .tracking(0.5)
                                        .padding(.leading, 4)
                                    
                                    // History Items
                                    VStack(spacing: 0) {
                                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                            if index > 0 {
                                                Divider()
                                                    .padding(.leading, 58)
                                            }
                                            
                                            HistoryRow(item: item, scheme: colorScheme) {
                                                viewModel.currentTab.url = item.url
                                                dismiss()
                                            }
                                        }
                                    }
                                    .glassCard(scheme: colorScheme)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Theme.Colors.background)
            .navigationTitle("历史记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !dataStore.history.isEmpty {
                        Button {
                            showClearConfirm = true
                        } label: {
                            Text("清除")
                                .font(Theme.Typography.body())
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("完成")
                            .font(Theme.Typography.button())
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
            }
            .confirmationDialog("清除历史记录", isPresented: $showClearConfirm, titleVisibility: .visible) {
                Button("清除所有历史记录", role: .destructive) {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.warning)
                    dataStore.clearHistory()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("此操作无法撤销")
            }
        }
    }
    
    private var groupedHistory: [(String, [HistoryItem])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        
        let grouped = Dictionary(grouping: dataStore.history) { item in
            formatter.string(from: item.visitedAt)
        }
        
        return grouped.sorted { $0.value.first?.visitedAt ?? Date() > $1.value.first?.visitedAt ?? Date() }
    }
}

// MARK: - History Row
struct HistoryRow: View {
    let item: HistoryItem
    let scheme: ColorScheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.Colors.surface)
                        .frame(width: 44, height: 44)
                    
                    Text(String(item.title.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(Theme.Typography.body())
                        .foregroundStyle(Theme.Colors.text)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text(item.url.host ?? "")
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.Colors.textTertiary)
                            .lineLimit(1)
                        
                        Text("·")
                            .foregroundStyle(Theme.Colors.textTertiary)
                        
                        Text(item.visitedAt, style: .time)
                            .font(Theme.Typography.caption())
                            .foregroundStyle(Theme.Colors.textTertiary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
            .padding(14)
            .background(Color.white.opacity(0.001)) // Hit testing
        }
    }
}
