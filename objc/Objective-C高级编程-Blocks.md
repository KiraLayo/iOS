# Blocks

**C语言函数使用的变量**
* 自动变量
* 函数的参数
* 静态变量
* 静态全局变量
* 全局变量

其中 **静态变量、静态全局变量、全局变量** 能够在函数多次调用见传递值。

**语法**
```
// Block
^returnType (arguments) {...}
// 返回类型为void 可省略
// 参数列表为空 可省略

// 声明Block类型变量
returnType (^name)(arguments);

```

**带有自动变量**的**匿名函数**，其中 **带有自动变量** 指截获保存自动变量的瞬间值，之后无法改写该值。

**重点：**
* 带有自动变量，或者说 **捕获自动变量**
* 匿名函数

如果将值赋值给捕获的自动变量，则会编译错误，但是调用自动变量的函数没有问题。

使用**C语言数组**时需要注意，截获自动变量的方法并没有实现对C语言数组的截获，如果使用字面量数组，会报错，使用指针可以，C语言规范不允许将C语言数组类型变量复制给C语言数组类型变量。

```
const char text[] = "hello"; // 报错
const char *text=  "hello"; // 正确
void (^block)(void) = ^ {
    printf(%c\n", text[2]);
}
```

## Block 实现

当使用 **Clang** 将 **Blocks** 转换为 **C语言** 函数时，函数名和相关结构体会使用 **Block** 语法所属的函数名和该 **Block** 语法在该函数出现的顺序来给经 **clang** 变换的函数或结构体命名，其中 **__cself** 等于 **this** 。

```
struct __xxx_block_impl_index {
    struct __block_impl impl;
    struct __main_block_desc_index * Desc;

    __xxx_block_impl_index (void *fp, struc __main_block_desc_index *desc, int flags=0) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
    }
}

struct __block_impl {
    void *isa;
    int Flags; //标志
    int Reserved; //版本升级所需区域
    void *FuncPtr; //函数指针，指向实际执行的静态函数
}

struct __xxx_block_desc_index {
    unsigned long reserved; //版本升级所需区域
    unsigned long Block_size; //Block大小
}
```

从 **Block** 的构造函数中可以看出 **Block** 就是Objective-C对象。

## 捕获自动变量

### 全局变量、静态全局变量

在 **Block** 中使用**全局变量**和**静态全局变量**，**Block** 并不会捕获这两种值，因为这两种值是直接使用的。

### 静态变量

在 **Block** 中使用 **静态变量** 会将静态变量那个的指针传递给 **Block** 结构体实例并保存。

### **__block**

类似于 **static、auto、register** 说明符，用于指定变量值设置到那个存储域中，**不是**所有权修饰符，可以和所有权修饰符共同存在。

当 **Block** 捕获到 **__block** 修饰的变量时，通过 **clang** 转化，可以发现，在原有 **Block** 代码上增加了如下内容：

```C
// name 是变量名称，index 是顺序
struct __Block_byref_name_index {
    void *__isa;
    __Block_byref_name_index *__forwarding; // 指向自身的指针
    int __flags;
    int __size; // 大小
    int name; // 这里的int是对应自动变量的类型
}

struct __main_block_impl_index {
    // impl及Desc
    // ...
    __block_byref_name_index *name; // __block
    // 其他捕获的自动变量
    // ...
    // 构造函数
    // 参数列表增加
    // __Block_byref_name_index *_name
    // 初始化列表增加
    // name(_name->__forwarding)
}

static void __main_block_func_index(struct __main_block_impl_index *__cself) {
    // 使用name时形式
    // __ceself->name->__forwarding->name
}

// 新增静态函数 copy/dispose
static void __main_block_copy_index(struct __main_block_impl_index *dst, struct __main_block_impl_index *src) {
    // 复制 __block 变量到堆
    // 具体根据捕获的自动变量的类型有变换
    __Block_object_assign(&dst->name, src->name, BLOCK_FIELD_IS_BYREF);
}

static void __main_block_dispose_index (struct __main_block_impl_index *src) {
    // 释放 __block 变量
    // 具体根据捕获的自动变量的类型有变换
    _BLock_object_dispose(src->name, BLOCK_FILED_IS_BYREF);
}

static sturec __main_block_desc_index {
    // reserved、Block_size
    // ...
    void (*copy)(struct __main_block_impl_index *, strcut __main_block_impl_index *);
    void (*dispose)(struct __main_block_impl_index *);

    // 构造函数中增加
    // copy和dispose的初始化
}
```

**__block** 指向的变量变成如下实例

```
__Block_byref_name_index name = {
    0,
    &name,
    0,
    sizeof(Block_byref_name_index),
    10 // 最后的成员比奥你那个相当于原自动变量
};
```
**__block** 指向的变量转化的结构并不在 **Block** 的结构体中，主要是为了在多个 **Block** 中使用。

### 对象

在捕获对象自动变量时，**Block** 用结构体中会附有带有与捕获的自动变量同样修饰符的id类型对象或类对象对象指针，同时结构体成员变量 **Desc** 增加成员变量 **copy** 和 **dispose** 函数指针。

