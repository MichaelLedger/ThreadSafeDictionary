//
//  TBThreadSafeMutableDictionary.m
//  TestLockless-iOS
//
//  Created by gavin.xiang on 2024/6/17.
//  Copyright © 2024 gavin.xiang. All rights reserved.
//
#import <pthread/pthread.h>
#import "PMutexThreadSafeDictionary.h"

@interface PMutexThreadSafeDictionary()
{
    pthread_mutex_t _mutex;
}
@property(atomic, strong) NSMutableDictionary *storage;
@end

@implementation PMutexThreadSafeDictionary

/**
 Private common init steps
 */
- (instancetype)initCommon
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&_mutex, NULL);
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


-(void)dealloc
{
    pthread_mutex_destroy(&_mutex);
}

#pragma mark - Read operation
//Read operation is lockless, just checking lock-write

-(NSUInteger)count
{
    pthread_mutex_lock(&_mutex);
    
    NSUInteger n = self.storage.count;
    
    pthread_mutex_unlock(&_mutex);
    return n;
}

-(id) objectForKey:(id)aKey
{
    pthread_mutex_lock(&_mutex);
    
    id val = [self.storage objectForKey:aKey];
    
    pthread_mutex_unlock(&_mutex);
    return val;
}

- (NSEnumerator*)keyEnumerator
{
    pthread_mutex_lock(&_mutex);
    
    id val = [self.storage keyEnumerator];
    
    pthread_mutex_unlock(&_mutex);
    return val;
}
- (NSArray*)allKeys
{
    pthread_mutex_lock(&_mutex);
    
    id val = [self.storage allKeys];
    
    pthread_mutex_unlock(&_mutex);
    return val;
}
- (NSArray*)allValues
{
    pthread_mutex_lock(&_mutex);
    
    id val = [self.storage allValues];
    
    pthread_mutex_unlock(&_mutex);
    return val;
}

#pragma mark - Write operation
-(void) setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    pthread_mutex_lock(&_mutex);
    
    [self.storage setObject:anObject forKey:aKey];
    
    pthread_mutex_unlock(&_mutex);
}

- (void)addEntriesFromDictionary:(NSDictionary*)otherDictionary
{
    pthread_mutex_lock(&_mutex);
    
    [self.storage addEntriesFromDictionary:otherDictionary];
    
    pthread_mutex_unlock(&_mutex);
}

- (void)removeObjectForKey:(id)aKey
{
    pthread_mutex_lock(&_mutex);
    
    [self.storage removeObjectForKey:aKey];
    
    pthread_mutex_unlock(&_mutex);
}

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    pthread_mutex_lock(&_mutex);
    
    [self.storage removeObjectsForKeys:keyArray];
    
    pthread_mutex_unlock(&_mutex);
}

- (void)removeAllObjects
{
    pthread_mutex_lock(&_mutex);
    
    [self.storage removeAllObjects];
    
    pthread_mutex_unlock(&_mutex);
}

@end

