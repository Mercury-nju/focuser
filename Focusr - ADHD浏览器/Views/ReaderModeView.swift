//
//  ReaderModeView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI
import WebKit

struct ReaderModeView: View {
    let url: URL
    let onExit: () -> Void
    
    @State private var content: String = ""
    @State private var isLoading = true
    @State private var fontSize: Double = AppSettings.shared.fontSize
    
    private var settings: AppSettings { AppSettings.shared }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶栏
            HStack {
                // 退出按钮
                Button(action: onExit) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.5))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color(white: 0.94))
                        )
                }
                
                Spacer()
                
                Text("阅读模式")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(white: 0.3))
                
                Spacer()
                
                // 字体控制
                HStack(spacing: 8) {
                    Button {
                        fontSize = max(12, fontSize - 2)
                        settings.fontSize = fontSize
                    } label: {
                        Image(systemName: "textformat.size.smaller")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(white: 0.45))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color(white: 0.94))
                            )
                    }
                    
                    Button {
                        fontSize = min(28, fontSize + 2)
                        settings.fontSize = fontSize
                    } label: {
                        Image(systemName: "textformat.size.larger")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(white: 0.45))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color(white: 0.94))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
            )
            
            // 分隔线
            Rectangle()
                .fill(Color(white: 0.92))
                .frame(height: 1)
            
            // 内容区
            if isLoading {
                Spacer()
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text("正在提取内容...")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(white: 0.5))
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    Text(content)
                        .font(.system(size: fontSize, weight: .regular))
                        .foregroundColor(settings.highContrastMode ? .white : Color(white: 0.2))
                        .lineSpacing(10)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .background(
            settings.highContrastMode ? Color.black : Color(white: 0.98)
        )
        .task {
            await extractContent()
        }
    }
    
    private func extractContent() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = String(data: data, encoding: .utf8) {
                content = extractTextFromHTML(html)
            }
        } catch {
            content = "无法加载内容"
        }
        isLoading = false
    }
    
    private func extractTextFromHTML(_ html: String) -> String {
        var text = html
        
        let scriptPattern = "<script[^>]*>[\\s\\S]*?</script>"
        text = text.replacingOccurrences(of: scriptPattern, with: "", options: .regularExpression)
        
        let stylePattern = "<style[^>]*>[\\s\\S]*?</style>"
        text = text.replacingOccurrences(of: stylePattern, with: "", options: .regularExpression)
        
        let tagPattern = "<[^>]+>"
        text = text.replacingOccurrences(of: tagPattern, with: " ", options: .regularExpression)
        
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        
        let whitespacePattern = "\\s+"
        text = text.replacingOccurrences(of: whitespacePattern, with: " ", options: .regularExpression)
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
