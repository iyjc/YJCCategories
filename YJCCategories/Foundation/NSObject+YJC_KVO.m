//
//  NSObject+YJC_KVO.m
//  YJCCategoriesExample
//
//  Created by leon@dev on 15/11/25.
//  Copyright © 2015年 YJC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+YJC_KVO.h"


#pragma mark - Target

static char kYJCKVOCallbackKey;
static char kYJCObservingKeyPath;

@interface NSObject (YJCKVO_Target)
@property (nonatomic, copy)     YJCKVOCallback      callback;
@property (nonatomic, copy)     NSString            *observingKeyPath;

@end

@implementation NSObject (YJCKVO_Target)

#pragma mark - Getter / Setter

- (void)setCallback:(YJCKVOCallback)callback {
    objc_setAssociatedObject(self, &kYJCKVOCallbackKey,
                             callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (YJCKVOCallback)callback {
    return objc_getAssociatedObject(self, &kYJCKVOCallbackKey);
}

- (void)setObservingKeyPath:(NSString *)observingKeyPath {
    objc_setAssociatedObject(self, &kYJCObservingKeyPath,
                             observingKeyPath, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)observingKeyPath {
    return objc_getAssociatedObject(self, &kYJCObservingKeyPath);
}

- (void)removeAssociatedObject:(id)object {
    if(!object) {
        return;
    }
    
    objc_removeAssociatedObjects(object);
}

@end


@implementation NSObject (YJC_KVO)

- (void)beginObserving:(NSObject *)target keyPath:(NSString *)keyPath usingBlock:(YJCKVOCallback)callback {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;

}

- (void)beginObserving:(NSObject *)target keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options usingBlock:(YJCKVOCallback)callback {

}

- (void)stopObserving {
    NSAssert(self.observingKeyPath.length > 0, @"Without observingKeyPath can't be stoped");
    
    [self removeObserver:self forKeyPath:self.observingKeyPath];
    [self removeAssociatedObject:self.callback];
    [self removeAssociatedObject:self.observingKeyPath];
}

- (void)beginObservingKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context usingBlock:(YJCKVOCallback)callback {
    [self addObserver:self forKeyPath:keyPath options:options context:context];
    [self setCallback:callback];
    [self setObservingKeyPath:keyPath];
    
    [self swizzleKVOSelector];
}

#pragma mark - Private Method

- (void)swizzled_observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)object change:(NSDictionary *)change context:(void *)context {
    [self swizzled_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    [self dynamic_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)dynamic_observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)object change:(NSDictionary *)change context:(void *)context {
    if(!object.callback) {
        return;
    }
    
    object.callback(keyPath, object, change, context);
}

- (void)swizzleKVOSelector {
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
}

@end
