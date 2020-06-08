//
//  RepeatingTimer.swift
//  JustLog
//
//  Created by Junaid Younus on 08/06/2020.
//  Copyright © 2020 Just Eat. All rights reserved.
//
//  https://medium.com/over-engineering/a-background-repeating-timer-in-swift-412cecfd2ef9 

import Foundation

/// RepeatingTimer mimics the API of DispatchSourceTimer but in a way that prevents crashes that occur from calling resume multiple times on a timer that is
/// already resumed (noted by https://github.com/SiftScience/sift-ios/issues/52)
internal class RepeatingTimer {

    let timeInterval: TimeInterval
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        t.setCancelHandler(handler: { [weak self] in
            self?.cancelHandler?()
        })
        return t
    }()

    var eventHandler: (() -> Void)?
    var cancelHandler: (() -> Void)?

    private enum State {
        case suspended
        case running
    }

    private var state: State = .suspended

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        run()
        eventHandler = nil
    }

    func run() {
        guard state != .running else { return }
        state = .running
        timer.resume()
    }

    func suspend() {
        guard state != .suspended else { return }
        state = .suspended
        timer.suspend()
    }
}
