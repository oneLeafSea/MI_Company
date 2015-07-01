//
//  RTSession.swift
//  testFramework
//
//  Created by 郭志伟 on 15/6/26.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

import Foundation

@objc public protocol RTSessionDelegate: class {
    func sessionDidConnect(session: RTSession)
    func sessionDidDisconnect(session: RTSession, error: NSError?)
    func sessionDidReceiveData(session: RTSession, data: NSData)
}

@objc public class RTSession: NSObject, NSStreamDelegate {
    
    public var queue = dispatch_get_main_queue()
    public var delegate: RTSessionDelegate?
    
    public var connected: Bool {
        get {
            return isInputStreamOpen && isOutputStreamOpen
        }
    }
    
    private var inputStream: NSInputStream?
    private var outputStream: NSOutputStream?
    
    private var ip: String
    private var port: UInt32
    
    private var isCreated = false
    private var isRunLoop = false
    private var isInputStreamOpen = false
    private var isOutputStreamOpen = false
    
    private var inputQueue = Array<NSData>()
    private var fragBuffer: NSData?
    
    let BUFFER_MAX = 2048
    
    private var writeQueue: NSOperationQueue!
    private var runloopQueue: dispatch_queue_t!
    
    public init(ip: String, port: UInt32) {
        self.ip = ip
        self.port = port;
    }
    
    public func connect() {
        if isCreated {
            return
        }
        runloopQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(runloopQueue, { () -> Void in
            self.isCreated = true
            self.createConnection()
            self.isCreated = false
        })
    }
    
    public func disconnect() {
        if !connected {
            return
        }
        dispatch_async(runloopQueue, { () -> Void in
            self.disconnectStream(nil)
        })
    }
    
    public func writeData(data: NSData) {
        let d = self.buildWriteData(data)
        self.dequeueWrite(d)
    }
    
    public func writeData(data: NSData, type: UInt32) {
        var combineData = NSMutableData();
        var bigEndianType = type.bigEndian
        combineData.appendBytes(&bigEndianType, length: sizeof(UInt32))
        combineData.appendData(data)
        self.writeData(combineData)
    }
    
