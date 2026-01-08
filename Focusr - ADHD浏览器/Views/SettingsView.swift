//
//  SettingsView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddLimit = false
    @State private var newDomain = ""
    @State private var newLimitMinutes = 30
    
    private var settings: AppSettings { AppSettings.shared }
    private var dataStore: DataStore { DataStore.shared }
    
    @State private var homeURL: String = AppSettings.shared.homeURL
    @State private var adBlockEnabled: Bool = AppSettings.shared.adBlockEnabled
    @State private var readerModeAutoEnabled: Bool = AppSettings.shared.readerModeAutoEnabled
    @State private var fontSize: Double = AppSettings.shared.fontSize
    @State private var highContrastMode: Bool = AppSettings.shared.highContrastMode
    @State private var colorBlindMode: Bool = AppSettings.shared.colorBlindMode
    @State private var hapticFeedback: Bool = AppSettings.shared.hapticFeedback
    @State private var siteLimitsRefresh: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 浏览设置
                    SettingsSection(title: "浏览") {
                        VStack(spacing: 0) {
                            SettingsTextField(title: "首页", text: $homeURL) {
                                settings.homeURL = homeURL
                            }
                            
                            Divider().padding(.leading, 16)
                            
                            SettingsToggle(title: "广告拦截", isOn: $adBlockEnabled) {
                                settings.adBlockEnabled = adBlockEnabled
                            }
                            
                            Divider().padding(.leading, 16)
                            
                            SettingsToggle(title: "自动阅读模式", isOn: $readerModeAutoEnabled) {
                                settings.readerModeAutoEnabled = readerModeAutoEnabled
                            }
                        }
                        .background(Color.white.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // 站点限制
                    SettingsSection(title: "站点时间限制") {
                        VStack(spacing: 0) {
                            ForEach(Array(dataStore.siteLimits.enumerated()), id: \.element.id) { index, limit in
                                if index > 0 {
                                    Divider().padding(.leading, 16)
                                }
                                SiteLimitRow(limit: limit) {
                                    dataStore.deleteSiteLimit(limit)
                                    siteLimitsRefresh.toggle()
                                }
                            }
                            .id(siteLimitsRefresh)
                            
                            if !dataStore.siteLimits.isEmpty {
                                Divider().padding(.leading, 16)
                            }
                            
                            Button {
                                showAddLimit = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 17, weight: .light))
                                        .foregroundColor(Color(white: 0.45))
                                    
                                    Text("添加限制")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(Color(white: 0.35))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                        }
                        .background(Color.white.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // 外观
                    SettingsSection(title: "外观") {
                        VStack(spacing: 0) {
                            // 字体大小
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("字体大小")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(Color(white: 0.25))
                                    
                                    Spacer()
                                    
                                    Text("\(Int(fontSize))")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(white: 0.5))
                                }
                                
                                Slider(value: $fontSize, in: 12...24, step: 1)
                                    .tint(Color(white: 0.4))
                                    .onChange(of: fontSize) { _, newValue in
                                        settings.fontSize = newValue
                                    }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            
                            Divider().padding(.leading, 16)
                            
                            SettingsToggle(title: "高对比度模式", isOn: $highContrastMode) {
                                settings.highContrastMode = highContrastMode
                            }
                            
                            Divider().padding(.leading, 16)
                            
                            SettingsToggle(title: "色盲友好模式", isOn: $colorBlindMode) {
                                settings.colorBlindMode = colorBlindMode
                            }
                        }
                        .background(Color.white.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // 反馈
                    SettingsSection(title: "反馈") {
                        VStack(spacing: 0) {
                            SettingsToggle(title: "触觉反馈", isOn: $hapticFeedback) {
                                settings.hapticFeedback = hapticFeedback
                            }
                        }
                        .background(Color.white.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // 关于
                    SettingsSection(title: "关于") {
                        VStack(spacing: 0) {
                            HStack {
                                Text("版本")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(Color(white: 0.25))
                                
                                Spacer()
                                
                                Text("1.0.0")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(white: 0.55))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            
                            Divider().padding(.leading, 16)
                            
                            HStack {
                                Text("专为ADHD用户设计")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(Color(white: 0.25))
                                
                                Spacer()
                                
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(white: 0.6))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .background(Color.white.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // 法律与隐私
                    SettingsSection(title: "法律与隐私") {
                        VStack(spacing: 0) {
                            if let privacyURL = URL(string: "https://mercury-nju.github.io/focuser/privacy.html") {
                                Link(destination: privacyURL) {
                                    HStack {
                                        Text("隐私政策")
                                            .font(.system(size: 15, weight: .regular))
                                            .foregroundColor(Theme.Colors.text)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.up.forward.square")
                                            .font(.system(size: 14))
                                            .foregroundColor(Theme.Colors.textTertiary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                }
                            }
                            
                            Divider().padding(.leading, 16)
                            
                            if let termsURL = URL(string: "https://mercury-nju.github.io/focuser/terms.html") {
                                Link(destination: termsURL) {
                                    HStack {
                                        Text("用户协议")
                                            .font(.system(size: 15, weight: .regular))
                                            .foregroundColor(Theme.Colors.text)
                                        
                                        Spacer()
                                    
                                        Image(systemName: "arrow.up.forward.square")
                                            .font(.system(size: 14))
                                            .foregroundColor(Theme.Colors.textTertiary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                }
                            }
                        }
                        .background(Color.white.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(white: 0.96))
            .navigationTitle("设置")
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
            .alert("添加站点限制", isPresented: $showAddLimit) {
                TextField("域名 (如 twitter.com)", text: $newDomain)
                TextField("每日限制(分钟)", value: $newLimitMinutes, format: .number)
                Button("取消", role: .cancel) {
                    newDomain = ""
                    newLimitMinutes = 30
                }
                Button("添加") {
                    if !newDomain.isEmpty {
                        let limit = SiteLimit(domain: newDomain, dailyLimitMinutes: newLimitMinutes)
                        dataStore.siteLimits.append(limit)
                        dataStore.save()
                        newDomain = ""
                        newLimitMinutes = 30
                    }
                }
            }
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(white: 0.5))
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.leading, 4)
            
            content
        }
    }
}

// MARK: - Settings Toggle
struct SettingsToggle: View {
    let title: String
    @Binding var isOn: Bool
    let onChange: () -> Void
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(white: 0.25))
        }
        .tint(Color(white: 0.35))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onChange(of: isOn) { _, _ in
            onChange()
        }
    }
}

// MARK: - Settings Text Field
struct SettingsTextField: View {
    let title: String
    @Binding var text: String
    let onChange: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(white: 0.25))
            
            Spacer()
            
            TextField("", text: $text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(white: 0.5))
                .multilineTextAlignment(.trailing)
                .textInputAutocapitalization(.never)
                .onChange(of: text) { _, _ in
                    onChange()
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Site Limit Row
struct SiteLimitRow: View {
    let limit: SiteLimit
    let onDelete: () -> Void
    
    @State private var showDeleteConfirm = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(limit.domain)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(white: 0.25))
                
                Text("已用 \(limit.usedMinutesToday)/\(limit.dailyLimitMinutes) 分钟")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(white: 0.55))
            }
            
            Spacer()
            
            if limit.isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.5))
            }
            
            Button {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .confirmationDialog("删除站点限制", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                onDelete()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定要删除 \(limit.domain) 的时间限制吗？")
        }
    }
}
