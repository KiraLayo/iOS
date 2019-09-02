//
//  Stack.swift
//  StructureKit
//
//  Created by yp-tc-m-2548 on 2019/9/2.
//  Copyright © 2019年 com.yeepay. All rights reserved.
//

import Foundation

public struct Stack<T> {
    
    var stack:[T] = [T]();
    
    public var count:Int {
        return stack.count;
    }
    
    public var isEmpty:Bool {
        return stack.isEmpty;
    }
    
    public var top:T? {
        return stack.first;
    }
    
    public mutating func push(value:T) {
        stack.append(value);
    }

    public mutating func pop() -> T? {
        if self.isEmpty {
            print("Error: empty!")
            return nil;
        }
        return stack.removeLast();
    }
}
