//
//  ViewController.m
//  FastestThreadsafeDictionary-iOS
//
//  Created by trongbangvp@gmail.com on 9/1/16.
//  Copyright © 2016 trongbangvp@gmail.com. All rights reserved.
//

// PMutexRW(fastest but will crash, not thread-safe!!!)

#pragma mark - PMutex > SpinLock <=> SpinLockRW > Atomic > Barrier
// 0.090898 < 0.195337 > 0.150919 < 0.334046 < 0.594016
// 0.080489 < 0.126249 < 0.137656 < 0.329052 < 0.553771
// 0.084977 < 0.151189 < 0.161779 < 0.430119 < 0.552239
// 0.079566 < 0.214234 > 0.156449 < 0.328487 < 0.560890

// below are console logs sample in Xcode 16.0 beta running on iPad Pro M4 Simulator(iOS 18.0):
/*
 🔍TEST THREADSAFE DIC WITH OSATIMIC CompareAndSwap
 loopCount:100
 read(99)==write(1)==cost(0.106730)
 loopCount:100
 read(1)==write(99)==cost(0.063089)
 loopCount:100
 read(20)==write(80)==cost(0.066793)
 loopCount:100
 read(80)==write(20)==cost(0.091766)
 💗Finish: 0.328487
 🔍TEST THREADSAFE DIC WITH WITH MUTEX
 loopCount:100
 read(99)==write(1)==cost(0.026476)
 loopCount:96
 read(1)==write(99)==cost(0.013757)
 loopCount:97
 read(20)==write(80)==cost(0.016356)
 loopCount:98
 read(80)==write(20)==cost(0.022816)
 💗Finish: 0.079566
 🔍TEST THREADSAFE DIC WITH OSSPINLOCK
 loopCount:100
 read(99)==write(1)==cost(0.062686)
 loopCount:100
 read(1)==write(99)==cost(0.032578)
 loopCount:100
 read(20)==write(80)==cost(0.032623)
 loopCount:100
 read(80)==write(20)==cost(0.086171)
 💗Finish: 0.214234
 🔍TEST THREADSAFE DIC WITH OSSPINLOCK RW
 loopCount:100
 read(99)==write(1)==cost(0.037656)
 loopCount:99
 read(1)==write(99)==cost(0.028570)
 loopCount:98
 read(20)==write(80)==cost(0.035164)
 loopCount:98
 read(80)==write(20)==cost(0.054845)
 💗Finish: 0.156449
 🔍TEST THREADSAFE DIC WITH GCD barrier DIC
 loopCount:100
 read(99)==write(1)==cost(0.158919)
 loopCount:100
 read(1)==write(99)==cost(0.110732)
 loopCount:99
 read(20)==write(80)==cost(0.142893)
 loopCount:100
 read(80)==write(20)==cost(0.148110)
 💗Finish: 0.560890
 🔍TEST THREADSAFE DIC WITH UNSAFE NSMutableDictionary. IT SHOULD CRASH, YOU KNOW......
 loopCount:100
 read(99)==write(1)==cost(0.002421)
 */

/*
 FastestThreadsafeDictionary-iOS(31216,0x16d723000) malloc: *** error for object 0x600000c6a940: pointer being freed was not allocated
 FastestThreadsafeDictionary-iOS(31216,0x16d723000) malloc: *** set a breakpoint in malloc_error_break to debug
 */

#import "ViewController.h"
void testUnsafeDic();
void testFastestOSAtomicDic();
void testPMutexDic();
void testPMutexRWDic();
void testSpinLockDic();
void testBarrierDic();
void testSpinLockRWDic();

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    const int n = 1;
    
    NSLog(@"🔍TEST THREADSAFE DIC WITH OSATIMIC CompareAndSwap");
    double endTime;
    double startTime = CACurrentMediaTime();
    
    for(int i=0;i<n;++i)
    {
        testFastestOSAtomicDic();
    }
    
    endTime = CACurrentMediaTime();
    NSLog(@"💗Finish: %f", endTime - startTime);
    startTime = endTime;
    
    NSLog(@"🔍TEST THREADSAFE DIC WITH WITH MUTEX");
    for(int i=0;i<n;++i)
    {
        testPMutexDic();
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
    
    NSLog(@"🔍TEST THREADSAFE DIC WITH OSSPINLOCK");
    for(int i=0;i<n;++i)
    {
        testSpinLockDic();
    }
    endTime = CACurrentMediaTime();
    NSLog(@"💗Finish: %f", endTime - startTime);
    startTime = endTime;
    
    NSLog(@"🔍TEST THREADSAFE DIC WITH OSSPINLOCK RW");
    for(int i=0; i<n; ++i)
    {
        testSpinLockRWDic();
    }
    endTime = CACurrentMediaTime();
    NSLog(@"💗Finish: %f", endTime - startTime);
    startTime = endTime;
    
    NSLog(@"🔍TEST THREADSAFE DIC WITH GCD barrier DIC");
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
