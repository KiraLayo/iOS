//
//  LinkedListNode.swift
//  StructureKit
//
//  Created by yp-tc-m-2548 on 2019/9/2.
//  Copyright © 2019年 com.yeepay. All rights reserved.
//

import Foundation

public class LinkedListNode<T> {
    //value of a node
    var value: T;
    
    //pointer to previous node
    var previous: LinkedListNode?;
    
    //pointer to next node
    var next: LinkedListNode?;
    
    //init
    public init(value: T) {
        self.value = value;
    }
}

public class LinkedList<T> {
    //typealias
    public typealias Node = LinkedListNode<T>;
    
    //if empty
    public var isEmpty: Bool {
        return head == nil
    }
    
    //total count of nodes
    public var count: Int {
        guard var node = head else {
            return 0
        }
        
        var count = 1
        while let next = node.next {
            node = next
            count += 1
        }
        return count
    }
    
    //pointer to the first node
    public var head: Node?
    
    //pointer to the last node
    public var last: Node? {
        
        guard var node = head else {
            return nil
        }
        
        //until node.next is nil
        while let next = node.next {
            node = next
        }
        return node
    }
    
    public init() {
    }
}

public extension LinkedList {
    func node(index:Int) -> Node? {
        if 0 == index {
            return head;
        } else {
            if index > count {
                return nil;
            }
            
            var node:Node? = head!.next;
            
            for _ in 1..<index{
                node = node?.next;
            }
            
            return node;
        }
    }
    
    func insert(newNode:Node, index:Int){
        if(index > count) || (index < 0) {
            print("out of range!");
            return;
        }
        
        //Judge1
        if 0 == index {//head
            head?.previous = newNode;
            head = newNode;
        }else {//middle and last
            let indexNode = self.node(index: index)!;
            let preNode = indexNode.previous!
            
            indexNode.previous = newNode;
            preNode.next = newNode;
            newNode.next = indexNode;
            newNode.previous = preNode;
        }
    }
    
    public func remove(index:Int) {
        if index > count || index < 0 || self.isEmpty {
            print("out of range")
            return;
        }
        
        if 0 == index {
            head = nil;
        }else{
            let indexNode = self.node(index: index)!;
            
            let nextNode = indexNode.next;
            let preNode = indexNode.previous!;
            
            preNode.next = nextNode;
            nextNode?.previous = preNode;
        }
    }
}
