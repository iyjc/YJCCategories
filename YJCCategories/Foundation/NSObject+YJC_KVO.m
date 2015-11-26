//
//  NSObject+YJC_KVO.m
//  YJCCategoriesExample
//
//  Created by leon@dev on 15/11/25.
//  Copyright © 2015年 YJC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+YJC_KVO.h"


static char kYJCKVOObserverMaperKey;
static char kYJCKVOObserverSwizzledKey;

@interface NSObject (YJCKVO_Target)
@property (nonatomic, assign, readwrite) BOOL                swizzled;
@property (nonatomic, strong, readonly)  NSMutableDictionary *observerMaper;

@end

@implementation NSObject (YJCKVO_Target)

#pragma mark - Getter / Setter

- (NSMutableDictionary *)observerMaper {
    id maper = objc_getAssociatedObject(self, &kYJCKVOObserverMaperKey);
    if(!maper) {
        maper = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &kYJCKVOObserverMaperKey, maper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return maper;
}

- (void)setSwizzled:(BOOL)swizzled {
    objc_setAssociatedObject(self, &kYJCKVOObserverSwizzledKey, @(swizzled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)swizzled {
   return [objc_getAssociatedObject(self, &kYJCKVOObserverSwizzledKey) boolValue];
}

- (void)removeAssociatedObject:(id)object {
    if(!object) {
        return;
    }
    
    objc_removeAssociatedObjects(object);
}

@end


@implementation NSObject (YJC_KVO)

- (void)beginObservingKeyPath:(NSString *)keyPath usingBlock:(YJCKVOCallback)callback {
    YJCKVOOptions options = YJCKVOOptionsNew | YJCKVOOptionsOld;
    [self beginObservingKeyPath:keyPath options:options context:NULL usingBlock:callback];
}

- (void)beginObservingKeyPath:(NSString *)keyPath options:(YJCKVOOptions)options usingBlock:(YJCKVOCallback)callback {
    [self beginObservingKeyPath:keyPath options:options context:NULL usingBlock:callback];
}

- (void)beginObservingKeyPath:(NSString *)keyPath options:(YJCKVOOptions)options context:(void *)context usingBlock:(YJCKVOCallback)callback {
    NSAssert(keyPath.length != 0, @"the length of keyPath should not be zero");
    NSAssert(callback != nil, @"the callback block should not be nil");
    
    [self addObserver:self
           forKeyPath:keyPath
              options:NSKeyValueObservingOptionNew//(NSKeyValueObservingOptions)options
              context:context];
    
    [self.observerMaper addEntriesFromDictionary:@{keyPath : callback}];
    
    [self swizzleKVOSelector];
}

- (void)stopObservingKeyPath:(NSString *)keyPath {
    NSAssert(keyPath.length != 0, @"the length of keyPath should not be zero");
    
    [self removeObserver:self forKeyPath:keyPath];
}

- (void)stopAllObserving {
    [self.observerMaper.allKeys enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger idx, BOOL *stop) {
        [self removeObserver:self forKeyPath:keyPath];
    }];
    
    [self removeAssociatedObject:self.observerMaper];
}

#pragma mark - Private Method

- (void)swizzled_observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)object change:(NSDictionary *)change context:(void *)context {
    [self swizzled_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    YJCKVOCallback callback = [self.observerMaper objectForKey:keyPath];
    
    if(!callback) {
        return;
    }
    
    callback(keyPath, object, change, context);
}

- (void)dynamic_observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)object change:(NSDictionary *)change context:(void *)context {
    YJCKVOCallback callback = [self.observerMaper objectForKey:keyPath];
    
    if(!callback) {
        return;
    }
    
    callback(keyPath, object, change, context);
}

- (void)swizzleKVOSelector {
    if(self.swizzled) {
        return;
    }
    
    SEL originalSelector = @selector(observeValueForKeyPath:ofObject:change:context:);
    SEL dynamicSelector = @selector(dynamic_observeValueForKeyPath:ofObject:change:context:);
    SEL swizzledSelector = @selector(swizzled_observeValueForKeyPath:ofObject:change:context:);
    
    Class clazz = self.class;
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method dynamicMethod = class_getInstanceMethod(clazz, dynamicSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    
    IMP dynamicImp = class_getMethodImplementation(clazz, dynamicSelector);
    
    BOOL addSuccessfully = class_addMethod(clazz,
                                           originalSelector,
                                           dynamicImp,
                                           method_getTypeEncoding(dynamicMethod));
    
    if(!addSuccessfully) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    self.swizzled = YES;
}

@end
