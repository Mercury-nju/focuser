//
//  FocusTimer.swift
//  Focusr - ADHD浏览器
//

import Foundation
import Combine
import UserNotifications
#if os(iOS)
import UIKit
#endif

final class FocusTimer: ObservableObject {
    enum TimerState {
        case idle, focusing, resting
    }
    
    @Published var state: TimerState = .idle
    @Published var remainingSeconds: Int = 0
    @Published var totalFocusSessions: Int = 0
    @Published var treeGrowth: Double = 0
    
    private var timer: Timer?
    private let focusDuration = 25 * 60
    private let restDuration = 5 * 60
    
    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progress: Double {
        guard state != .idle else { return 0 }
        let total = state == .focusing ? focusDuration : restDuration
        guard total > 0 else { return 0 }
        return Double(total - remainingSeconds) / Double(total)
    }
    
    init() {
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    func startFocus() {
        stopTimer()
        state = .focusing
        remainingSeconds = focusDuration
        treeGrowth = 0
        startTimer()
        triggerHaptic()
    }
    
    func startRest() {
        stopTimer()
        state = .resting
        remainingSeconds = restDuration
        startTimer()
        triggerHaptic()
    }
    
    func stop() {
        stopTimer()
        state = .idle
        remainingSeconds = 0
        treeGrowth = 0
    }
    
    func pause() {
        stopTimer()
    }
    
    func resume() {
        if remainingSeconds > 0 && state != .idle {
            startTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tick()
            }
        }
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func tick() {
        guard remainingSeconds > 0 else {
            timerCompleted()
            return
        }
        
        remainingSeconds -= 1
        
        if state == .focusing {
            treeGrowth = min(1.0, Double(focusDuration - remainingSeconds) / Double(focusDuration))
        }
    }
    
    private func timerCompleted() {
        stopTimer()
        triggerHaptic()
        sendCompletionNotification()
        
        if state == .focusing {
            totalFocusSessions += 1
            startRest()
        } else {
            state = .idle
            treeGrowth = 0
        }
    }
    
    private func sendCompletionNotification() {
        let content = UNMutableNotificationContent()
        if state == .focusing {
            content.title = "专注完成 🎉"
            content.body = "太棒了！休息5分钟吧"
        } else {
            content.title = "休息结束"
            content.body = "准备好开始下一轮专注了吗？"
        }
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func triggerHaptic() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
}
