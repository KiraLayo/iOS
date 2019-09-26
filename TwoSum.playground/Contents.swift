
//func twoSum1(nums: [Int], target: Int) -> [Int] {
//    for i in 0..<(nums.count-1) {
//        for j in (i+1)..<nums.count {
//            if (nums[i] + nums[j]) > target{
//                continue;
//            }
//
//            if (target - nums[j]) == nums[i] {
//                return [i, j];
//            }
//        }
//    }
//    return [];
//}

func twoSum2(nums: [Int], target: Int) -> [Int] {
    var numMap = [Int:Int]();
    
    for index1 in 0..<nums.count {
//        if nums[index1] > target {
//            continue;
//        }
        
        let key = nums[index1];
        
        if nil != numMap[target - key] {
            let index2 = numMap[target - key]!
            return [index2, index1];
        }
        
        if nil == numMap[key] {
            numMap[key] = index1;
        }
    }
    
    return [];
}

let sum2 = twoSum2(nums: [-3,4,3,90], target: 0);
print(sum2);
