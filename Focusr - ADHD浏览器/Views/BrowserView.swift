//
//  BrowserView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI

struct BrowserView: View {
    @State private var viewModel = BrowserViewModel()
    @State private var activeSheet: SheetType?
    @Environment(\.colorScheme) var colorScheme
    
    enum SheetType: String, Identifiable {
        case menu, bookmarks, history, settings, notes, sessions
        var id: String { rawValue }
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background
            Theme.backgroundGradient(for: colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // URL Bar
                if !viewModel.showFocusMode {
                    URLBar(
                        urlInput: $viewModel.urlInput,
                        isLoading: viewModel.isLoading,
                        currentURL: viewModel.currentTab.url,
                        onSubmit: { viewModel.navigate(to: viewModel.urlInput) },
                        onMenu: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                activeSheet = .menu
                            }
                        },
                        onRefresh: { viewModel.reload() }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 4)
                }
                
                // Content Area
                ZStack(alignment: .top) {
                    if viewModel.currentTab.url == nil {
                        HomeView(viewModel: viewModel)
                    } else if viewModel.showReaderMode {
                        ReaderModeView(url: viewModel.currentTab.url!) {
                            viewModel.toggleReaderMode()
                        }
                    } else {
                        WebView(
                            url: viewModel.currentTab.url,
                            canGoBack: $viewModel.canGoBack,
                            canGoForward: $viewModel.canGoForward,
                            isLoading: $viewModel.isLoading,
                            currentURL: .constant(viewModel.currentTab.url),
                            pageTitle: .constant(viewModel.currentTab.title),
                            onNavigate: { url, title in
                                viewModel.updateCurrentTab(url: url, title: title)
                            },
                            webViewStore: viewModel.webViewStore
                        )
                    }
                    
                    // Focus Mode Bar
                    if viewModel.showFocusMode {
                        FocusModeBar(timer: viewModel.focusTimer) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                viewModel.toggleFocusMode()
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Loading Indicator
                    if viewModel.isLoading && viewModel.currentTab.url != nil {
                        VStack {
                            GeometryReader { geo in
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Theme.Colors.accent.opacity(0.3),
                                                Theme.Colors.accent,
                                                Theme.Colors.accent.opacity(0.3)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 3)
                            }
                            .frame(height: 3)
                            .shadow(color: Theme.Colors.accent.opacity(0.5), radius: 2)
                            Spacer()
                        }
                    }
                }
                
                // Navigation Bar
                if !viewModel.showFocusMode {
                    NavigationBar(viewModel: viewModel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.showFocusMode)
            
            // Tabs Overlay
            if viewModel.showTabsView {
                TabsOverlayView(viewModel: viewModel)
                    .transition(.opacity)
                    .zIndex(50)
            }
            
            // Sidebar Menu Overlay
            if activeSheet == .menu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            activeSheet = nil
                        }
                    }
                    .zIndex(100)
                
                MenuView(
                    viewModel: viewModel,
                    onNavigate: { sheet in
                        withAnimation(.easeOut(duration: 0.2)) {
                            // Delay slightly to allow sidebar to close visually or just switch?
                            // Switching directly works best for UX usually.
                            activeSheet = sheet
                        }
                    },
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            activeSheet = nil
                        }
                    }
                )
                .frame(width: 300)
                .background(Theme.Colors.surface)
                .ignoresSafeArea()
                .transition(.move(edge: .leading))
                .zIndex(101)
            }
        }
        // Unified Sheet Management (Excluding Menu)
        .sheet(item: sheetBinding) { type in
            Group {
                switch type {
                case .menu:
                    EmptyView() // Should not happen via sheet
                case .bookmarks:
                    BookmarksView(viewModel: viewModel)
                case .history:
                    HistoryView(viewModel: viewModel)
                case .settings:
                    SettingsView()
                case .notes:
                    NotesView()
                case .sessions:
                    SessionsView(viewModel: viewModel)
                }
            }
            .presentationDragIndicator(.visible)
            .presentationBackground(.ultraThinMaterial)
            .presentationCornerRadius(24)
        }
        .alert("Site Locked", isPresented: $viewModel.showSiteLocked) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Daily limit reached for this site.")
        }
        .task {
            // Compile AdBlock Rules in Background
            try? await ContentBlocker.shared.compileRules()
        }
    }
    
    // Custom binding to filter out .menu from sheet modifier
    private var sheetBinding: Binding<SheetType?> {
        Binding(
            get: { activeSheet == .menu ? nil : activeSheet },
            set: {
                if let val = $0, val != .menu { activeSheet = val }
                else if $0 == nil && activeSheet != .menu { activeSheet = nil }
            }
        )
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
