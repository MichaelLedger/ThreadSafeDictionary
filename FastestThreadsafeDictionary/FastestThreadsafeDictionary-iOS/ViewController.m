//
//  ViewController.m
//  FastestThreadsafeDictionary-iOS
//
//  Created by gavin.xiang on 2024/6/17.
//  Copyright © 2024 gavin.xiang. All rights reserved.
//

// PMutexRW(fastest but will crash, not thread-safe!!!)

#pragma mark - PMutex(recommend) > UnfairLock > SpinLock > Atomic > Barrier
// | PMutex | UnfairLock | SpinLock | Atomic | Barrier |
// | 0.198411 | 0.221064 | 0.449822 | 0.750522 | 1.352811 |
// | 0.197390 | 0.215329 | 0.316888 | 0.616962 | 1.200954 |
// | 0.195957 | 0.224263 | 0.275043 | 0.615157 | 1.213631 |

// below are console logs sample in Xcode 16.0 beta running on iPad Pro M4 Simulator(iOS 18.0):
/*
 🔍TEST THREADSAFE DIC WITH WITH MUTEX
 loopCount:398
 read(99)==write(1)==cost(0.072264)
 loopCount:398
 read(1)==write(99)==cost(0.032061)
 loopCount:400
 read(20)==write(80)==cost(0.039537)
 loopCount:399
 read(80)==write(20)==cost(0.059242)
 release dictionary
 💗Finish: 0.203294
 🔍TEST THREADSAFE DIC WITH UNFAIR LOCK
 loopCount:400
 read(99)==write(1)==cost(0.071942)
 loopCount:398
 read(1)==write(99)==cost(0.037985)
 loopCount:400
 read(20)==write(80)==cost(0.047258)
 loopCount:399
 read(80)==write(20)==cost(0.069207)
 release dictionary
 💗Finish: 0.226578
 🔍TEST THREADSAFE DIC WITH OSSPINLOCK
 loopCount:399
 read(99)==write(1)==cost(0.082074)
 loopCount:396
 read(1)==write(99)==cost(0.061610)
 loopCount:400
 read(20)==write(80)==cost(0.053287)
 loopCount:398
 read(80)==write(20)==cost(0.103477)
 release dictionary
 💗Finish: 0.300655
 🔍TEST THREADSAFE DIC WITH ATIMIC
 loopCount:399
 read(99)==write(1)==cost(0.260741)
 loopCount:398
 read(1)==write(99)==cost(0.203560)
 loopCount:398
 read(20)==write(80)==cost(0.227111)
 loopCount:397
 read(80)==write(20)==cost(0.264877)
 release dictionary
 💗Finish: 0.956473
 🔍TEST THREADSAFE DIC WITH GCD barrier
 loopCount:399
 read(99)==write(1)==cost(0.263219)
 loopCount:400
 read(1)==write(99)==cost(0.247871)
 loopCount:399
 read(20)==write(80)==cost(0.275099)
 loopCount:398
 read(80)==write(20)==cost(0.320329)
 release dictionary
 💗Finish: 1.106706
 🔍TEST THREADSAFE DIC WITH UNSAFE NSMutableDictionary. IT SHOULD CRASH, YOU KNOW......
 loopCount:399
 read(99)==write(1)==cost(0.014681)
 */

/*
 FastestThreadsafeDictionary-iOS(31216,0x16d723000) malloc: *** error for object 0x600000c6a940: pointer being freed was not allocated
 FastestThreadsafeDictionary-iOS(31216,0x16d723000) malloc: *** set a breakpoint in malloc_error_break to debug
 */

#import "ViewController.h"
void testUnsafeDic();
void testOSAtomicDic();
void testPMutexDic();
void testPMutexRWDic();
void testSpinLockDic();
void testBarrierDic();
void testSpinLockRWDic();
void testUnfairLockAtomicDic();

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    const int n = 1;
    double endTime;
    double startTime = CACurrentMediaTime();
    
    NSLog(@"🔍TEST THREADSAFE DIC WITH WITH MUTEX");
    for(int i=0;i<n;++i)
    {
        testPMutexDic();
    }
    endTime = CACurrentMediaTime();
    NSLog(@"💗Finish: %f", endTime - startTime);
    startTime = endTime;
    
    NSLog(@"🔍TEST THREADSAFE DIC WITH UNFAIR LOCK");
    for(int i=0;i<n;++i)
    {
        testUnfairLockAtomicDic();
    }
    endTime = CACurrentMediaTime();
    NSLog(@"💗Finish: %f", endTime - startTime);
    startTime = endTime;
    
    NSLog(@"🔍TEST THREADSAFE DIC WITH OSSPINLOCK");
    for(int i=0;i<n;++i)
    {
        testSpinLockDic();
    }
    endTime = CACurrentMediaTime();
    NSLog(@"💗Finish: %f", endTime - startTime);
    startTime = endTime;
    
    NSLog(@"🔍TEST THREADSAFE DIC WITH ATIMIC");
    for(int i=0;i<n;++i)
    {
        testOSAtomicDic();
    }
    endTime = CACurrentMediaTime();
    NSLog(@"💗Finish: %f", endTime - startTime);
    startTime = endTime;
    
    /*
    NSLog(@"🔍TEST THREADSAFE DIC WITH WITH MUTEX RW");
    for(int i=0;i<n;++i)
    {
        testPMutexRWDic();
    }
    endTime = CACurrentMediaTime();
    NSLog(@"💗Finish: %f", endTime - startTime);
    startTime = endTime;
     */
    
    /*
    NSLog(@"🔍TEST THREADSAFE DIC WITH OSSPINLOCK RW");
    for(int i=0; i<n; ++i)
    {
        testSpinLockRWDic();
    }
    endTime = CACurrentMediaTime();
    NSLog(@"💗Finish: %f", endTime - startTime);
    startTime = endTime;
     */
    
    NSLog(@"🔍TEST THREADSAFE DIC WITH GCD barrier");
    for(int i=0; i<n; ++i)
    {
        testBarrierDic();
    }
    endTime = CACurrentMediaTime();
    NSLog(@"💗Finish: %f", endTime - startTime);
    startTime = endTime;
    
    NSLog(@"🔍TEST THREADSAFE DIC WITH UNSAFE NSMutableDictionary. IT SHOULD CRASH, YOU KNOW......");
    
    testUnsafeDic();
    endTime = CACurrentMediaTime();
    NSLog(@"💗Finish: %f", endTime - startTime);
    startTime = endTime;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
