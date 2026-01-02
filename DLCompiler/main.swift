//
//  main.swift
//  DLCompiler
//
//  Created by 在百慕大钓鱼的人 on 2026/1/2.
//

import Foundation

func main() {
    print("VERSION \(INFO.VERSION)")

    guard let str_toks = getTokens(from: .STD, filePath: "~/Code/XCode/DLCompiler/DLCompiler/test.dl") else {
        errorHandler()
        return
    }

    print(str_toks)
    
    var ast : AST = AST(str_toks: str_toks)
    
    ast.printAllToks()
    
    print("Starting to build the AST tree.")
    
    while (true) {
        let tok = ast.peek()
        if (tok.type == .ALLDONE) {
            break
        }
        
        switch (tok.type) {
        case .IO:
            parseIO(ast: &ast)
        case .VARIABLE:
            parseVariable(ast: &ast)
        default:
            ast.advance()
        }
    }
    
    print("AST tree construction completed.")
    ast.printAllNodes()
    
    print("Starting logic verification.")
    verifyLogic(astNodeList: &ast.nodes)
    print("Logic verification passed.")
    
    print("Start running.")
    let runner : Runner = Runner(ast: ast)
    runner.run()
    
    exit(0)
}

main()
