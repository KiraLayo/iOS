//
//  Queue.swift
//  StructureKit
//
//  Created by yp-tc-m-2548 on 2019/9/2.
//  Copyright © 2019年 com.yeepay. All rights reserved.
//

import Foundation

public struct Queue<T> {
    
    var queue: [T] = [T]();
    
    public var count: Int {
        return queue.count;
    }
    
    public var isEmpty: Bool {
        return queue.isEmpty;
    }
    
    public mutating func enqueue(value: T) {
        queue.append(value);
    }
    
    public mutating func dequeue() -> T?{
        if isEmpty {
            print("Error: isEmpty");
            return nil;
        }
        return queue.removeFirst();
    }
}
