//
//  tools.swift
//  DLCompiler
//
//  Created by 在百慕大钓鱼的人 on 2026/1/2.
//

import Foundation

func errorHandler(errorInfo : [String] = []) {
    print("An error has been detected:")
    for info in errorInfo {
        print(info)
    }
    exit(-1)
}

func mysteriousErrorHandler(errorInfo : [String]) {
    print("It seems a mysterious error has occurred, but this error shouldn't have happened:")
    for info in errorInfo {
        print(info)
    }
    exit(-1)
}

func warningHandler(warningInfo : [String] = []) {
    print("A warning has been detected:")
    for info in warningInfo {
        print(info)
    }
    return
}

func string2bool(str : String) -> Bool? {
    switch (str) {
    case "1":
        fallthrough
    case "True":
        fallthrough
    case "true":
        return true
    case "0":
        fallthrough
    case "False":
        fallthrough
    case "false":
        return false
    default:
        return nil
    }
}
