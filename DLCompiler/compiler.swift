//
//  compiler.swift
//  DLCompiler
//
//  Created by 在百慕大钓鱼的人 on 2026/1/15.
//

enum OPERATE_TYPE {
    case AND
    case OR
    case NOT
    case ERR
}

enum IO_TYPE {
    case input
    case output
}

indirect enum EXPR {
    case variable(str : String)
    case and(exprList : [EXPR])
    case or(exprList : [EXPR])
    case not(expr : EXPR)
}

enum ASTNode {
    case io(ioType : IO_TYPE, variableNameList : [String])
    case assign(to: String, expr: EXPR)
}

struct AST {
    let toks : [TOK]
    var nodes: [ASTNode] = []
    var index : Int
    
    init(toks: [TOK]) {
        self.toks = toks
        self.nodes = Array()
        self.index = 0
    }
    
    init(str_toks: [String]) {
        self.toks = {
            var toks : [TOK] = Array()
            for i in str_toks.indices {
                let tok = getTokType(str: str_toks[i])
                
                if (tok.type == .NULL) {
                    errorHandler(errorInfo: ["The type of \(tok.str) is NULL."])
                }
                
                toks.append(tok)
            }
            return toks
        }()
        self.nodes = Array()
        self.index = 0
    }
    
    mutating func expect(tokTypeList : [TOK_TYPE]) -> TOK? {
        let tok = toks[index]
        
        guard tokTypeList.contains(tok.type) else {
            errorHandler(errorInfo: ["!!!Expect: \(tokTypeList) after \((index==0) ? "" : toks[index-1].str) around \(String(describing: self.anround())) not \(tok.str)"])
            return tok
        }
        
        index += 1
        return tok
    }
    
    func peek() -> TOK {
        return (index < toks.count) ? toks[index] : TOK(str: "", type: .ALLDONE)
    }
    
    mutating func advance() {
        index += 1
    }
    
    func printAllToks() {
        for tok in toks {
            print(tok)
        }
    }
    
    func printAllNodes() {
        print("AST Nodes:")
        for node in nodes {
            print(node)
        }
    }
    
    func anround() -> [String] {
        var result : [String] = []
        if (index-2>0) {
            result.append(toks[index-2].str)
        }
        if (index-1>0) {
            result.append(toks[index-1].str)
        }
        result.append(toks[index].str)
        if (index+1<toks.count-1) {
            result.append(toks[index+1].str)
        }
        if (index+2<toks.count-1) {
            result.append(toks[index+2].str)
        }
        return result
    }
    
    func getPreviousTok() -> TOK {
        return (index==0) ? TOK(str: "", type: .EOF) : toks[index-1]
    }
}

func parseIO(ast : inout AST) {
    var inputvariableNameList : [String] = []
    guard let tok_func = ast.expect(tokTypeList: [.IO]) else { return }
    
    guard let io_tpye : IO_TYPE = {
        switch (tok_func.str) {
        case "input":
            return .input
        case "output":
            return .output
        default:
            mysteriousErrorHandler(errorInfo: [""])
            return nil
        }
    }() else { return }
    
    guard let tok_variable = ast.expect(tokTypeList: [.VARIABLE]) else { return }
    inputvariableNameList.append(tok_variable.str)

    
    loop: while (true) {
        guard let tok = ast.expect(tokTypeList: [.VARIABLE, .EOF]) else { return }
        switch (tok.type) {
        case .VARIABLE:
            inputvariableNameList.append(tok.str)
        default:
            break loop
        }
    }
    
    ast.nodes.append(.io(ioType: io_tpye, variableNameList: inputvariableNameList))
}

func parseExpr(ast : inout AST) -> EXPR {
    guard let tok_operate = ast.expect(tokTypeList: [.OPERATOR]) else {
        return .variable(str: "")
    }
    
    var exprList : [EXPR] = []
    
    loop: while (true) {
        guard let tok2 = ast.expect(tokTypeList: [.OPENINGPARENTHESIS, .VARIABLE, .EOF, .CLOSINGPARENTHESIS]) else {
            return .variable(str: "")
        }
        print(tok2)
        switch (tok2.type) {
        case .OPENINGPARENTHESIS:
            exprList.append(parseExpr(ast: &ast))
        case .VARIABLE:
            exprList.append(.variable(str: tok2.str))
        case .EOF:
            break loop
        case .CLOSINGPARENTHESIS:
            break loop
        default:
            errorHandler(errorInfo: ["Expect EOF or CLOSINGPARENTHESIS."])
        }
    }
    
    return {
        switch (tok_operate.str) {
        case "and":
            fallthrough
        case "AND":
            return .and(exprList: exprList)
        case "or":
            fallthrough
        case "OR":
            return .or(exprList: exprList)
        case "not":
            fallthrough
        case "NOT":
            return .not(expr: exprList[0])
        default:
            // 不可能
            return .variable(str: "")
        }
    }()
}

func parseVariable(ast : inout AST) {
    guard let tok_to = ast.expect(tokTypeList: [.VARIABLE]) else { return }
    
    ast.nodes.append(.assign(to: tok_to.str, expr: parseExpr(ast: &ast)))
}

func verifyLogic(astNodeList : inout [ASTNode]) {
    var ASTvariableNameList : Set<String> = []
    var ASTindex : Int = 0
    
    func check_if_a_variable_exists(_ variableName : String) {
        guard ASTvariableNameList.contains(variableName) else {
            errorHandler(errorInfo: ["The variable \"\(variableName)\" is not defined,", "at \(astNodeList[ASTindex])"])
            return
        }
    }
    
    func check_if_a_variable_exists_in_expr(_ expr : EXPR) {
        switch (expr) {
        case .variable(let str):
            check_if_a_variable_exists(str)
        case .and(let exprList):
            for exprIndex in exprList.indices { check_if_a_variable_exists_in_expr(exprList[exprIndex]) }
        case .or(let exprList):
            for exprIndex in exprList.indices { check_if_a_variable_exists_in_expr(exprList[exprIndex]) }
        case .not(let expr):
            check_if_a_variable_exists_in_expr(expr)
        }
    }
    
    while(ASTindex < astNodeList.count) {
        switch (astNodeList[ASTindex]) {
        case .io(let ioType, let variableNameList):
            switch (ioType) {
            case .input:
                for variableName in variableNameList { ASTvariableNameList.insert(variableName)}
            case .output:
                for variableName in variableNameList { check_if_a_variable_exists(variableName) }
            }
        case .assign(let to, let expr):
            ASTvariableNameList.insert(to)
            check_if_a_variable_exists_in_expr(expr)
            break
        default:
            break
        }
        ASTindex += 1
    }
}
