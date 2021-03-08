# GCD

异步执行任务的技术之一，一般将应用程序中记述的线程管理用的代码在系统级中实现，开发者只需要定义想执行的任务并追加到适当的 **Dispatch Queue** 中，**GCD** 就能 **生成必要的线程** 并计划执行任务，因为线程管理时作为系统的一部分来实现，因此可以统一管理，也可执行任务，这样就比以前的线程更有效率。

## 多线程

一台机器中的每个 **物理CPU** 都可以虚拟出多个**虚拟CPU**（一般可能是2个）。

一个CPU核 **执行的命令列** 为一条 **无分叉路径**，当这种无分叉路径不只一条时即为 **多线程**。

这里的 **路径**、**命令列**可以看作就是一条线程。

一个CPU核一次能够执行的CPU命令始终为1，通过 **上下文切换**，CPU就能在多条路径中执行CPU命令列。

**上下文切换：**

XUN内核在发生操作系统事件时（如每隔一定时间，换气系统调用等情况）会 **切换** 执行路径。执行中的路径**状态**，如CPU的寄存器等信息会保存到各自路径**专用的内存块**中，从要切换到的目标路径专用的内存快中，**复原**CPU寄存器等信息，继续执行切换路径的 **CPU命令列**。

可能发生的**问题**：

* **数据竞争**：多个线程更新相同资源，导致数据不一致。
* **死锁**：停止等待事件的线程会导致多个线程互相持续等待。
* 太多线程导致小号大量内存。

## 主线程

应用程序在启动时，通过最先执行的线程来描绘用户界面、处理触摸屏幕的事件等，这个线程就是 **主线程**。

如果在主线程中进行长时间的处理，就会妨碍主线程的执行（**阻塞**），从而导致不能更新用户界面、应用程序的画面长时间停滞等问题。

## Dispatch Queue

使用 **Block** 定义要执行的任务，通过 **dispatch_async** 函数 **追加** 到 **Dispatch Queue** 中，通过这样指定 **Block** 在另一个线程中执行，**Dispatch Queue** 执行处理的等待队列。

**Dispatch Queue** 分为两种：

* **Serial Dispatch Queue**：等待现在执行中处理结束
* **Concurrent Dispatch Queue**：不等待现在执行中处理结束，直接进行下一个任务

向 **Concurrent Dispatch Queue** 执行处理时，不会等待处理结束，会直接开始进行下一个处理，可以**并行处理**，并行执行的处理数量取决于当前系统的状态。

**并行执行** 就是使用多个线程同时执行多个处理（任务）。

**iOS** 和 **OSX**的核心 **XUN** 内核决定应当使用的线程数，并只生成所需的线程执行处理，**iOS** 和 **OSX** 基于 **Dispatch Queue 中处理数**、**CPU核数**、CPU负载等当前系统的状态来决定 **Concurrent Dispatch Queue** 中并行执行的处理数，当处理结束后，应当执行的处理数减少是，**XUN** 内核会结束不在需要的线程。

**Concurrent Dispatch Queue** 执行处理时，执行顺序会根据处理内容和系统状态发生改变，**Serial Dispatch Queue** 执行处理顺序固定 。

一个 **Serial Dispatch Queue** 生成并开始处理任务，系统对于一个 **Serial Dispatch Queue** 就只会生成一个线程，但是如果有多个有处理任务的**Serial Dispatch Queue**, 就会生成多个线程，各个 **Serial Dispatch Queue** 将并行处理。

### 生成 Dispatch Queue

**dispatch_queue_create** 函数：

第一个参数是**Dispatch Queue名称**，会在 **Xcode** 和 **Instruments** 的调试器中作为 **Dispatch Queue** 名称表示，也会出现在 **CrashLog** 中。

第二参数是指定创建什么类型的 **Dispatch Queue**, 第二个参数为 **NULL** 时为 **Serial Dispatch Queu**，为 **DISPATCH_QUEUE_CONCURRENT** 时为 **Concurrent Dispatch Queue**。

### 系统 Dispatch Queue

**Main Dispatch Queue** 

在 **主线程** 中执行的 **Dispatch Queue**，因为主线程只有1个，所以 **Main Dispatch Queue** 是 **Serial Dispatch Queue**

**Global Dispatch Queue**

**Concurrent Dispatch Queue**，拥有4个执行优先级：高优先级（High Priority）、默认优先级（Default Priority）、低优先级（Low Priority）、后台优先级（Background Priority）。

通过 **XUN** 内核管理的用于 **Global Dispatch Queue** 的线程，将各自使用的 **Global Dispatch Queue** 的执行 **优先级** 作为线程 **执行的优先级** 使用。

向 **Global Dispatch Queue** 中追加处理时，应当选择与处理内容对应的 **执行优先级** 的 **Global Dispatch Queue**。

通过 **XUN** 内核用于 **Global Dispatch Queue** 的线程并不能保证实时性，因此执行优先级只是 **大致的判断**。

对 **Global Dispatch Queue** 和 **Main Dispatch Queue** 执行 **dispatch_retain** 和 **dispatch_release** 无效。

通过 **dispatch_queue_create** 生成的 **Dispatch Queue** 都使用与**默认的优先级** **Global Dispatch Queue** 相同执行优先级的线程。

### Dispatch Queue 引用计数

**iOS6.0** 之前，GCD 还没有被 **ARC** 管理， 需要使用 **dispatch_release** 和 **dispatch_retain** 管理**引用计数**，**iOS6.0** 之后，交由 **ARC** 管理。

**dispatch_async** 函数中追加 **Block** 到 **Dispatch Queue** 后，即使立即释放 **Dispatch Queue**，也不会有问题，因为这个过程中， **Block** 会持有 **Dispatch Queue**，**Block** 执行结束后，就会释放 **Dispatch Queue**。

## GCD API

### dispatch_set_target_queue（dispatch_object_t object, dispatch_queue_t queue）

指定执行队列。

可以看做是 **重定向**，将一个或多个 **Dispatch Queue** 中的处理或 **dispatch_object_t** 对象 **重定向** 到 **目标队列** 中。

通过将多个 **Serial Dispatch Queue** 指定到一个 **Serial Dispatch Queue** 中时，可以防止这些 **Serial Dispatch Queue** 中的任务并行执行。

**注意:**

指定目标队列时注意不要形成环，否则发生错误。

如果队列有目标队列，则队列的 **执行优先级** 最终会是整个依赖链中最低的优先级的那个。

目标队列可以是 **Global Dispatch Queue**，但最好使用 **dispatch_queue_attr_make_with_qos_class** 替代。

如果队列有目标队列，系统不会为其生成线程，除非目标队列是 **Global Dispatch Queue**。

更改 **object** 的目标队列是一个异步操作，不会立即操作，也不会影响与 **object** 关联的 **Block**。

当 **object** 处于**非活跃状态**时，改变目标队列将立即生效，并且会影响与**object** 关联的 **Block**。

当 **object** 处于**活跃状态**时，则更改其目标队列将导致未定义的行为。

### dispatch_after

在指定时间后，将处理 **追加** 到 **Dispatch Queue**，而不是指定时间后就执行。