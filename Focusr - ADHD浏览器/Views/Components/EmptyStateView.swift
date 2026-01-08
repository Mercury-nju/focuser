//
//  EmptyStateView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    @State private var breatheAnimation = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // 图标
            ZStack {
                // 呼吸光晕
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(white: 0.85).opacity(0.5), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: breatheAnimation ? 50 : 40
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(breatheAnimation ? 1.1 : 1.0)
                
                // 图标背景
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.black.opacity(0.04), radius: 12, y: 4)
                
                // 图标
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(Color(white: 0.45))
            }
            
            // 标题
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(white: 0.25))
            
            // 副标题
            Text(subtitle)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(white: 0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                breatheAnimation = true
            }
        }
    }
}
