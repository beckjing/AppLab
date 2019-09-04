//
//  SourceEditorCommand.swift
//  FormatterExtension
//
//  Created by yuecheng on 2019/8/21.
//  Copyright © 2019 NanoSparrow. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        formatLines(invocation: invocation);
        completionHandler(nil)
    }
    
    
    func formatLines(invocation: XCSourceEditorCommandInvocation) -> Void {
        let lines = invocation.buffer.lines
        let select = invocation.buffer.selections.firstObject as! XCSourceTextRange
        let selectRange = IndexSet(integersIn: select.start.line...select.end.line)
        let selectLine = invocation.buffer.lines.objects(at: selectRange)
        for line : String in selectLine as! [String] {
            NSLog("select line:%@", line)
        }
//        let updatedText = Array(lines.reversed())
//        lines.removeAllObjects()
//        lines.addObjects(from: updatedText)
        NSLog("%@", select);
    }
    
    class var 
}
