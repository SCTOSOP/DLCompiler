//
//  optimizer.swift
//  DLCompiler
//
//  Created by 在百慕大钓鱼的人 on 2026/1/22.
//

import Foundation

class OperationTreeNode {
    var left : OperationTreeNode
    var operation_type : OPERATE_TYPE
    var right : OperationTreeNode
    
    init(left: OperationTreeNode, operation_type : OPERATE_TYPE,  right: OperationTreeNode) {
        self.left = left
        self.operation_type = operation_type
        self.right = right
    }
}

class Optimizer {
    private let astNodeList : [ASTNode]
    
    init(astNodeList: [ASTNode]) {
        self.astNodeList = astNodeList
    }
    
    
}
