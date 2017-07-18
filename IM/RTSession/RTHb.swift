//
//  RTHb.swift
//  testFramework
//
//  Created by 郭志伟 on 15/6/29.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

import UIKit

@objc class RTHb: NSObject {
    var queue: dispatch_queue_t = dispatch_get_main_queue()
    var timer: dispatch_source_t!
    
    let interval: UInt32
    unowned let session: RTSession
    
    private var running: Bool = false
    
    init(interval: UInt32, session: RTSession) {
        self.interval = interval
        self.session = session
        super.init()
    }
    
    func start() {
        if running {
            return
        }
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, UInt64(interval) * NSEC_PER_SEC, UInt64(interval) * NSEC_PER_SEC)
        dispatch_source_set_event_handler(timer, { () -> Void in
            self.session.sendHb()
        })
        dispatch_resume(timer)
        running = true
    }
    
    func stop() {
        dispatch_source_cancel(timer)
        running = false
    }

}
