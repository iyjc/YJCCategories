//
//  NSObject+YJC_KVO.h
//  YJCCategoriesExample
//
//  Created by leon@dev on 15/11/25.
//  Copyright © 2015年 YJC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YJCKVOCallback)(NSString *keyPath, id object, NSDictionary *change, void *context);

@interface NSObject (YJC_KVO)

- (void)stopObserving;

- (void)beginObservingKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context usingBlock:(YJCKVOCallback)callback;

@end
