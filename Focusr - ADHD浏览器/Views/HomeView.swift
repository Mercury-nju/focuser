//
//  HomeView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI
import UIKit

struct HomeView: View {
    @ObservedObject var viewModel: BrowserViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var breatheAnimation = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                Theme.backgroundGradient(for: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Breathing Logo
                    ZStack {
                        // Outer Glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Theme.Colors.accent.opacity(colorScheme == .dark ? 0.15 : 0.08),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: breatheAnimation ? 120 : 80
                                )
                            )
                            .frame(width: 240, height: 240)
                            .scaleEffect(breatheAnimation ? 1.15 : 1.0)
                            .opacity(breatheAnimation ? 1.0 : 0.6)
                        
                        // Glass Circle
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                            
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(colorScheme == .dark ? 0.2 : 0.7),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                        .frame(width: 96, height: 96)
                        .shadow(
                            color: Theme.Shadows.medium(for: colorScheme).color,
                            radius: Theme.Shadows.medium(for: colorScheme).radius,
                            y: Theme.Shadows.medium(for: colorScheme).y
                        )
                        
                        // Logo Image
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    }
                    
                    Spacer().frame(height: 32)
                    
                    // Brand Name
                    Text("Focusr")
                        .font(Theme.Typography.headerMedium())
                        .tracking(8)
                        .foregroundStyle(Theme.Colors.text.opacity(0.8))
                    
                    Spacer().frame(height: 12)
                    
                    // Tagline
                    Text("专注你的思维")
                        .font(Theme.Typography.caption())
                        .tracking(4)
                        .foregroundStyle(Theme.Colors.textTertiary)
                    
                    Spacer()
                    Spacer()
                    
                    // Bottom Controls
                    if !viewModel.showFocusMode {
                        HStack(spacing: 48) {
                            GlassButton(
                                icon: "circle.circle",
                                label: "专注",
                                isActive: viewModel.showFocusMode,
                                colorScheme: colorScheme
                            ) {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    viewModel.toggleFocusMode()
                                }
                            }
                            
                            GlassButton(
                                icon: "square.stack.3d.up",
                                label: "\(viewModel.tabs.count) 标签",
                                isActive: false,
                                colorScheme: colorScheme
                            ) {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    viewModel.showTabsView = true
                                }
                            }
                        }
                        .padding(.bottom, geo.safeAreaInsets.bottom + 20)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                breatheAnimation = true
            }
        }
    }
}

// MARK: - Glass Button
struct GlassButton: View {
    let icon: String
    let label: String
    var isActive: Bool = false
    var colorScheme: ColorScheme
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    // Glass Background
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(isPressed ? Theme.Colors.glassTint(for: colorScheme) : Color.clear)
                        )
                    
                    // Border
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.3 : 0.8),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                        .frame(width: 60, height: 60)
                    
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .light))
                        .foregroundStyle(
                            isActive ? Theme.Colors.accent : Theme.Colors.text.opacity(0.7)
                        )
                }
                .shadow(
                    color: Theme.Shadows.small(for: colorScheme).color,
                    radius: isPressed ? 2 : 8,
                    y: isPressed ? 1 : 4
                )
                .scaleEffect(isPressed ? 0.92 : 1.0)
                
                Text(label)
                    .font(Theme.Typography.caption())
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .buttonStyle(DisplayPressStyle(isPressed: $isPressed))
    }
}

// MARK: - Pressable Button Style
struct DisplayPressStyle: ButtonStyle {
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
