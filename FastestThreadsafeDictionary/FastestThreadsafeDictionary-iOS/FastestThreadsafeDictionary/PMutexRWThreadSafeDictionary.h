//
//  PMutexRWThreadSafeDictionary.h
//  FastestThreadsafeDictionary-iOS
//
//  Created by Gavin Xiang on 2024/6/17.
//  Copyright © 2024 gavin.xiang. All rights reserved.
//

// It's not safe to use separated pthread_mutex_t lock for read and write!!!
// Crash: Thread 12: EXC_BAD_ACCESS (code=1, address=0x0)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PMutexRWThreadSafeDictionary : NSMutableDictionary

@end

NS_ASSUME_NONNULL_END
