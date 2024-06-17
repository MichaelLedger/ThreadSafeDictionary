//
//  SpinLockRWThreadSafeDictionary.h
//  FastestThreadsafeDictionary-iOS
//
//  Created by gavin.xiang on 2024/6/17.
//  Copyright © 2017 gavin.xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

//https://en.wikipedia.org/wiki/Readers%E2%80%93writers_problem
//In First ReadersWriter solution, write can be starve, so it maybe suitable for lazy initialization with some write and almost read operation
//This Ditionary may has advantage in case there are lots of entries, and we perform lots of read operation (because read operation is seem lockless with this Dictionary)

@interface SpinLockRWThreadSafeDictionary : NSMutableDictionary

@end