    public func writeDict(dict: NSDictionary, type: UInt32) {
        var dictData = NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(0), error: nil)
        if let d = dictData {
            self.writeData(d, type: type)
        }
    }
    
    public func sendHb() {
        var zero: UInt32 = 0
        var data = NSData(bytes: &zero, length: sizeof(UInt32))
        self.dequeueWrite(data)
    }
    
    private func dequeueWrite(data: NSData) {
        if !self.connected {
            println("网络已经断开")
            return
        }
        if self.writeQueue == nil {
            self.writeQueue = NSOperationQueue()
            self.writeQueue.maxConcurrentOperationCount = 1
        }
        
        writeQueue.addOperationWithBlock { () -> Void in
            var total = 0
            while true {
                if self.outputStream == nil {
                    break
                }
                let writeBuffer = UnsafePointer<UInt8>(data.bytes + total)
                var len = self.outputStream?.write(writeBuffer, maxLength: data.length-total);
                if len == nil || len! < 0 {
                    break
                } else {
                    total += len!
                }
                if total >= data.length {
                    break
                }
            }
        }
    }
    
    private func buildWriteData(data: NSData) -> NSData {
        var data4Sending = NSMutableData();
        var dataSz: UInt32 = UInt32(data.length).bigEndian;
        data4Sending.appendBytes(&dataSz, length: sizeof(UInt32));
        data4Sending.appendData(data)
        return data4Sending;
    }
    
    private func createConnection() {
        var readStream: Unmanaged<CFReadStreamRef>?
        var writeStream: Unmanaged<CFWriteStreamRef>?
        CFStreamCreatePairWithSocketToHost(nil, self.ip, self.port, &readStream, &writeStream)
        inputStream = readStream!.takeUnretainedValue()
        outputStream = writeStream!.takeUnretainedValue()
        
        inputStream!.delegate = self
        outputStream!.delegate = self
        inputStream!.setProperty(NSStreamSocketSecurityLevelNegotiatedSSL, forKey: NSStreamSocketSecurityLevelKey)
        outputStream!.setProperty(NSStreamSocketSecurityLevelNegotiatedSSL, forKey: NSStreamSocketSecurityLevelKey)
        let settings: Dictionary<NSObject, NSObject> = [kCFStreamSSLValidatesCertificateChain: NSNumber(bool:false), kCFStreamSSLPeerName: kCFNull]
        inputStream!.setProperty(settings, forKey: kCFStreamPropertySSLSettings as! String)
        outputStream!.setProperty(settings, forKey: kCFStreamPropertySSLSettings as! String)
        isRunLoop = true
        inputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        inputStream!.open()
        outputStream!.open()
        while(isRunLoop) {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture() as! NSDate)
        }
    }
    
    // MARk: delegate
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        if eventCode == NSStreamEvent.HasBytesAvailable {
            if aStream == inputStream {
                self.processInputStream()
            }
        } else if eventCode == NSStreamEvent.ErrorOccurred {
            println("有错误发生")
            self.disconnectStream(aStream.streamError)
        } else if eventCode == NSStreamEvent.EndEncountered {
            println("接受到关闭信号")
            self.disconnectStream(nil)
        } else if eventCode == NSStreamEvent.OpenCompleted {
            self.processStreamOpen(aStream)
        }
        
    }
    
    private func processInputStream() {
        let buf = NSMutableData(capacity: BUFFER_MAX)
        var buffer = UnsafeMutablePointer<UInt8>(buf!.bytes)
        let length = inputStream!.read(buffer, maxLength: BUFFER_MAX)
        if length > 0 {
            println("接受到\(length)字节的数据")
            var process = false
            if inputQueue.count == 0 {
                process = true
            }
            inputQueue.append(NSData(bytes: buffer, length: length))
            if process {
                self.dequeueInput()
            }
        }
    }
    
    private func dequeueInput() {
        if inputQueue.count > 0 {
            let data = inputQueue[0]
            var work = data
            if fragBuffer != nil {
                var combine = NSMutableData(data: fragBuffer!)
                combine.appendData(data)
                work = combine
                fragBuffer = nil
            }
            let buffer = UnsafePointer<UInt8>(work.bytes)
            self.processRawMessage(buffer, bufferLen: work.length)
            inputQueue = inputQueue.filter{$0 != data}
            dequeueInput()
        }
    }
    
    private func processRawMessage(buffer: UnsafePointer<UInt8>, bufferLen: Int) {
        if bufferLen < 4 {
            if bufferLen == 0 {
                return
            }
            fragBuffer = NSData(bytes: buffer, length: bufferLen)
            return
        }
        
        let bytes = UnsafePointer<UInt32>(buffer)
        let dataLen = CFSwapInt32BigToHost(bytes[0])
        if dataLen == 0 {
            println("接受到心跳")
            return
        }
        
        if UInt32(bufferLen) < dataLen + 4 {
            fragBuffer = NSData(bytes: buffer, length: bufferLen)
            return
        }
        
        var codeBuffer = UnsafePointer<UInt8>(buffer + 4)
        
        var data = NSData(bytes: codeBuffer, length: Int(dataLen))
        dispatch_async(queue, { () -> Void in
            self.delegate?.sessionDidReceiveData(self, data: data)
        })
        processRawMessage(UnsafePointer<UInt8>(buffer + Int(4 + dataLen)), bufferLen: bufferLen - Int(4 + dataLen))
    }
    
    private func processStreamOpen(stream: NSStream) {
        if stream == inputStream {
            self.isInputStreamOpen = true
        }
        if stream == outputStream {
            self.isOutputStreamOpen = true
        }
        
        if self.isInputStreamOpen && self.isOutputStreamOpen {
            dispatch_async(self.queue, { () -> Void in
                self.delegate?.sessionDidConnect(self)
            })
        }
    }
    
    private func disconnectStream(error: NSError?) {
        if writeQueue != nil {
            writeQueue.waitUntilAllOperationsAreFinished()
        }
        if let stream = inputStream {
            stream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            stream.close()
            isInputStreamOpen = false
        }
        if let stream = outputStream {
            stream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            stream.close()
            isOutputStreamOpen = false
        }
        outputStream = nil
        inputStream = nil
        isRunLoop = false
        isCreated = false
        runloopQueue = nil
        
        dispatch_async(queue, { () -> Void in
            self.delegate?.sessionDidDisconnect(self, error: error)
        })
    }
}