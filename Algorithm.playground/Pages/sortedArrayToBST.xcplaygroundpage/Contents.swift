//: [Previous](@previous)

import Foundation

//将一个按照升序排列的有序数组，转换为一棵高度平衡二叉搜索树。
//
//本题中，一个高度平衡二叉树是指一个二叉树每个节点 的左右两个子树的高度差的绝对值不超过 1。
//
//示例:
//
//给定有序数组: [-10,-3,0,5,9],
//
//一个可能的答案是：[0,-3,9,-10,null,5]，它可以表示下面这个高度平衡二叉搜索树：
//
//      0
//     / \
//   -3   9
//   /   /
// -10  5
//
//来源：力扣（LeetCode）
//链接：https://leetcode-cn.com/problems/convert-sorted-array-to-binary-search-tree
//著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。

public class TreeNode {
     public var val: Int
     public var left: TreeNode?
     public var right: TreeNode?
     public init(_ val: Int) {
         self.val = val
         self.left = nil
         self.right = nil
     }
}

func sortedArrayToBST(_ nums: [Int]) -> TreeNode? {
   if (nums.count == 0) {
        return nil;
    }
    
    let headIndex = nums.count / 2;

    let head = TreeNode(nums[headIndex]);
    if (headIndex - 1 >= 0) {
        head.left = sortedArrayToBST(Array(nums[..<headIndex]));
    }
    if (headIndex + 1 < nums.count) {
        head.right = sortedArrayToBST(Array(nums[(headIndex+1)...]));
    }
    
    return head;
}

sortedArrayToBST([-10,-3,0,5,9]);
//sortedArrayToBST([-10,-3]);

//: [Next](@next)
