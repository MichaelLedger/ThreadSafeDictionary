//
//  PMutexRWThreadSafeDictionary.m
//  FastestThreadsafeDictionary-iOS
//
//  Created by Gavin Xiang on 2024/6/17.
//  Copyright © 2024 trongbangvp@gmail.com. All rights reserved.
//

#import <pthread/pthread.h>
#import "PMutexRWThreadSafeDictionary.h"

@interface PMutexRWThreadSafeDictionary()
{
    pthread_mutex_t _mutex_read;
    pthread_mutex_t _mutex_write;
}
@property(atomic, strong) NSMutableDictionary* dic;
@end

@implementation PMutexRWThreadSafeDictionary

-(id) init
{
    if(self = [super init])
    {
        pthread_mutex_init(&_mutex_read, NULL);
        pthread_mutex_init(&_mutex_write, NULL);
        _dic = [NSMutableDictionary new];
    }
    return self;
}
-(id)initWithDictionary:(NSDictionary *)otherDictionary
{
    if(self = [super init])
    {
        if(otherDictionary)
            _dic = [otherDictionary mutableCopy];
        else
            _dic = [NSMutableDictionary new];
    }
    return self;
}
-(void)dealloc
{
    pthread_mutex_destroy(&_mutex_read);
    pthread_mutex_destroy(&_mutex_write);
}

#pragma mark - Read operation
//Read operation is lockless, just checking lock-write

-(NSUInteger)count
{
    pthread_mutex_lock(&_mutex_read);
    
    NSUInteger n = self.dic.count;
    
    pthread_mutex_unlock(&_mutex_read);
    return n;
}

-(id) objectForKey:(id)aKey
{
    pthread_mutex_lock(&_mutex_read);
    
    id val = [self.dic objectForKey:aKey];
    
    pthread_mutex_unlock(&_mutex_read);
    return val;
}

- (NSEnumerator*)keyEnumerator
{
    pthread_mutex_lock(&_mutex_read);
    
    id val = [self.dic keyEnumerator];
    
    pthread_mutex_unlock(&_mutex_read);
    return val;
}
- (NSArray*)allKeys
{
    pthread_mutex_lock(&_mutex_read);
    
    id val = [self.dic allKeys];
    
    pthread_mutex_unlock(&_mutex_read);
    return val;
}
- (NSArray*)allValues
{
    pthread_mutex_lock(&_mutex_read);
    
    id val = [self.dic allValues];
    
    pthread_mutex_unlock(&_mutex_read);
    return val;
}

#pragma mark - Write operation
-(void) setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    pthread_mutex_lock(&_mutex_write);
    
    [self.dic setObject:anObject forKey:aKey];
    
    pthread_mutex_unlock(&_mutex_write);
}

- (void)addEntriesFromDictionary:(NSDictionary*)otherDictionary
{
    pthread_mutex_lock(&_mutex_write);
    
    [self.dic addEntriesFromDictionary:otherDictionary];
    
    pthread_mutex_unlock(&_mutex_write);
}

- (void)removeObjectForKey:(id)aKey
{
    pthread_mutex_lock(&_mutex_write);
    
    [self.dic removeObjectForKey:aKey];
    
    pthread_mutex_unlock(&_mutex_write);
}

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    pthread_mutex_lock(&_mutex_write);
    
    [self.dic removeObjectsForKeys:keyArray];
    
    pthread_mutex_unlock(&_mutex_write);
}

- (void)removeAllObjects
{
    pthread_mutex_lock(&_mutex_write);
    
    [self.dic removeAllObjects];
    
    pthread_mutex_unlock(&_mutex_write);
}

@end


