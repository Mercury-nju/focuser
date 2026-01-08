//
//  URLBar.swift
//  Focusr - ADHD浏览器
//

import SwiftUI

struct URLBar: View {
    @Binding var urlInput: String
    let isLoading: Bool
    let currentURL: URL?
    let onSubmit: () -> Void
    let onMenu: () -> Void
    let onRefresh: () -> Void
    
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Menu Button
            Button(action: onMenu) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Theme.Colors.surface.opacity(0.5))
                        )
                    
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }
            .shadow(
                color: Theme.Shadows.small(for: colorScheme).color,
                radius: Theme.Shadows.small(for: colorScheme).radius,
                y: 2
            )
            
            // Search Box
            HStack(spacing: 10) {
                // Status Icon
                Group {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 18, height: 18)
                    } else if currentURL != nil && !isFocused && urlInput.isEmpty {
                        Image(systemName: currentURL?.scheme == "https" ? "lock.fill" : "globe")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.Colors.success)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.Colors.textTertiary)
                    }
                }
                .frame(width: 24)
                
                // Input Area
                ZStack(alignment: .leading) {
                    if urlInput.isEmpty && !isFocused {
                        Text(currentURL?.host ?? "Search or enter URL")
                            .font(Theme.Typography.body())
                            .foregroundStyle(currentURL != nil ? Theme.Colors.text : Theme.Colors.textTertiary)
                            .lineLimit(1)
                    }
                    
                    TextField("", text: $urlInput)
                        .font(Theme.Typography.body())
                        .foregroundStyle(Theme.Colors.text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .submitLabel(.go)
                        .focused($isFocused)
                        .onSubmit {
                            if !urlInput.isEmpty {
                                onSubmit()
                            }
                            isFocused = false
                        }
                }
                
                // Right Action
                if !urlInput.isEmpty && isFocused {
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) {
                            urlInput = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Theme.Colors.textTertiary)
                    }
                } else if !isLoading && currentURL != nil && !isFocused {
                    Button(action: onRefresh) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Theme.Colors.glassTint(for: colorScheme).opacity(0.3))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.15 : 0.5),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Theme.Shadows.small(for: colorScheme).color,
                radius: Theme.Shadows.small(for: colorScheme).radius,
                y: 2
            )
            .onTapGesture {
                if !isFocused {
                    if let url = currentURL {
                        urlInput = url.absoluteString
                    }
                    isFocused = true
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onChange(of: isFocused) { _, focused in
            if !focused && urlInput == currentURL?.absoluteString {
                urlInput = ""
            }
        }
    }
}
