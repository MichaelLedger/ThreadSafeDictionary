//
//  BarrierThreadSafeDictionary.h
//  FullBellyIntl
//
//  Created by Gavin Xiang on 2022/1/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// This dictionary uses GCD barrier to solve the ReadersWriter problem. But it's slow when there are lots of write operation
// dispatch_barrier_async is very time-consuming, almost 10 times that of dispatch_barrier_sync !!!
@interface BarrierThreadSafeDictionary : NSMutableDictionary

@end

NS_ASSUME_NONNULL_END
