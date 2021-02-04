# Tagged Pointer

从64bits开始， iOS引入了Tagged Pointer技术，为了提高性能并减少内存使用的。(本文讨论的基础是在64位系统下)

## 内存占用

* Tagged Pointer之前：内存占用 = 8字节（指针大小） + 对象本身大小
* Tagged Pointer之后：内存占用 = 8字节

>Tagged Pointer = Tag + Data（地址 + 数据）

## Tagged Pointer具体组成



## Tagged Pointer混淆（iOS 12）

在iOS12以后，苹果对Tagged Pointer本身做了混淆，后续的组成都是以未混淆前为基准。

### 混淆简述

1. 使用一些值来进行位移运算，左右横移。
2. 在_objc_init时生成一个随机码。
3. 使用随机数对结果进行异或运算。
