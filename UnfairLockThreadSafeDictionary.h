//
//  UnfairLockThreadSafeDictionary.h
//  FastestThreadsafeDictionary-iOS
//
//  Created by Gavin Xiang on 2024/6/18.
//  Copyright © 2024 MichaelLedger. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef SD_USE_OS_UNFAIR_LOCK
#define SD_USE_OS_UNFAIR_LOCK TARGET_OS_MACCATALYST ||\
    (__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0) ||\
    (__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_12) ||\
    (__TV_OS_VERSION_MIN_REQUIRED >= __TVOS_10_0) ||\
    (__WATCH_OS_VERSION_MIN_REQUIRED >= __WATCHOS_3_0)
#endif

#ifndef SD_LOCK_DECLARE
#if SD_USE_OS_UNFAIR_LOCK
#define SD_LOCK_DECLARE(lock) os_unfair_lock lock
#else
#define SD_LOCK_DECLARE(lock) os_unfair_lock lock API_AVAILABLE(ios(10.0), tvos(10), watchos(3), macos(10.12)); \
OSSpinLock lock##_deprecated;
#endif
#endif

#ifndef SD_LOCK_DECLARE_STATIC
#if SD_USE_OS_UNFAIR_LOCK
#define SD_LOCK_DECLARE_STATIC(lock) static os_unfair_lock lock
#else
#define SD_LOCK_DECLARE_STATIC(lock) static os_unfair_lock lock API_AVAILABLE(ios(10.0), tvos(10), watchos(3), macos(10.12)); \
static OSSpinLock lock##_deprecated;
#endif
#endif

#ifndef SD_LOCK_INIT
#if SD_USE_OS_UNFAIR_LOCK
#define SD_LOCK_INIT(lock) lock = OS_UNFAIR_LOCK_INIT
#else
#define SD_LOCK_INIT(lock) if (@available(iOS 10, tvOS 10, watchOS 3, macOS 10.12, *)) lock = OS_UNFAIR_LOCK_INIT; \
else lock##_deprecated = OS_SPINLOCK_INIT;
#endif
#endif

#ifndef SD_LOCK
#if SD_USE_OS_UNFAIR_LOCK
#define SD_LOCK(lock) os_unfair_lock_lock(&lock)
#else
#define SD_LOCK(lock) if (@available(iOS 10, tvOS 10, watchOS 3, macOS 10.12, *)) os_unfair_lock_lock(&lock); \
else OSSpinLockLock(&lock##_deprecated);
#endif
#endif

#ifndef SD_UNLOCK
#if SD_USE_OS_UNFAIR_LOCK
#define SD_UNLOCK(lock) os_unfair_lock_unlock(&lock)
#else
#define SD_UNLOCK(lock) if (@available(iOS 10, tvOS 10, watchOS 3, macOS 10.12, *)) os_unfair_lock_unlock(&lock); \
else OSSpinLockUnlock(&lock##_deprecated);
#endif
#endif

NS_ASSUME_NONNULL_BEGIN

@interface UnfairLockThreadSafeDictionary : NSMutableDictionary

@end

NS_ASSUME_NONNULL_END
