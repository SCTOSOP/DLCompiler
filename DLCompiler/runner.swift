//
//  runner.swift
//  DLCompiler
//
//  Created by 在百慕大钓鱼的人 on 2026/1/21.
//

import Foundation

class Runner {
    private let astNodeList : [ASTNode]
    
    var variableMap : [String : Bool] = [:]
    
    init(ast: AST) {
        self.astNodeList = ast.nodes
    }
    
    private func readBool(for variableName: String) -> Bool {
        while true {
            print("INPUT(\(variableName)) >>> ", terminator: "")

            let line = readLine()!

            if let value = string2bool(str: line.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return value
            }

            print("Invalid input. Please enter true/false (or 1/0).")
        }
    }
    
    func run() {
        var runIndex : Int = 0
        
        func io_input(variableNameList : [String]) {
            for variableName in variableNameList {
                variableMap[variableName] = readBool(for: variableName)
            }
        }
        
        func io_output(variableNameList : [String]) {
            for variableName in variableNameList {
                print("\(variableName) is \(variableMap[variableName]!)")
            }
        }
        
        func calculateExpr(_ expr : EXPR) -> Bool {
            var result : Bool
            
            switch(expr) {
            case .variable(let str):
                return variableMap[str]!
            case .and(let exprList):
                result = true
                for exprIndex in exprList.indices {
                    result = result && calculateExpr(exprList[exprIndex])
                }
                return result
            case .or(let exprList):
                result = false
                for exprIndex in exprList.indices {
                    result = result || calculateExpr(exprList[exprIndex])
                }
                return result
            case .not(let expr):
                return !calculateExpr(expr)
            }
        }
        
        while (runIndex < astNodeList.count) {
            switch (astNodeList[runIndex]) {
            case .io(let ioType, let variableNameList):
                switch (ioType) {
                case .input:
                    io_input(variableNameList: variableNameList)
                case .output:
                    io_output(variableNameList: variableNameList)
                }
            case .assign(let to, let expr):
                variableMap[to] = calculateExpr(expr)
            }
            
            runIndex += 1
        }
    }
}
