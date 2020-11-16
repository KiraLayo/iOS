//: [Previous](@previous)

import Foundation

//下一个排列
/*
 实现获取下一个排列的函数，算法需要将给定数字序列重新排列成字典序中下一个更大的排列。

 如果不存在下一个更大的排列，则将数字重新排列成最小的排列（即升序排列）。

 必须原地修改，只允许使用额外常数空间。

 以下是一些例子，输入位于左侧列，其相应输出位于右侧列。
 1,2,3 → 1,3,2
 3,2,1 → 1,2,3
 1,1,5 → 1,5,1
 1325
*/

func nextPermutation(_ nums: inout [Int]) {
    var i = nums.count - 1;
    var isDesc = true;
    for index in (0..<nums.count).reversed() {
        if (index > 0 && nums[index] > nums[index - 1]) {
            i = index;
            isDesc = false
            break;
        }
        
        if (index == 0 && isDesc) {
            nums = nums.reversed();
        }
    }
    
    if (!isDesc) {
        for index in (i..<nums.count).reversed() {
            if (nums[index] > nums[i - 1]) {
                let tmp = nums[index];
                nums[index] =  nums[i - 1];
                nums[i - 1] = tmp;
                break;
            }
        }
        var m = i;
        var n = nums.count - 1;
        for _ in 0..<((nums.count - i)/2) {
            let tmp = nums[m];
            nums[m] = nums[n];
            nums[n] = tmp;
            n -= 1;
            m += 1;
        }
    }
}

var array = [5,4,7,5,3,2];
nextPermutation(&array);
print(array);
//: [Next](@next
