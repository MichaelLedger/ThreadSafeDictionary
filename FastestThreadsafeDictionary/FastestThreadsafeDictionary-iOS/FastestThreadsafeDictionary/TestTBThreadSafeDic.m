//
//  TestTBThreadSafeDic.m
//  TestLockless-iOS
//
//  Created by gavin.xiang on 2024/6/17.
//  Copyright © 2024 gavin.xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AtomicThreadSafeDictionary.h"
#import "PMutexThreadSafeDictionary.h"
#import "PMutexRWThreadSafeDictionary.h"
#import "SpinLockThreadSafeDictionary.h"
#import "BarrierThreadSafeDictionary.h"
#import "SpinLockRWThreadSafeDictionary.h"

typedef NS_ENUM(NSUInteger, ReadWriteType) {
    ReadWriteTypeWriteOnce,// write only once & left times all read
    ReadWriteTypeReadOnce,// read only once & left times all write
    ReadWriteTypeWriteMore,// write more times than read
    ReadWriteTypeReadMore// read more times than write
};

void readWriteOnMultiThread(NSMutableDictionary* dic)
{
    //dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t concurrentQueue = dispatch_queue_create("ccQueue", DISPATCH_QUEUE_CONCURRENT);
    
    NSString* key = @"key";
    NSString* key1 = @"key1";
    NSString* key2 = @"key2";
    NSString* newVal = @"newVal";
    NSString* newVal1 = @"newVal1";
    NSString* newVal2 = @"newVal2";
    
    double(^workToDo)(int, int, int) = ^(int readTimesPerExecute, int writeTimesPerExecute, int iterations){
        double endTime;
        double startTime = CACurrentMediaTime();
        //iterations
        //The number of times to execute the block.
        __block int loopCount = 0;
        dispatch_apply(iterations, concurrentQueue, ^(size_t idx) {
            loopCount++;
            for(size_t count = 0; count < readTimesPerExecute; ++count)
            {
                //NSString* key = [NSString stringWithFormat:@"key%zu%zu",idx,count];
                //NSString* newVal = [NSString stringWithFormat:@"Val%zu%zu",idx,count];
                
                //Test read use both [] and objectForKey
                id val = dic[key];
                val = [dic objectForKey:key];
                id val1 = dic[key1];
                val1 = [dic objectForKey:key1];
                id val2 = dic[key2];
                val2 = [dic objectForKey:key2];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused"
                NSUInteger n = dic.count;
                id arr = dic.allKeys;
                arr = dic.allValues;
                id enumerator = dic.keyEnumerator;
#pragma clang diagnostic pop
            }
            for(size_t count = 0; count < writeTimesPerExecute; ++count)
            {
                //NSString* key = [NSString stringWithFormat:@"key%zu%zu",idx,count];
                //NSString* newVal = [NSString stringWithFormat:@"Val%zu%zu",idx,count];
                [dic removeAllObjects];
                [dic removeObjectForKey:key];
                [dic removeObjectsForKeys:@[key1, key2]];
                
                //Test write use [] and setObject
                dic[key] = newVal;
                [dic setObject:newVal1 forKey:key1];
                
                //addEntriesFromDictionary
                [dic addEntriesFromDictionary:@{key2:newVal2}];
            }
        });
        NSLog(@"loopCount:%d", loopCount);
        endTime = CACurrentMediaTime();
        return endTime - startTime;
    };
    
    int totalTimes = 100;
    for (NSUInteger type = ReadWriteTypeWriteOnce; type <= ReadWriteTypeReadMore; type ++) {
        int readTimesPerExecute;
        int writeTimesPerExecute;
        switch (type) {
                /*
            case ReadWriteTypeRandom:
            {
                readTimesPerExecute = arc4random() % totalTimes;
                writeTimesPerExecute = totalTimes - readTimesPerExecute;
            }
                break;
                 */
            case ReadWriteTypeReadOnce:
            {
                readTimesPerExecute = 1;
                writeTimesPerExecute = totalTimes - readTimesPerExecute;
            }
                break;
            case ReadWriteTypeWriteOnce:
            {
                writeTimesPerExecute = 1;
                readTimesPerExecute = totalTimes - writeTimesPerExecute;
            }
                break;
            case ReadWriteTypeReadMore:
            {
                readTimesPerExecute = totalTimes * 0.8;
                writeTimesPerExecute = totalTimes - readTimesPerExecute;
            }
                break;
            case ReadWriteTypeWriteMore:
            {
                writeTimesPerExecute = totalTimes * 0.8;
                readTimesPerExecute = totalTimes - writeTimesPerExecute;
            }
                break;
            default:
            {
                readTimesPerExecute = totalTimes * 0.5;
                writeTimesPerExecute = totalTimes - readTimesPerExecute;
            }
                break;
        }
        double cost = workToDo(readTimesPerExecute, writeTimesPerExecute, 100);
        NSLog(@"read(%d)==write(%d)==cost(%f)", readTimesPerExecute, writeTimesPerExecute, cost);
    }
}

//Test multi thread read and write to the dictionary
void testUnsafeDic()
{
    NSMutableDictionary* dic = [NSMutableDictionary new];
    readWriteOnMultiThread(dic);
}

void testPMutexDic()
{
    PMutexThreadSafeDictionary* dic = [PMutexThreadSafeDictionary new];
    readWriteOnMultiThread(dic);
}

void testPMutexRWDic()
{
    PMutexRWThreadSafeDictionary* dic = [PMutexRWThreadSafeDictionary new];
    readWriteOnMultiThread(dic);
}

void testSpinLockDic()
{
    SpinLockThreadSafeDictionary* dic = [SpinLockThreadSafeDictionary new];
    readWriteOnMultiThread(dic);
}

void testBarrierDic()
{
    BarrierThreadSafeDictionary* dic = [[BarrierThreadSafeDictionary alloc] initWithDictionary:@{}];
    readWriteOnMultiThread(dic);
}

void testSpinLockRWDic()
{
    SpinLockRWThreadSafeDictionary* dic = [SpinLockRWThreadSafeDictionary new];
    readWriteOnMultiThread(dic);
}

void testFastestOSAtomicDic()
{
    AtomicThreadSafeDictionary* dic = [AtomicThreadSafeDictionary new];
    readWriteOnMultiThread(dic);
}
