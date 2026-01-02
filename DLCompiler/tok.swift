//
//  tok.swift
//  DLCompiler
//
//  Created by 在百慕大钓鱼的人 on 2026/1/2.
//

enum TOK_TYPE {
    case NULL
    
    case OPERATOR
    
    case IO
    
    case NUMBER
    case VARIABLE
    
    case OPENINGPARENTHESIS
    case CLOSINGPARENTHESIS
    
    case EOF
    case ALLDONE
}

struct TOK {
    let str : String
    let type : TOK_TYPE
    
    init(str: String) {
        self.str = str
        self.type = TOK_TYPE.NULL
    }
    
    init(str: String, type: TOK_TYPE) {
        self.str = str
        self.type = type
    }
}

let keywordMap: [String: TOK_TYPE] = [
    "and": .OPERATOR,
    "or": .OPERATOR,
    "not": .OPERATOR,
    "input": .IO,
    "output": .IO,
    ";": .EOF,
    "EOF": .ALLDONE
]

func getTokType(str : String) -> TOK {
    let key = str.lowercased()
    
    if let t = keywordMap[key] {
        return TOK(str: str, type: t)
    }
    
    if (str.allSatisfy({ $0.isNumber })) {
        return TOK(str: str, type: .NUMBER)
    }
    
    if (str == "(") {
        return TOK(str: str, type: .OPENINGPARENTHESIS)
    }
    
    if (str == ")") {
        return TOK(str: str, type: .CLOSINGPARENTHESIS)
    }
    
    return TOK(str: str, type: .VARIABLE)
}
