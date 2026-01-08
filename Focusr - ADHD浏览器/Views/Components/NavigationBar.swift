//
//  NavigationBar.swift
//  Focusr - ADHD浏览器
//

import SwiftUI
import UIKit

struct NavigationBar: View {
    @ObservedObject var viewModel: BrowserViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side: Back + Forward
            HStack(spacing: 0) {
                NavButton(
                    icon: "chevron.left",
                    disabled: !viewModel.canGoBack,
                    active: false,
                    colorScheme: colorScheme,
                    action: { viewModel.goBack() }
                )
                
                NavButton(
                    icon: "chevron.right",
                    disabled: !viewModel.canGoForward,
                    active: false,
                    colorScheme: colorScheme,
                    action: { viewModel.goForward() }
                )
            }
            .frame(maxWidth: .infinity)
            
            // Center: Focus
            NavButton(
                icon: "circle.circle",
                disabled: false,
                active: viewModel.showFocusMode,
                colorScheme: colorScheme,
                action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel.toggleFocusMode()
                    }
                }
            )
            
            // Right side: Tabs
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    viewModel.showTabsView = true
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Theme.Colors.text.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    
                    Text("\(viewModel.tabs.count)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Colors.text)
                }
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 6)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .shadow(
                    color: Theme.Shadows.small(for: colorScheme).color,
                    radius: Theme.Shadows.small(for: colorScheme).radius,
                    y: -2
                )
        )
    }
}

struct NavButton: View {
    let icon: String
    let disabled: Bool
    let active: Bool
    let colorScheme: ColorScheme
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        } label: {
            Image(systemName: active ? "\(icon).fill" : icon)
                .font(.system(size: 20, weight: active ? .medium : .light))
                .foregroundStyle(
                    active ? Theme.Colors.accent :
                    disabled ? Theme.Colors.textTertiary : Theme.Colors.textSecondary
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .scaleEffect(isPressed ? 0.88 : 1.0)
                .contentShape(Rectangle())
        }
        .disabled(disabled)
        .buttonStyle(NavPressStyle(isPressed: $isPressed))
    }
}

struct NavPressStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                withAnimation(.easeOut(duration: 0.12)) {
                    isPressed = newValue
                }
            }
    }
}
