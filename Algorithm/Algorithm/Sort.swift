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
    public class func bubbleSort(nums:inout [Int]) -> [Int]{
        for i in 0..<nums.count - 1  {
            for j in 0..<nums.count - i - 1{
                if nums[j] > nums[j+1] {
                    nums.swapAt(j, j+1);
                }
            }
        }
        return nums;
    }
    
    //优化冒泡1：若某位置之后未发生交换，则说明该位置后已是有序
    public class func bubbleSort1(nums:[Int]){
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
    
    //优化冒泡2：若某位置之后未发生交换，则说明该位置后已是有序
    public class func bubbleSort2(nums:[Int]){
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
    
    public class func selectSort(nums:inout [Int]){
        for i in 0..<nums.count - 1 {
            var minIndex = i;
            for j in i+1..<nums.count {
                if nums[j] < nums[minIndex] {
                    minIndex = j;
                }
            }
            nums.swapAt(minIndex, i);
        }
    }
    
    public class func insertSort(nums:inout [Int]) {
        for i in 1..<nums.count {
            for j in (1...i).reversed() {
                if nums[j] < nums[j-1] {
                    nums.swapAt(j, j-1)
                }else{
                    break;
                }
            }
        }
    }
    
    //优化，通过对比从后向前赋值，减少交换
    public class func insertSort1(nums:inout [Int]) {
        for i in 1..<nums.count {
            let current = nums[i];
            var j = i;
            while j > 0 {
                if current < nums[j-1] {
                    nums[j] = nums[j-1];
                    j -= 1;
                }
            }
            nums[j] = current;
        }
    }
    
    public class func quickSort(nums: inout [Int], left: Int,  right: Int){
        //递归出口
        if left >= right{
            return;
        }
        
        var l = left;
        var r = right;
        let p = nums[l];

        while l < r {
            while (left < right) && nums[right] >= p {
                r -= 1;
            }
            nums[l] = nums[r];
            while (l < r) && nums[l] <= p {
                l += 1;
            }
            nums[r] = nums[l];
        }
        nums[l] = p;
        
        quickSort(nums: &nums, left: left, right: l-1);
        quickSort(nums: &nums, left: l+1, right: right);
    }
    
    func mergeArray(_ nums1: inout [Int], _ m: Int, _ nums2: [Int], _ n: Int) {
        
        var p = m + n - 1;
        var p1 = m;
        var p2 = n;
        
        while p1 >= 0 && p2 >= 0 {
            if nums1[p1] > nums2[p2] {
                nums1[p] = nums1[p1];
                p1 -= 1;
            }else{
                nums1[p] = nums2[p2];
                p2 -= 1;
            }
            p -= 1;
        }
        
        while p2 >= 0 {
            nums1[p] = nums2[p2];
            p2 -= 1;
            p -= 1;
        }
    }
    
//    public class func mergeSort(nums:inout [Int]){
//        var size = 2;
//        while size <= nums.count + (nums.count%2 != 0 ? 1:0) {
//            let partCount = nums.count/size + (nums.count%size != 0 ? 1:0);
//            for i in 0..<partCount/2 {
//                _mergeSort(nums: &nums, f: i, s: i+size);
//            }
//            size = size * 2;
//        }
//    }
    
//    class func _mergeSort(nums: inout [Int], f:Int, s:Int){
//        var temp = nums.range;
//
//        for i in i..<(i+l) {
//
//        }
//    }
}