其源代码转换后变化如下：

```C
struct __main_block_impl_index {
    // impl及Desc
    // ...
    id __strong *name; // 附有相同所有权修饰符的对象
    // 其他捕获的自动变量
    // ...
    // 构造函数
    // 参数列表增加 
    // id __strong * _name //注意所有权修饰符
    // 初始化列表增加
    // name(_name)
}

static void __main_block_func_index(struct __main_block_impl_index *__cself) {
    // 使用name时形式
    // __ceself->name
}

// 新增静态函数 copy/dispose
static void __main_block_copy_index(struct __main_block_impl_index *dst, struct __main_block_impl_index *src) {
    // 复制 __block 变量到堆
    // 具体根据捕获的自动变量的类型有变换
    __Block_object_assign(&dst->name, src->name, BLOCK_FIELD_IS_OBJECT);
}

static void __main_block_dispose_index (struct __main_block_impl_index *src) {
    // 释放 __block 变量
    // 具体根据捕获的自动变量的类型有变换
    _BLock_object_dispose(src->name, BLOCK_FIELD_IS_OBJECT);
}

static sturec __main_block_desc_index {
    // reserved、Block_size
    // ...
    void (*copy)(struct __main_block_impl_index *, strcut __main_block_impl_index *);
    void (*dispose)(struct __main_block_impl_index *);

    // 构造函数中增加
    // copy和dispose的初始化
}
```

转换后源代码在 **Block** 用结构体部分基本相同，用于**处理对象**的 **copy** 和 **dispose** 细节有区别。

* 对象：**BLOCK_FIELD_IS_OBJECT**
* **__block** 变量：BLOCK_FIELD_IS_BYREF

### **__block** 变量为附有修饰符的对象

struct __Block_byref_name_index {
    void *__isa;
    __Block_byref_name_index *__forwarding; // 指向自身的指针
    int __flags;
    int __size; // 大小
    int name; // 这里的int是对应自动变量的类型
}

```C
__block id name = [[NSObject alloc] init];
// 等同
__block id __strong name = [[NSObject alloc] init];
```

源代码转换会有以下变化

```C
struct __Block_byref_name_index {
    void *__isa;
    __Block_byref_name_index *__forwarding; // 指向自身的指针
    int __flags;
    int __size; // 大小
    void (*__Block_byref_id_object_copy)(void*, void*); //重点
    void (*__Block_byref_id_object_dispose)(void *); //重点
    id __strong name; // 这里的int是对应自动变量的类型
}

static void __Block_byref_id_object_copy_131(void *dst,void *src){
    // 131是标记，不清楚
    // 40 是结构体变量指针到成员name指针之间的距离，也就是__isa 到 name之间的距离
    // *(void(* *)((char *)src + 40)
    // void *src 转为 (char *)src
    // (char *)src + 40 是指针name的地址
    // name：指针的地址
    // *name：指针指向的地址
    // **name：指针指向的地址上的对象
    //（void * *）是取得 *name
    // *(void **) 是取得 **name
    _Block_object_assign((char*)dst + 40, *(void(* *)((char *)src + 40),131);
}

static void __Block_byref_id_object_dispose_131(void *src){
    // 131是标记，不清楚
    // 40 是结构体变量指针到成员name指针之间的
    距离，也就是__isa 到 name之间的距离
    // *(void(* *)((char *)src + 40)
    // void *src 转为 (char *)src
    // (char *)src + 40 是指针name的地址
    // name：指针的地址
    // *name：指针指向的地址
    // **name：指针指向的地址上的对象
    //（void * *）是取得 *name
    // *(void **) 是取得 **name
    _Block_object_dispose(*(void(* *)((char *)src + 40),131);
}

// 变量声明部分

__Block_byref_name_index name = {
    0,
    &name
    0x2000000,
    sizeof(__Block_byref_name_index),
    __Block_byref_id_object_copy_131,
    __Block_byref_id_object_dispose_131,
    [[NSObject alloc] init]
}
```

注意注释说明部分，上面代码部分主要是针对 **__strong** 修饰符的情况，其他修饰先考虑其内部处理，再考虑 **__block** 变量的处理。

**__weak** 先考虑其是否nil， 如果为nil，就不需要.

**__autoreleasing** 无法与 **__block** 共存

**__unsafe_unretained** 当成普通指针对待

## Block 存储域

**Block 与 __block 变量的本质**

**Block**：栈上**Block**的结构体实例

**__block变量**：栈上 **__block** 变量的机构体实例。

**Block** 中有 **isa** 指针，根据之前的分析可知 **Block** 也是 **Objective-C** 对象，具体对应的类为：

* _NSConcreteStackBlock
  * 该类的对象设置在栈上
* _NSConcreteGlobalBlock
  * 设置在程序的数据区域中
* _NSConcreteMallocBlock
  * 设置在由malloc函数分配的内存块（堆）中

之前例子中都是 **_NSConcreteStackBlock** 类型的 **Block**，如果在记述全局变量的地方使用 **Block语法** 时，生成的 **Block** 就是 **_NSConcreteGlobalBlock** 类的。

