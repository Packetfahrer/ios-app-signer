//
//  NSTask-execute.swift
//  AppSigner
//
//  Created by Daniel Radtke on 11/3/15.
//  Copyright © 2015 Daniel Radtke. All rights reserved.
//

import Foundation
struct AppSignerTaskOutput {
    var output: String
    var status: Int32
    init(status: Int32, output: String){
        self.status = status
        self.output = output
    }
}
extension NSTask {
    func launchSyncronous() -> AppSignerTaskOutput {
        self.standardInput = NSFileHandle.fileHandleWithNullDevice()
        let pipe = NSPipe()
        self.standardOutput = pipe
        self.standardError = pipe
        let pipeFile = pipe.fileHandleForReading
        self.launch()
        
        let data = NSMutableData()
        while self.running {
            data.appendData(pipeFile.availableData)
        }
        
        let output = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        
        return AppSignerTaskOutput(status: self.terminationStatus, output: output)
        
    }
    
    func execute(launchPath: String, workingDirectory: String?, arguments: [String]?)->AppSignerTaskOutput{
        self.launchPath = launchPath
        if arguments != nil {
            self.arguments = arguments
        }
        if workingDirectory != nil {
            self.currentDirectoryPath = workingDirectory!
        }
        return self.launchSyncronous()
    }
    
}