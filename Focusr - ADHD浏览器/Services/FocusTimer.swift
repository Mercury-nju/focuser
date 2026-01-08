//
//  FocusTimer.swift
//  Focusr - ADHD浏览器
//

import Foundation
import UIKit

@Observable
final class FocusTimer {
    enum TimerState {
        case idle, focusing, resting
    }
    
    var state: TimerState = .idle
    var remainingSeconds: Int = 0
    var totalFocusSessions: Int = 0
    var treeGrowth: Double = 0
    
    private var timer: Timer?
    private let focusDuration = 25 * 60  // 25分钟
    private let restDuration = 5 * 60    // 5分钟
    
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
    
    func startFocus() {
        stopTimer()
        state = .focusing
        remainingSeconds = focusDuration
        treeGrowth = 0
        startTimer()
        triggerHaptic(.medium)
    }
    
    func startRest() {
        stopTimer()
        state = .resting
        remainingSeconds = restDuration
        startTimer()
        triggerHaptic(.light)
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
        // 确保timer在滚动时也能工作
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
        triggerHaptic(.heavy)
        
        if state == .focusing {
            totalFocusSessions += 1
            // 自动开始休息
            startRest()
        } else {
            // 休息结束，回到空闲状态
            state = .idle
            treeGrowth = 0
        }
    }
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #endif
    }
}
