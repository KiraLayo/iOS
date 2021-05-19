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

```C
void dispatch_after(dispatch_time_t when, dispatch_queue_t queue, dispatch_block_t block);
```

在指定时间后，将处理 **追加** 到 **Dispatch Queue**，而不是指定时间后就执行。

**dispatch_time_t**

可以使用以下两种方式创建

**dispatch_time_t dispatch_time(dispatch_time_t when, int64_t delta);**
* 相对时间
* 内部使用 **mach_absolute_time** 作为时钟
* 以**滴答**为单位单调递增的时钟的当前值（从任意点开始），当系统处于睡眠状态时此时钟不会递增。改变当前系统时间无影响。
* 当 **when** 是 **DISPATCH_WALLTIME_NOW** 时，其内部会使用 **gettimeofday(_:_:)** 作为时钟

**dispatch_time_t dispatch_walltime(const struct timespec *when, int64_t delta);**
* 绝对时间
* 内部使用 **gettimeofday(_:_:)** 作为时钟
* 以系统时间为准，与app是否唤醒无关。

```C
enum {
	DISPATCH_WALLTIME_NOW DISPATCH_ENUM_API_AVAILABLE
			(macos(10.14), ios(12.0), tvos(12.0), watchos(5.0))	= ~1ull,
};

#define DISPATCH_TIME_NOW (0ull)
#define DISPATCH_TIME_FOREVER (~0ull)

```

```C
// delta 纳秒
#define NSEC_PER_SEC 1000000000ull /* nanoseconds per microsecond */
#define NSEC_PER_MSEC 1000000ull /* microseconds per second */
#define USEC_PER_SEC 1000000ull /* nanoseconds per second */
#define NSEC_PER_USEC 1000ull /* nanoseconds per millisecond */
```

### Dispatch Group

```C
// 创建Group
dispatch_group_t dispatch_group_create(void);

// 追加处理到指定的Group和Queue
void dispatch_group_async(dispatch_group_t group, dispatch_queue_t queue, dispatch_block_t block);

// 手动减少Group中的处理数
void dispatch_group_enter(dispatch_group_t group);
// 手动增加Group中的处理数
void dispatch_group_leave(dispatch_group_t group);

// 结束处理
void dispatch_group_notify(dispatch_group_t group, dispatch_queue_t queue, dispatch_block_t block);

// 结束处理, 当结果不为0时，表示还有未完成的任务。
intptr_t dispatch_group_wait(dispatch_group_t group, dispatch_time_t timeout);
```

追加多个处理到指定的 **Dispatch Group** 中，并在指定的 **Dispatch Queue** 中运行，并且最后可以通过 **dispatch_group_notify** 或者 **dispatch_group_wait** 做**结束处理**， 此时 **Dispatch Group** 中的处理都已经完成（需要注意 **dispatch_group_wait** 的考虑）。

**注意**：

* 在 **Group** 中的 **Block** 可以运行在不同的 **Queue** 中
* **Group** 持有外部所有 **Block**，GCD 持有 **Group**，直到所有的 **Block** 完成。
* **dispatch_group_notify** 后如果未释放（**非ARC**），可以继续使用 **dispatch_group_async** 追加处理
* 如果 **Group** 中没有处理，**dispatch_group_notify** 的结束处理将会立即执行
* **dispatch_group_leave/dispatch_group_enter** 可以手动增加 **Group** 的处理计数，区别于调用 **dispatch_group_async**，可以使用这两个方法配合 **Block** 手动处理类似 **dispatch_group_async** 的调用，也就是 **Block** 调用前调用 **dispatch_group_enter**， **Block** 结束调用 **dispatch_group_leave**

### dispatch_barrier_X

* 在 **barrier block** 之前的 **block** **执行完成之后**才会执行 **barrier block**，**barrier bloc** **执行完成后**，后续的 **block** 才会执行。
* **queue** 需要使用 **dispatch_queue_create** 创建的 **concurrent queue**，如果使用 **serial queue** 或者 **global concurrent queues**，执行方式就会同 **dispatch_sync、dispatch_async** 相同

#### dispatch_barrier_async

```C
void dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);
```

**queue**：会被系统持有，直到 **Block** 执行完毕
**block**：被系统copy及持有，直到执行完毕 

当 **Block** 被提交到队列后立即返回，不等待到其执行完毕。

#### dispatch_barrier_sync

```C
void dispatch_barrier_sync(dispatch_queue_t queue, dispatch_block_t block);
```

**queue**：因同步执行，所以不会有 **Block_copy** 操作

### dispatch_async

将指定的 **Block** **非同步** 的追加到指定的 **Dispatch Queue** 中，不会等待 **Block** 执行完毕，会直接返回。

### dispatch_sync

将指定的 **Block** **同步** 追加到指定的 **Dispatch Queue** 中，**Block** 执行完成之前，会一直 **等待**，一般情况下会在 **dispatch_sync** 当前线程中执行，除非是提交到 **main dispatch queue** 将会在 **main thread** 中运行

当在**串行队列**中使用时，会造成 **死锁**，因为只有一条线程， **dispatch_sync** 在等待 **Block** 的结束，**Block** 也在等待 **dispatch_sync** 的结束。

### dispatch_apply

```C
// 在指定的Queue上提交iterations次Block
// queue 可以使用 DISPATCH_APPLY_AUTO
void dispatch_apply(size_t iterations, dispatch_queue_t queue, void (^block)(size_t));
```

如果追加到并发队列，则 **Block** 是并发执行的，但是要注意必须是 **可重入**。

### dispatch_suspend/dispatch_resume

当有大量处理追加到 **Queue** 时，如果不想执行 **已追加但未执行** 的 **Block**，则可以是用 **dispatch_suspend** 进行挂起。后续需要执行时 **dispatch_resume** 恢复，对已经执行 **Block** 没有影响。

### Dispatch Semaphore

持有计数的 **信号**， 该计数是多线程编程中的计数类型信号。计数为 **0** 时 **等待**， 计数为 **1或大于1** 时，**减去1** 而不等待。

```C
dispatch_semaphore_t dispatch_semaphore_create(intptr_t value);

// 当dispatch_semaphore_t 计数为 0 时 等待到timeout，为1时继续执行
intptr_t dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout);

// 增加 dispatch_semaphore_t 计数，唤醒当前被wait的线程
intptr_t dispatch_semaphore_signal(dispatch_semaphore_t dsema);

```

### dispatch_once


```C
// 在程序生命周期中，仅执行一次
void dispatch_once(dispatch_once_t *predicate, dispatch_block_t block);

static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    
});

```

这个方法时线程安全的, predicate 可以是全局变量，也可以是静态变量。

### Dispatch I/O

