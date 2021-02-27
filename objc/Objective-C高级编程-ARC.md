# 自动引用计数

引用计数针对的是堆上的对象。

在栈中可以成为使用，在堆上时引用。

## MRC内存管理方式

### 自己生成的对象，自己持有

使用以下名称开头的方法名说明自己生成对象并持有。

* alloc
* new
* copy
* mutableCopy

### 非自己生成的，自己也可以持有

使用 **retain** 可以持有非自己生成的对象也就是[之前](#自己生成的对象自己持有)方式以外的对象。

### 持有的对象，不再需要持有时，释放
### 非自己持有的无法释放

## autorelease

自动释放，与 **C** 语言中的自动变量（局部变量）类似

**使用方法：**

1. 生成并持有 **NSAutoreleasePool** 对象；
2. 调用对象的 **autorelease** 方法；
3. 废弃 **NSAutoreleasePool** 对象；

对于调用过 **autorelease** 方法的对象，**NSAutoreleasePool** 在废弃时，都会调用 **relase** 方法。

在程序祝循环的 **NSRunloop** 或者其他程序运行的地方，已经有对 **NSAutoreleasePool** 进行生成、持有和废弃的处理。

**NSAutoreleasePool** 对象无法调用 **autorelase** 方法，会异常。

## ARC

在 **编译单位（比如文件）** 上可以设置是否使用 **ARC**。

**id** 类型相当于 **C** 语言中的 **void\***。

**ARC** 有效时 **id** 类型和对象类型必须附加所有权修饰符。

### 所有权修饰符   

复制给对象指针时，所有权修饰符必须保持一致

**__strong（强引用）**

* **id** 类型和对象类型的默认所有权修饰符
* 会持有非自己生成的对象
* 超过对象作用域时，会调用 **release** 方法
* 当调用非 **alloc/new/copy/mutableCopy/init** 情况时，返回对象方法中会使用 **objc_autoreleaseReturnValue** 返回 **autoreleasepool** 中的对象，当赋值给 __**strong** 变量时，编译器会使用 **objc_retainAutoreleasedReturnValue**获得对象。
* 当编译器检测到 **objc_autoreleaseReturnValue** 的接收者时 **objc_retainAutoreleasedReturnValue****，objc_autoreleaseReturnValue** 则不会将对像返回给 **autoreleasepool** 而是之间返回给调用者。

**__weak（弱引用）**

* 引用对象释放后，自己会失效并置为 **nil**。
* 在**使用** (重点是**使用**) **__weak** 修饰的对象过程中，该对象有可能被废弃，所以使用 **__weak** 修饰的对象并要注册到 **autoreleasepool** 中。
* 用以解决 **循环引用** 问题。
  * 互相引用
  * 对自身引用
  * 环状引用
* 部分类不支持__weak，比如 **NSMachPort**，一般这种类中会有相应的标示

**__unsafe_unretained（不安全所有权）**

* 不属于编译器的内存管理对象。
* 在iOS4之前替代 **__weak**。
* 使用对应对象时需要确保对象存在。

**__autoreleasing（自动释放）**

**ARC** 有效时，使用 **__autoreleasing** 替代 **autorelease**，同时使用 **@autoreleasepool**代替。

一般情况下**不会显式调用**，非显式的调用例子
* 编译器会检查方法名是否满足**自己生成并持有**，如果不满足，则会将方法的返回值注册到 **autoreleasepool** 中。在方法内部并不会显示的使用 **__autoreleasing**
* **id** 的指针或者对象的指针在**没有显式指定**时，会被附加上 **__autoreleasing**，比如 **NSObject \*\*** 会成为**NSObject \* __autoreleasing \***
```
NSError *error;
NSError **pError = &error;
```
以上代码会报错，因为 **error** 有修饰符为 **_strong**，**\*pError**的修饰符号为**__autoreleasing**, 需要显式指定为**__strong**。其他修饰符情况也同理

```
NSError *error;

// 不过这里就是__autoreleasing没有关系了，对象不会添加到autoreleasepool中
NSError * __strong *pError = &error;
```
**注意特殊情况**

当 **id** 的指针或类型的指针，位于函数形参时，不设置修饰符的情况下，会做以下处理：

```
// 此处不会报错
NSError *error;
BOOL res = [obj methodWithError:&error];

// 编译器转化为

NSError __strong *error;
NSError __autoreleasing *tmp = error;
// 此处不会报错
BOOL res = [obj methodWithError:&tmp];
```

__**autoreleasing**和**autorelease** 注册对象到 **autoreleasepool** 会增加引用计数，在离开 **autoreleasepool** 作用域时，减少对应的对象的引用计数。

**__weak/__strong/__autorelease** 会保证其修饰的变量初始化为 **nil**

### ARC规则

* 不能使用 **retain/release/retainCount/autorelease**
* 不能使用 **NSAllocateObject/NSDeallocateObject**
* 遵守MRC内存管方法命名规则，并在此基础上添加以 **init** 开头的方法
  * **init** 必须是实例方法，并且返回 **id** 类型或该方法声明类的对象类型，或是子类、超类，返回的对象不会被注册到 **autoreleasepool** 中，基本是对 **alloc** 方法中返回的对象的初始化。
* 不显式调用 **dealloc**
* 使用 **@autoreloeasepool块** 替代 **NSAutoreleasePool** 
* 不使用 **NSZone**
  * **NSZone** 目前的运行时系臃肿已被忽略。
* 对象类型不能作为C语言的结构体成员
  * 该条有问题，待探究
* 需要显式转换 **id** 和 **void\***
  * 需要使用 **__bridge** 和 **CFBridge** 转换。
  * __**bridge** 转换，不涉及持有状态的变化
  * __**birdge_retained/CFBridgeRetain** 会使变量持有赋值对象，引用计数之后由 **CF** 管理
  * __**birdge_transfer/CFBridgeRelease** 会使变量持有赋值对象，引用计数之后由 **ARC** 管理

### 属性

**属性与所有权修饰符的关系**

* **assign** == __**unsafe_unretained**
* **copy** == __**strong**(赋值的是被复制对象)
* **retain/strong** == __**strong**
* **unsafe_unretained** == __**unsafe_unreatined**
* **weak** == __**weak**

成员所有权声明与属性声明必须保持一致。

**注意**

* **id\*** 类型默认是 **id __autoreleasing \*** 类型如果不需要使用自动释放特性，需要显式的指定修饰符比如 __**strong**。
* __**strong** 虽然可以使 **id** 类型变量初始化为 **nil**，但是不能使 **id \*** 类型的变量被初始化为 **nil**

**拓展**
C语言风格动态数组可以使用 **calloc** 来构建。
```
NSObject * __strong *array = nil;
// calloc 会将分配的区域初始化为0，因为使用__strong 修饰的变量前，必须将其初始化nil， 使用 malloc 之后使用 memset 也可以
array = (id __strong *)calloc(number, sizeof(id));
```

**释放**的时候需要注意，先把所有的成员先全部释放（**nil**），之后再释放数组本身。

```c
// 这里省略
for i ...
array[i] = nil

free(array)；
```

其他会使变量初始化为nil的修饰符同理。

有时候引用计数可能会出错，可能因为**竞态条件文档**、已释放对象、对象地址不正确等原因，所以不一定完全可行，但大多数情况下没有问题。