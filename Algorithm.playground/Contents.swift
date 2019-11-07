import Foundation

public class TreeNode : Hashable{
     public var val: Int
     public var left: TreeNode?
     public var right: TreeNode?
     public init(_ val: Int) {
             self.val = val
                 self.left = nil
                 self.right = nil
    }
}

func maxDepth1(_ root: TreeNode?) -> Int {
    if root == nil {
        return 0;
    }
    
    let left = maxDepth1(root!.left);
    let right = maxDepth1(root!.right);
    
    return 1 + max(left, right);
};

func maxDepth11(_ root: TreeNode?) -> Int {
    if root == nil {
        return 0;
    }
    
    var stack = [TreeNode]();
    
    
    let left = maxDepth1(root!.left);
    let right = maxDepth1(root!.right);
    
    return 1 + max(left, right);
};

func maxDepth2(_ root: TreeNode?) -> Int {
    if root == nil {
        return 0;
    }
    var queue = [TreeNode]();
    queue.append(root!);
    var depth = 0;
    while !queue.isEmpty {
        depth += 1;
        
        var currentQueue = [TreeNode]();
        
        while let node = queue.popLast() {
            if node.left != nil {
                currentQueue.append(node.left!);
            }
            if node.right != nil {
                currentQueue.append(node.right!);
            }
        }
        
        queue.append(contentsOf: currentQueue);
    }
    return depth;
};

func maxDepth22(_ root: TreeNode?) -> Int {
    if root == nil {
        return 0;
    }
    var queue = [TreeNode]();
    queue.append(root!);
    var value = [Int]();
    value.append(1);
    
    var depth = 0;
    
    while !queue.isEmpty {
        let node = queue.popLast()!;
        let current = value.popLast()!;
        depth = max(current, depth);
        
        if node.right != nil {
            queue.append(node.right!);
            value.append(current + 1);
        }
        
        if node.left != nil {
            queue.append(node.left!);
            value.append(current + 1);
        }
    }
    return depth;
};


