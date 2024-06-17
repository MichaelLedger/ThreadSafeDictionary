//
//  TBThreadSafeMutableDictionary.h
//  TestLockless-iOS
//
//  Created by gavin.xiang on 2024/6/17.
//  Copyright © 2024 gavin.xiang. All rights reserved.
//

/*
 * Idea is:
 * Use separated lock for read and write
 * So, read operation is seemly lockless
 * Only lock when read/write, write/write concurrently.
 *
 * But currently, i can't find OSAtomic operation like that: compare a to value x, set b to value y. So there are no absolute safe solution -> use lock for all read/write operation
 * At least 10x faster than TSMutableDictionary
 */

#import <Foundation/Foundation.h>

@interface PMutexThreadSafeDictionary : NSMutableDictionary

@end
