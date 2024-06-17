//
//  BarrierThreadSafeDictionary.m
//  FullBellyIntl
//
//  Created by Gavin Xiang on 2022/1/28.
//

#import "BarrierThreadSafeDictionary.h"

@implementation BarrierThreadSafeDictionary {
    dispatch_queue_t isolationQueue_;
    NSMutableDictionary *storage_;
}

/**
 Private common init steps
 */
- (instancetype)initCommon
{
    self = [super init];
    if (self) {
        isolationQueue_ = dispatch_queue_create([@"com.thread_safe_dictionary.concurrent" UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)init
{
    self = [self initCommon];
    if (self) {
        storage_ = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    self = [self initCommon];
    if (self) {
        storage_ = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }
    return self;
}

- (NSDictionary *)initWithContentsOfFile:(NSString *)path
{
    self = [self initCommon];
    if (self) {
        storage_ = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initCommon];
    if (self) {
        storage_ = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
    self = [self initCommon];
    if (self) {
        storage_ = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary copyItems:flag];
    }
    return self;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [self initCommon];
    if (self) {
        if (!storage_) {
            storage_ = [NSMutableDictionary dictionary];
        }
        if (!objects || !keys) {
            // [NSDictionary dictionary] will invoke this.
            // [NSException raise:NSInvalidArgumentException format:@"objects and keys cannot be nil"];
        } else {
            for (NSUInteger i = 0; i < cnt; ++i) {
                storage_[keys[i]] = objects[i];
            }
        }
    }
    return self;
}

#pragma mark - Read operation
- (NSUInteger)count
{
    __block NSUInteger count;
    dispatch_sync(isolationQueue_, ^{
        count = storage_.count;
    });
    return count;
}

- (id)objectForKey:(id)aKey
{
    __block id obj;
    dispatch_sync(isolationQueue_, ^{
        obj = storage_[aKey];
    });
    return obj;
}

- (NSEnumerator *)keyEnumerator
{
    __block NSEnumerator *enu;
    dispatch_sync(isolationQueue_, ^{
        enu = [storage_ keyEnumerator];
    });
    return enu;
}

- (NSArray *)allKeys {
    __block NSArray *allKeys;
    dispatch_sync(isolationQueue_, ^{
        allKeys = [storage_ allKeys];
    });
    return allKeys;
}

- (NSArray *)allKeysForObject:(id)anObject {
    __block NSArray *allKeys;
    dispatch_sync(isolationQueue_, ^{
        allKeys = [storage_ allKeysForObject:anObject];
    });
    return allKeys;
}

- (NSArray *)allValues {
    __block NSArray *allKeys;
    dispatch_sync(isolationQueue_, ^{
        allKeys = [storage_ allValues];
    });
    return allKeys;
}

#pragma mark - Write operation
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    aKey = [aKey copyWithZone:NULL];
    dispatch_barrier_sync(isolationQueue_, ^{
        self->storage_[aKey] = anObject;
    });
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    dispatch_barrier_sync(isolationQueue_, ^{
        [self->storage_ addEntriesFromDictionary:otherDictionary];
    });
}

- (void)removeObjectForKey:(id)aKey
{
    dispatch_barrier_sync(isolationQueue_, ^{
        [self->storage_ removeObjectForKey:aKey];
    });
}

- (void)removeObjectsForKeys:(NSArray *)keyArray {
    dispatch_barrier_sync(isolationQueue_, ^{
        [self->storage_ removeObjectsForKeys:keyArray];
    });
}

- (void)removeAllObjects {
    dispatch_barrier_sync(isolationQueue_, ^{
        [self->storage_ removeAllObjects];
    });
}

@end
