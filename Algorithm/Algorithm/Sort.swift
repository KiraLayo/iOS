//
//  Sort.swift
//  Algorithm
//
//  Created by yp-tc-m-2548 on 2019/9/18.
//  Copyright © 2019年 com.KiraLayo. All rights reserved.
//

import Foundation

public class Sort {
    //基础冒泡
    public class func bubbleSort(nums:[Int]){
        var sorted = nums;
        for i in 0..<sorted.count {
            for j in 0..<(sorted.count-i-1){
                if sorted[j] > sorted[j + 1] {
                    sorted.swapAt(j, j+1);
                }
            }
        }
        print(sorted);
    }
    //优化冒泡1：若未发生交换，则说明已是有序
    public class func bubbleSort1(nums:[Int]){
        var sorted = nums;
        for i in 0..<sorted.count {
            var isSorted = false;
            if sorted[i] < sorted[i+1] {continue};
            for j in 0..<(sorted.count-i-1){
                if sorted[j] > sorted[j + 1] {
                    sorted.swapAt(j, j+1);
                    isSorted = true;
                }
            }
            if isSorted {break;}
        }
        print(sorted);
    }
    
    //优化冒泡2：若某位置之后未发生交换，则说明该位置后已是有序
    public class func bubbleSort2(nums:[Int]){
        var sorted = nums;
        
        var last = nums.count-1;
        
        for _ in 0..<sorted.count {
            var isSorted = true;
            for j in 0..<last{
                if sorted[j] > sorted[j + 1] {
                    sorted.swapAt(j, j+1);
                    isSorted = false;
                    last = j;
                }
            }
            if isSorted {break;}
        }
        print(sorted);
    }
    
    //优化冒泡3：若某位置之后未发生交换，则说明该位置后已是有序
    public class func bubbleSort3(nums:[Int]){
        var sorted = nums;
        
        var start = 0;
        var end = sorted.count - 1;
        
        for _ in 0..<sorted.count {
            
            var isSorted = true;
            
            for i in start..<end{
                if sorted[i] > sorted[i + 1] {
                    sorted.swapAt(i, i + 1);
                    isSorted = false;
                    end = i;
                }
            }
            
            if isSorted {break;}
            
            isSorted = true;
            
            for j in (start..<end).reversed(){
                if sorted[j] > sorted[j + 1] {
                    sorted.swapAt(j, j + 1);
                    isSorted = false;
                    start = j + 1;
                }
            }
            
            if isSorted {break;}
        }
        print(sorted);
    }
    
    class func insertSort(nums:[Int]) {
        var sorted = nums;
        
        for i in 1..<sorted.count {
            var preIndex = i - 1;
            let current = sorted[i];
            
            while (preIndex >= 0) && (sorted[preIndex] > current) {
                sorted[preIndex + 1] = sorted[preIndex];
                preIndex -= 1;
            }
            sorted[preIndex + 1] = current;
        }
        
        print(sorted);
    }
    
    class func selectSort(nums:[Int]){
        var sorted = nums;
        
        for i in 0..<sorted.count {
            var minIndex = i;
            
            var isSorted = true;
            for j in (i+1)..<sorted.count {
                if sorted[j] < sorted[minIndex] {
                    minIndex = j;
                    isSorted = false;
                }
            }
            if isSorted { break;}
            
            sorted.swapAt(i, minIndex);
        }
    }
}
