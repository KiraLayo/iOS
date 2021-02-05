# Tagged Pointer

从64bits开始， iOS引入了Tagged Pointer技术，为了提高性能并减少内存使用的。(本文讨论的基础是在64位系统下)

## 内存占用

* Tagged Pointer之前：内存占用 = 8字节（指针大小） + 对象本身大小
* Tagged Pointer之后：内存占用 = 8字节

>Tagged Pointer = Tag + Data（地址 + 数据）

## Tagged Pointer混淆

苹果对Tagged Pointer本身做了混淆，可以通过增加环境变量 **OBJC_DISABLE_TAG_OBFUSCATION** 来控制是否混淆

**混淆简述：**

1. 使用一些值来进行位移运算，左右横移。
2. 在_objc_init时生成一个随机码。
3. 使用随机数对结果进行异或运算。

## Tagged Pointer组成

### Tagged Pointer的判断

```c
// objc-internal.h
static inline bool 
_objc_isTaggedPointer(const void * _Nullable ptr)
{
    return ((uintptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK;
}
```

通过 **_OBJC_TAG_MASK** 进行判断，_OBJC_TAG_MASK的来源与系统有关，本质与最高/低有效位的判断相关。

```c
#if (TARGET_OS_OSX || TARGET_OS_IOSMAC) && __x86_64__
    // TARGET_OS_IOSMAC的值未知
    // 64-bit Mac - tag bit is LSB
#   define OBJC_MSB_TAGGED_POINTERS 0
#else
    // Everything else - tag bit is MSB
#   define OBJC_MSB_TAGGED_POINTERS 1
#endif
```

**MacOS** 使用 **LSB** 最低有效位。

**iOS** 使用 **MSB** 最高有效位。

```c
#if OBJC_MSB_TAGGED_POINTERS
#   define _OBJC_TAG_MASK (1UL<<63)
#   define _OBJC_TAG_INDEX_SHIFT 60
#   define _OBJC_TAG_SLOT_SHIFT 60
#   define _OBJC_TAG_PAYLOAD_LSHIFT 4
#   define _OBJC_TAG_PAYLOAD_RSHIFT 4
#   define _OBJC_TAG_EXT_MASK (0xfUL<<60)
#   define _OBJC_TAG_EXT_INDEX_SHIFT 52
#   define _OBJC_TAG_EXT_SLOT_SHIFT 52
#   define _OBJC_TAG_EXT_PAYLOAD_LSHIFT 12
#   define _OBJC_TAG_EXT_PAYLOAD_RSHIFT 12
#else
#   define _OBJC_TAG_MASK 1UL
#   define _OBJC_TAG_INDEX_SHIFT 1
#   define _OBJC_TAG_SLOT_SHIFT 0
#   define _OBJC_TAG_PAYLOAD_LSHIFT 0
#   define _OBJC_TAG_PAYLOAD_RSHIFT 4
#   define _OBJC_TAG_EXT_MASK 0xfUL
#   define _OBJC_TAG_EXT_INDEX_SHIFT 4
#   define _OBJC_TAG_EXT_SLOT_SHIFT 4
#   define _OBJC_TAG_EXT_PAYLOAD_LSHIFT 0
#   define _OBJC_TAG_EXT_PAYLOAD_RSHIFT 12
#endif
```