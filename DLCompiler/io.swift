//
//  io.swift
//  DLCompiler
//
//  Created by 在百慥大钓鱼的人 on 2026/1/2.
//

import Foundation

enum IO {
    case STD
    case FILE
}

enum STR_STATE {
    case LETTER
    case NUMBER
    case SIGN
    case BLANK
    case DEFAULT
}

func getTokens(from : IO, filePath : String? = nil) -> [String]? {
    var str : String = String()
    var result : [String] = Array()
    
    switch (from) {
    case IO.STD:
        var newLine : String = readLine()!
        while (newLine != "EOF") {
            str += newLine
            newLine = readLine()!
        }
    case IO.FILE:
        guard let filePath = filePath else {return nil}
        let fileURL = URL(fileURLWithPath: filePath)
        do {
            str = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("Cannot open the file \(filePath)")
            return nil
        }
    }
    
    var strBuffer : String = String()
    var preState : STR_STATE = STR_STATE.DEFAULT

    func flushBuffer() {
        if !strBuffer.isEmpty {
            result.append(strBuffer)
            strBuffer = ""
        }
    }

    for ch in str {
        switch ch {
        case _ where ch.isLetter:
            if preState != .LETTER {
                flushBuffer()
                preState = .LETTER
            }
            strBuffer.append(ch)
        case _ where ch.isNumber:
            if preState == .LETTER {
                strBuffer.append(ch)
            } else {
                if preState != .NUMBER {
                    flushBuffer()
                    preState = .NUMBER
                }
                strBuffer.append(ch)
            }
        case _ where ch.isWhitespace || ch.isNewline:
            flushBuffer()
            preState = .BLANK
        default:
            if preState != .SIGN {
                flushBuffer()
                preState = .SIGN
            }
            strBuffer.append(ch)
        }
    }
    flushBuffer()
    
    return result
}
