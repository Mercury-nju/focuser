//
//  BookmarksView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI

struct BookmarksView: View {
    @Bindable var viewModel: BrowserViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private var dataStore: DataStore { DataStore.shared }
    
    var body: some View {
        NavigationStack {
            Group {
                if dataStore.bookmarks.isEmpty {
                    EmptyStateView(
                        icon: "star",
                        title: "No Bookmarks",
                        subtitle: "Tap 'Add Bookmark' in menu to save"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(dataStore.bookmarks) { bookmark in
                                BookmarkCard(bookmark: bookmark, scheme: colorScheme) {
                                    viewModel.currentTab.url = bookmark.url
                                    dismiss()
                                } onDelete: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        dataStore.removeBookmark(bookmark)
                                    }
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
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(Theme.Typography.button())
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - Bookmark Card
struct BookmarkCard: View {
    let bookmark: Bookmark
    let scheme: ColorScheme
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.Colors.surface)
                        .frame(width: 48, height: 48)
                    
                    Text(String(bookmark.title.prefix(1)).uppercased())
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(bookmark.title)
                        .font(Theme.Typography.body())
                        .foregroundStyle(Theme.Colors.text)
                        .lineLimit(1)
                    
                    Text(bookmark.url.host ?? bookmark.url.absoluteString)
                        .font(Theme.Typography.caption())
                        .foregroundStyle(Theme.Colors.textTertiary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.Colors.textTertiary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Theme.Colors.surface)
                        )
                }
            }
            .padding(12)
            .glassCard(scheme: scheme)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(CardPressStyle(isPressed: $isPressed))
    }
}

struct CardPressStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, pressed in
                withAnimation(.easeOut(duration: 0.12)) {
                    isPressed = pressed
                }
            }
    }
}
