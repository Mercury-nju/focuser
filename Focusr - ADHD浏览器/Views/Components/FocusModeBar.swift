//
//  FocusModeBar.swift
//  Focusr - ADHD浏览器
//

import SwiftUI

struct FocusModeBar: View {
    @Bindable var timer: FocusTimer
    let onExit: () -> Void
    
    @State private var pulseAnimation = false
    
    var body: some View {
        HStack(spacing: 14) {
            // 退出按钮
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                onExit()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(white: 0.5))
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color(white: 0.95))
                    )
            }
            
            // 状态指示
            HStack(spacing: 6) {
                Circle()
                    .fill(timer.state == .focusing ? Color(white: 0.25) : Color(white: 0.6))
                    .frame(width: 5, height: 5)
                    .scaleEffect(pulseAnimation && timer.state == .focusing ? 1.3 : 1.0)
                
                Text(timer.state == .focusing ? "专注" : "休息")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(white: 0.5))
            }
            
            // 分隔线
            Rectangle()
                .fill(Color(white: 0.85))
                .frame(width: 1, height: 16)
            
            // 时间显示
            Text(timer.formattedTime)
                .font(.system(size: 18, weight: .light, design: .monospaced))
                .foregroundColor(Color(white: 0.2))
                .monospacedDigit()
            
            // 进度环
            ZStack {
                Circle()
                    .stroke(Color(white: 0.9), lineWidth: 2)
                
                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(
                        Color(white: 0.35),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 22, height: 22)
            
            // 完成次数
            if timer.totalFocusSessions > 0 {
                Text("×\(timer.totalFocusSessions)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(Color(white: 0.55))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color(white: 0.94))
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.06), radius: 16, y: 6)
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.7), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}
