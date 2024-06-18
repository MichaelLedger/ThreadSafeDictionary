//
//  UnfairLockThreadSafeDictionary.m
//  FastestThreadsafeDictionary-iOS
//
//  Created by Gavin Xiang on 2024/6/18.
//  Copyright © 2024 trongbangvp@gmail.com. All rights reserved.
//

#import "UnfairLockThreadSafeDictionary.h"
#include <os/lock.h>

// 'OSSpinLock' is deprecated: first deprecated in iOS 10.0 - Use os_unfair_lock() from <os/lock.h> instead
@interface UnfairLockThreadSafeDictionary()
{
    SD_LOCK_DECLARE(_lock);
}

@property(nonatomic, strong) NSMutableDictionary *storage;
@end

@implementation UnfairLockThreadSafeDictionary

/**
 Private common init steps
 */
- (instancetype)initCommon
{
    self = [super init];
    if (self) {
        SD_LOCK_INIT(_lock);
    }
    return self;
}

- (instancetype)init
{
    self = [self initCommon];
    if (self) {
        _storage = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    self = [self initCommon];
    if (self) {
        _storage = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }
    return self;
}

- (NSDictionary *)initWithContentsOfFile:(NSString *)path
{
    self = [self initCommon];
    if (self) {
        _storage = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initCommon];
    if (self) {
        _storage = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
    self = [self initCommon];
    if (self) {
        _storage = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary copyItems:flag];
    }
    return self;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [self initCommon];
    if (self) {
        if (!_storage) {
            _storage = [NSMutableDictionary dictionary];
        }
        if (!objects || !keys) {
            // [NSDictionary dictionary] will invoke this.
            // [NSException raise:NSInvalidArgumentException format:@"objects and keys cannot be nil"];
        } else {
            for (NSUInteger i = 0; i < cnt; ++i) {
                _storage[keys[i]] = objects[i];
            }
        }
    }
    return self;
}

#pragma mark - Read operation
//Read operation is lockless, just checking lock-write

-(NSUInteger)count
{
    SD_LOCK(self->_lock);
    
    NSUInteger n = self.storage.count;
    
    SD_UNLOCK(self->_lock);
    return n;
}

-(id) objectForKey:(id)aKey
{
    SD_LOCK(self->_lock);
    
    id val = [self.storage objectForKey:aKey];
    
    SD_UNLOCK(self->_lock);
    return val;
}

- (NSEnumerator*)keyEnumerator
{
    SD_LOCK(self->_lock);
    
    id val = [self.storage keyEnumerator];
    
    SD_UNLOCK(self->_lock);
    return val;
}
- (NSArray*)allKeys
{
    SD_LOCK(self->_lock);
    
    id val = [self.storage allKeys];
    
    SD_UNLOCK(self->_lock);
    return val;
}
- (NSArray*)allValues
{
    SD_LOCK(self->_lock);
    
    id val = [self.storage allValues];
    
    SD_UNLOCK(self->_lock);
    return val;
}

#pragma mark - Write operation
-(void) setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    SD_LOCK(self->_lock);
    
    [self.storage setObject:anObject forKey:aKey];
    
    SD_UNLOCK(self->_lock);
}

- (void)addEntriesFromDictionary:(NSDictionary*)otherDictionary
{
    SD_LOCK(self->_lock);
    
    [self.storage addEntriesFromDictionary:otherDictionary];
    
    SD_UNLOCK(self->_lock);
}

- (void)removeObjectForKey:(id)aKey
{
    SD_LOCK(self->_lock);
    
    [self.storage removeObjectForKey:aKey];
    
    SD_UNLOCK(self->_lock);
}

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    SD_LOCK(self->_lock);
    
    [self.storage removeObjectsForKeys:keyArray];
    
    SD_UNLOCK(self->_lock);
}

- (void)removeAllObjects
{
    SD_LOCK(self->_lock);
    
    [self.storage removeAllObjects];
    
    SD_UNLOCK(self->_lock);
}

@end
