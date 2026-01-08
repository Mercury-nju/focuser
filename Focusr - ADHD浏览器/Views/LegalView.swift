//
//  LegalView.swift
//  Focusr - ADHD浏览器
//
//

import SwiftUI

struct LegalView: View {
    let type: LegalType
    @Environment(\.dismiss) private var dismiss
    
    enum LegalType {
        case privacy
        case terms
        
        var title: String {
            switch self {
            case .privacy: return "隐私政策"
            case .terms: return "用户协议"
            }
        }
        
        var content: String {
            switch self {
            case .privacy:
                return """
                **生效日期：2026年1月8日**
                
                本隐私政策说明 Focusr - ADHD浏览器（以下简称“本应用”）如何收集、使用和保护您的信息。
                
                **1. 数据收集与存储**
                本应用是一款“本地优先”的工具类应用。
                - **本地存储**：您的所有浏览历史、书签、会话记录、笔记以及设置偏好均仅存储在您设备的本地存储空间中。
                - **无服务器上传**：本应用没有任何自建服务器，也不会将您的上述个人数据上传至任何云端服务器。
                - **iCloud同步**：如果您开启了iCloud备份功能，您的数据可能会被Apple备份，这部分数据遵循Apple的隐私政策。
                
                **2. 外部网站与第三方服务**
                - **网页浏览**：本应用使用 iOS 系统原生的 WKWebView 内核进行网页渲染。当您访问第三方网站时，请遵循该网站的隐私政策。本应用无法控制第三方网站如何收集您的数据。
                - **搜索引擎**：在使用搜索引擎（如 Bing、Google）时，通过地址栏输入的查询词将发送给相应的搜索引擎服务提供商。
                
                **3. 权限使用**
                - **网络访问**：用于加载网页内容。
                - **触觉反馈**：用于提供交互反馈体验。
                
                **4. 儿童隐私**
                我们不刻意收集未满13周岁儿童的个人信息。由于本应用不收集用户数据，因此也不存在相关风险。
                
                **5. 联系我们**
                如果您对本隐私政策有任何疑问，请联系我们：
                电子邮箱：lihongyangnju@gmail.com
                """
                
            case .terms:
                return """
                **生效日期：2026年1月8日**
                
                欢迎使用 Focusr - ADHD浏览器。使用本应用即表示您同意以下条款。
                
                **1. 许可使用**
                本应用授予您个人的、不可转让的、非独占的许可，允许您在您的 Apple 设备上安装和使用本应用。
                
                **2. 用户行为规范**
                您同意仅出于合法目的使用本应用。您不得利用本应用进行任何非法的、侵犯他人权益的或破坏互联网安全的活动。
                
                **3. 免责声明**
                本应用按“现状”提供，不包含任何形式的明示或暗示保证。开发者不对因使用本应用而产生的任何数据丢失、设备损坏或随后果承担责任。
                
                **4. 知识产权**
                本应用的所有权和知识产权归开发者所有。
                
                **5. 变更与终止**
                我们保留随时修改本协议的权利。重大变更将在应用更新说明中通知。
                
                **6. 联系方式**
                如有问题，请联系：lihongyangnju@gmail.com
                """
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(type.content)
                    .font(Theme.Typography.body())
                    .foregroundStyle(Theme.Colors.text)
                    .lineSpacing(6)
                    .textSelection(.enabled)
                
                Spacer()
            }
            .padding(24)
        }
        .background(Theme.Colors.background)
        .navigationTitle(type.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
