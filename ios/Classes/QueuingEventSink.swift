//
//  QueuingEventSink.swift
//  a_player
//
//  Created by drm-chao wang on 2022/6/27.
//

import Foundation
import Flutter

class EndOfStreamEvent {}
class ErrorEvent {
    public let code: String
    public let message: String
    public let details: Any
    init(code: String, message: String, details: Any) {
        self.code = code
        self.message = message
        self.details = details
    }
}
class QueuingEventSink: NSObject {
    private var delegate: FlutterEventSink? = nil;
    private var eventQueue = [Any]()
    private var done = false
    
    func setDelegate(delegate: FlutterEventSink?) -> Void {
        self.delegate = delegate
        maybeFlush()
    }
    func endOfStream() -> Void {
        enqueue(event: EndOfStreamEvent())
        maybeFlush()
        done = true
    }
    func error(code: String, message: String, details: Any) -> Void {
        enqueue(event: ErrorEvent.init(code: code, message: message, details: details))
        maybeFlush()
    }
    
    func success(event: Any) -> Void {
        enqueue(event: event)
        maybeFlush()
    }
    
    private func enqueue(event: Any) -> Void {
        if (done) {
            return
        }
        self.eventQueue.append(event)
    }
    private func maybeFlush() -> Void {
        if (self.delegate == nil) {
            return
        }
        self.eventQueue.forEach({(event: Any) in
            if (event is EndOfStreamEvent) {
                self.delegate!(FlutterEndOfEventStream)
            } else if (event is ErrorEvent) {
                let e = event as! ErrorEvent
                self.delegate!(FlutterError(code: e.code, message: e.message, details: e.details))
            } else {
                self.delegate!(event)
            }
        })
        
        self.eventQueue.removeAll()
        
    }
}