```C
// 位于全局变量区域，也就是数据区
void (^block)(void) = ^{};
int main() {
    
}
```

**_NSConcreteGlobalBlock** 因为在使用全局变量的地方不能使用自动变量，所以不存在对自动变量进行捕获，不依赖于执行时的状态，功能相同的 **Block** 在整个程序中只需要存在一个。

即使在 **函数内** 而不在全局变量的地方使用 **Block** 语法时，只要 Block **不捕获**自动变量，就可以将 **Block** 用结构体实例设置在程序的**数据区域**。也就是会变成 **_NSConcreteGlobalBlock**类对象

**重点：**

只在截获自动变量时，**Block** 用**结构体实例截获的值**才会根据执行时的状态变化，也就是根据保存那一刻的值来变化。

## **Block** 及 **__block** 超出变量作用域可存在

在栈上的 **Block** 及 **__block** 变量，当其作用域结束，变量就会被废弃，如果 **Block** 中有延时操作，将无法通过指针访问原来的自动变量。

**Blocks** 通过将 **Block** 和 **__block** 变量从栈复制到堆上的方法来解决这个问题。

复制到堆上的 **Block** 将 **__NSConcreteMallocBlock** 类对象写入 **Block** 用结构体实例的成员变量 **isa** 中。

**__block** 变量用结构体成员变量 **__forwarding** 可以实现无论 **__block** 变量配置在栈上还是堆上时都能够正确的访问 **__block** 变量。在 **__block** 变量配置在堆上的状态下，使栈上的 **__block** 变量结构体实例成员 **__forwarding** 指向对上的结构体实例。

### 复制机制

当 **ARC** 有效时，大多数情况下，编译器会恰当的判断，自动生成将 **Block** 从栈上复制到堆上的代码。

**可自动生成的情况：**

* 将 **Block** 复制给附有 __**strong** 修饰的id类型或 **Block** 类型**变量**时；
* 当 **Block** 作为函数返回时。
* **Cocoa** 框架的方法且方法名含有usingBlock等时。
* **Grand Central Dispatch** 的API。

**需要手动复制的情况：**

* 向方法或函数的参数中传递 **Block** 时

当需要 **手动复制** 时，则需要调用 **copy** 实例方法。

```C
// 当getBlockArray作用域结束后，调用getBlockArray()[0] 时会报错
- (id) getBlockArray {
    return [[NSArray alloc] initWithObjects:^(NSLog(@".."))];
}

- (id) getBlockCopyArray {
    // 手动复制
    return [[NSArray alloc] initWithObjects:^(NSLog(@"..")).copy];
}

```

**重点：**

**Block** 结构体实例复制到堆上，主要是依靠调用 **_Block_copy(block)** 方法，需要与 **Block** 用结构体中成员变量 **Desc** 中的copy区分。

不同 **Block** 的 **copy** 效果：

* **_NSConcreteStackBlock：** 从栈复制到堆
* **_NSConcreteGlobalBlock：** 什么也不做
* **_NSConcreteMallocBlock：** 引用计数短暂增加

多次调用 **copy**：

```C
blk = [[[blk copy] copy] copy];
转化为
{
    // blk_t 是堆上 Block 结构体
    // 栈上的Block被复制到堆上，并被tmp强引用，引用计数 + 1
    blk_t tmp = [blk copy];
    // blk强引用堆上的Block 引用计数 +1
    blk = tmp;
}
// tmp废弃，block引用计数-1

{
    // 同上
    blk_t tmp = [blk copy];
    blk = tmp;
}

// ...
```

## **__block** 变量存储域

不同存储域的 __**block**，**copy** 时的效果：

* 栈：从栈复制到堆上并被 **Block** 持有
* 堆：被 **Block** 持有

在一个 **Block** 中使用 __**block** 变量，当该 **Block** 从栈复制到堆时，使用的所有 __**block** 变量也必定配置在栈上，这些 __**block** 变量也全部被从栈复制到堆中，同时原先在栈中的 **__block** 变量用结构体实例的成员变量 **__forwarding** 会指向复制到**堆**上的**__block** 变量用结构体实例。

**注意** 

__**block** 变量结构体是与 **Block** 结构体独立的，多个 **Block** 结构体可以共同引用一个 __**block** 变量。

最先 **Block** 会配置在栈上，**Block** 所使用的 __**block** 变量也在栈上，当任何一个 **Block** 从栈复制到堆上时，使用的**__block** 变量也会一并从栈复制到堆上，并被复制的 **Block** 持有，对应引用计数 + 1。

**重点**

在堆中，**Block** 持有 __**block** 变量，对应引用计数的变化，与**Objective-C** 之引用计数内存管理完全相同，包括多个 **Block** 持有 __**block** 变量的情况。

当 **Block** 被释放，对应持有 __**block** 变量的引用计数也相应减少，直到为0释放。

## 解除循环引用

可以通过 __weak、__unsafe_retained、__block，解除循环引用。

**注意：** __block 在arc和非arc状态下，有区别，需要注意。__block可以通过执行 Block 控制持有时间（将其中一环置为**nil**）.