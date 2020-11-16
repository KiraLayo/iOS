//: [Previous](@previous)

import Foundation

//反转一个单链表。
//
//示例:
//
//输入: 1->2->3->4->5->NULL
//输出: 5->4->3->2->1->NULL
//进阶:
//你可以迭代或递归地反转链表。你能否用两种方法解决这道题？
//
//来源：力扣（LeetCode）
//链接：https://leetcode-cn.com/problems/reverse-linked-list
//著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。

/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     public var val: Int
 *     public var next: ListNode?
 *     public init(_ val: Int) {
 *         self.val = val
 *         self.next = nil
 *     }
 * }
 */

 public class ListNode {
     public var val: Int
     public var next: ListNode?
     public init(_ val: Int) {
         self.val = val
         self.next = nil
     }
 }

class Solution {
    func reverseList(_ head: ListNode?) -> ListNode? {
        return recursive(head);
        return iteration(head);
    }
    
    func recursive(_ head: ListNode?) -> ListNode? {
        if (head == nil || head?.next == nil) {
            return head;
        }
        
        let node = recursive(head!.next);
        head?.next?.next = head;
        head?.next = nil;
        return node;
    }
    
    func iteration(_ head: ListNode?) -> ListNode? {
        if head == nil {
            return head;
        }
        
        var pre: ListNode? = nil;
        var cur: ListNode? = head;
        
        while cur != nil {
            let tmp = cur!.next!;
            cur?.next = pre;
            pre = cur;
            cur = tmp;
        }
        return pre;
    }
}
//: [Next](@next)
