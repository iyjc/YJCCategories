//
//  KVOTestModel.m
//  YJCCategoriesExample
//
//  Created by leon@dev on 15/11/25.
//  Copyright © 2015年 YJC. All rights reserved.
//

#import "KVOTestModel.h"

@implementation KVOTestModel

- (id)init {
    if(self = [super init]) {
        [self addObserver:self forKeyPath:@"property2" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"property2" context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    NSLog(@"usingSelector %@ %@", keyPath, change);
}

@end
