//
//  NSObject+YJC_KVO.h
//  YJCCategoriesExample
//
//  Created by leon@dev on 15/11/25.
//  Copyright © 2015年 YJC. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSUInteger, YJCKVOOptions) {
    YJCKVOOptionsNew        = NSKeyValueObservingOptionNew,
    YJCKVOOptionsOld        = NSKeyValueObservingOptionOld,
    YJCKVOOptionsInitial    = NSKeyValueObservingOptionInitial,
    YJCKVOOptionsPrior      = NSKeyValueObservingOptionPrior
};

typedef void (^YJCKVOCallback)(NSString *keyPath, id object, NSDictionary *change, void *context);

@interface NSObject (YJC_KVO)

- (void)beginObservingKeyPath:(NSString *)keyPath usingBlock:(YJCKVOCallback)callback;

- (void)beginObservingKeyPath:(NSString *)keyPath options:(YJCKVOOptions)options usingBlock:(YJCKVOCallback)callback;

- (void)beginObservingKeyPath:(NSString *)keyPath options:(YJCKVOOptions)options context:(void *)context usingBlock:(YJCKVOCallback)callback;

- (void)stopObservingKeyPath:(NSString *)keyPath;

- (void)stopAllObserving;

@end
