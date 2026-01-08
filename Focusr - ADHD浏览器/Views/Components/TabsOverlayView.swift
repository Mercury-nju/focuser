//
//  TabsOverlayView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI

struct TabsOverlayView: View {
    @ObservedObject var viewModel: BrowserViewModel
    @State private var showSaveSession = false
    @State private var sessionName = ""
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // 背景遮罩
            Color.black.opacity(appearAnimation ? 0.25 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissView()
                }
            
            VStack(spacing: 0) {
                // 顶栏
                HStack(alignment: .center) {
                    Text("标签页")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(white: 0.2))
                    
                    Spacer()
                    
                    // 保存会话
                    Button {
                        showSaveSession = true
                    } label: {
                        Text("保存")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(white: 0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(white: 0.95))
                            )
                    }
                    
                    // 关闭
                    Button {
                        dismissView()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(white: 0.5))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color(white: 0.95))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // 分隔线
                Rectangle()
                    .fill(Color(white: 0.92))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                
                // 标签列表
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                        spacing: 12
                    ) {
                        ForEach(Array(viewModel.tabs.enumerated()), id: \.element.id) { index, tab in
                            TabCard(
                                tab: tab,
                                isSelected: index == viewModel.currentTabIndex,
                                onSelect: {
                                    viewModel.selectTab(at: index)
                                    dismissView()
                                },
                                onClose: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        viewModel.closeTab(at: index)
                                    }
                                }
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // 新建标签
                        if viewModel.tabs.count < 10 {
                            NewTabButton {
                                viewModel.addTab()
                            }
                        }
                    }
                    .padding(20)
                }
                
                // 底栏
                HStack {
                    Text("\(viewModel.tabs.count)/10 标签")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(white: 0.6))
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.regularMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 30, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
            )
            .padding(16)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .opacity(appearAnimation ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                appearAnimation = true
            }
        }
        .alert("保存会话", isPresented: $showSaveSession) {
            TextField("会话名称", text: $sessionName)
            Button("取消", role: .cancel) { sessionName = "" }
            Button("保存") {
                if !sessionName.isEmpty {
                    viewModel.saveCurrentSession(name: sessionName)
                    sessionName = ""
                }
            }
        }
    }
    
    private func dismissView() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            appearAnimation = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            viewModel.showTabsView = false
        }
    }
}

// MARK: - Tab Card
struct TabCard: View {
    let tab: Tab
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // 预览区域
                ZStack(alignment: .topTrailing) {
                    // 背景
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.97), Color(white: 0.94)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 56)
                    
                    // 网站首字母
                    if let host = tab.url?.host {
                        Text(String(host.prefix(1)).uppercased())
                            .font(.system(size: 20, weight: .ultraLight))
                            .foregroundColor(Color(white: 0.7))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(Color(white: 0.6))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // 关闭按钮
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color(white: 0.5))
                            .frame(width: 20, height: 20)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                            )
                    }
                    .padding(6)
                }
                
                // 信息区域
                VStack(alignment: .leading, spacing: 3) {
                    Text(tab.title.isEmpty ? "新标签页" : tab.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.25))
                        .lineLimit(1)
                    
                    Text(tab.url?.host ?? "about:blank")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(Color(white: 0.55))
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.04), radius: isSelected ? 12 : 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(white: 0.7) : Color(white: 0.9), lineWidth: isSelected ? 1.5 : 0.5)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(TabCardPressStyle(isPressed: $isPressed))
    }
}

struct TabCardPressStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                withAnimation(.easeOut(duration: 0.15)) {
                    isPressed = newValue
                }
            }
    }
}

// MARK: - New Tab Button
struct NewTabButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(Color(white: 0.5))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                    )
                    .foregroundColor(Color(white: 0.85))
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(TabCardPressStyle(isPressed: $isPressed))
    }
}
