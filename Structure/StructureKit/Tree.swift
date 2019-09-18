//
//  Tree.swift
//  StructureKit
//
//  Created by yp-tc-m-2548 on 2019/9/2.
//  Copyright © 2019年 com.yeepay. All rights reserved.
//

import UIKit

enum TreeSpreadType {
    case level;
    case depth;
}

public class TreeNode<T> {
    var value: T;
    
    var left:TreeNode?;
    var right:TreeNode?;
    
    public init(value:T){
        self.value = value;
    }
    
    public class func front(node: TreeNode) {
        print(node.value);
        print("|")
        if node.left != nil {
            self.front(node: node.left!);
        }else{
            print("口");
        }
        if node.left != nil {
            self.front(node: node.right!);
        }else{
            print("口", terminator: "");
        }
    }
    
    public func middle(node: TreeNode) {
        
        if node.left != nil {
            self.middle(node: node.left!);
        }else{
            print("口");
        }
        
        print(node.value);
        
        if node.left != nil {
            self.middle(node: node.right!);
        }else{
            print("口");
        }
    }
    
    public func last(node: TreeNode) {
        
        if node.left != nil {
            self.middle(node: node.left!);
        }else{
            print("口");
        }
        
        if node.left != nil {
            self.middle(node: node.right!);
        }else{
            print("口");
        }
        
        print(node.value);
    }
}

class Tree<T> {
    public var root: TreeNode<T>?;
    
    public var isEmpty: Bool {
        return root == nil;
    }
    
    public init(nodes:[T]) {
        for index in 0..<nodes.count/2 {
            
            let node = TreeNode<T>(value: nodes[index]);
            node.left = TreeNode<T>(value: nodes[index * 2 + 1]);
            node.right = TreeNode<T>(value: nodes[index * 2 + 2]);
            
            if 0 == index {
                root = node;
            }
        }
    }
    
    public func printAll(type:TreeSpreadType){
        switch type {
        case .level:
            guard isEmpty else {
                TreeNode.front(node: root!);
                return;
            }
//        case .depth:
//            print("");
        default: break
        }
    }
}
