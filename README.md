# ThreadSafeDictionary

NSMutableDictionary of iOS is not threadsafe. You may encountered problem when read/write shared NSMutableDictinary from multiple thread. I want to make fast and threadsafe mutable dictionary. The idea is use OSAtomic and lockless read operation:
  + Use separated lock for read and write. So, read operation is seemly lockless in case that we rarely write to the dictionary (such as lazy initialization, only 1 thread initialize data once and other threads read the data).
  + Only lock when read/write, write/write concurrently.

`PMutex(recommend) > UnfairLock > SpinLock > Atomic > Barrier`

| PMutex | UnfairLock | SpinLock | Atomic | Barrier |
|-|-|-|-|-|
| 0.203294 | 0.226578 | 0.300655 | 0.956473 | 1.106706 |
| 0.197390 | 0.215329 | 0.316888 | 0.616962 | 1.200954 |
| 0.195957 | 0.224263 | 0.275043 | 0.615157 | 1.213631 |

 But i can't find OSAtomic operation on iOS that can do something like that: Compare a to value x then set b to value y. So there is no absolute safe solution for lockless read -> Currently i use lock for all read/write operation. But certainly it's still very fast.

Comparision:
In the sample project: multiple thread read/write to a shared dictionary:
+ PMutexThreadsafeDictionary: 15.x seconds
+ FastestThreadsafeDictionary: 8.x seconds. So it's 2x faster than using pthread mutex

Note that both of them have their pros and cons:
+ Use atomic operation when you plan to hold the lock for extremely short interval, contention is rare (For example: lazy initialization)
+ Pthread: The advantage is waiting-thread does not take any CPU time. This requires intervention by the OS to stop the thread, and start it again when unlocking. But this OS intervention comes with a certain amount of overhead. 

## Tips:

The rise of parallelism in hardware has led to significant changes in software development. This has brought about the introduction of APIs for thread management and synchronization primitives in SDKs. Crafting a multi-threaded program that runs without glitches is a challenging endeavor. Among the most daunting challenges is ensuring different threads access memory without conflict.
In true parallel systems (like multi-core or multiprocessor setups), two threads might simultaneously read from and write to the same memory location, leading to a “data race.” Delving into the finer details (such as data size, alignment, processor caches, and atomics) might get complex, but using mutexes is the conventional method to prevent data races. When a mutex instance is in place, and its lock/unlock methods are appropriately called, it ensures the atomicity of data operations and exclusive access.
On Apple’s platforms, the os_unfair_lock is the most performance-efficient lock available.

All the old C locks are there, but they’re trying to steer everyone towards os_unfair_lock, nowadays. See the Concurrent Programming with GCD where they discuss C lock mechanisms (and how you’d use them in Swift if you wanted to), and this discussion touches upon their thought process regarding locks nowadays.

But you can use pthread_mutex_t like before. Or if you’re dealing with an atomic, you can use OSAtomicXXX. The old spinlock has been deprecated, with this os_unfair_lock recommended in lieu of that. All of these options are buried in the man pages.

Needless to say, from Objective-C, you still have NSLock, NSRecursiveLock and the @synchronized directive, too.

The old Threading Programming Guide: Using Locks enumerates a few of the locking alternatives.

## Reference:

[Is there any native C-level lock other than os_unfair_lock in Objective-C/Swift?](https://stackoverflow.com/questions/60045664/is-there-any-native-c-level-lock-other-than-os-unfair-lock-in-objective-c-swift)

[Swift: Mutex benchmark](https://serhiybutz.medium.com/swift-mutex-benchmark-b21ee293d9ad)

[pthread_mutex_t](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/pthread_mutex_lock.3.html)

[OSAtomicXXX](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/OSAtomicAdd32.3.html)

[NSLock](https://developer.apple.com/documentation/foundation/nslock?language=objc)

[NSRecursiveLock](https://developer.apple.com/documentation/foundation/nsrecursivelock?language=objc)

[Concurrent Programming with GCD](https://developer.apple.com/videos/play/wwdc2016/720/?time=997)

[Threading Programming Guide: Using Locks](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/ThreadSafety/ThreadSafety.html#//apple_ref/doc/uid/10000057i-CH8-SW16)

[ManPages_iPhoneOS](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/index.html)

[Mastering Thread Safety in Swift With One Runtime Trick](https://betterprogramming.pub/mastering-thread-safety-in-swift-with-one-runtime-trick-260c358a7515)

[A Tour of OSAtomic](https://www.mikeash.com/pyblog/friday-qa-2011-03-04-a-tour-of-osatomic.html)

[pthread mutex vs pthread spinlock](http://www.alexonlinux.com/pthread-mutex-vs-pthread-spinlock)

[Atomic: SPINLOCK is not safe in iOS](https://github.com/ReactiveCocoa/ReactiveCocoa/issues/2619)

[Swift access race with os_unfair_lock_lock](https://stackoverflow.com/questions/68614552/swift-access-race-with-os-unfair-lock-lock)

[iOS OSSpinLock](https://juejin.cn/post/6903421287713439752)

[Spin Lock Implementations (OSSpinLock)](https://stackoverflow.com/questions/12949028/spin-lock-implementations-osspinlock)
