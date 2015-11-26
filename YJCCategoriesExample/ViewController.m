//
//  ViewController.m
//  YJCCategoriesExample
//
//  Created by leon@dev on 15/11/25.
//  Copyright © 2015年 YJC. All rights reserved.
//

#import "ViewController.h"

#import "KVOTestModel.h"
#import "NSObject+YJC_KVO.h"


@interface ViewController ()
@property (nonatomic, strong) KVOTestModel          *kvoTest;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.kvoTest = [[KVOTestModel alloc] init];
    
    [self.kvoTest beginObservingKeyPath:@"property3"
                                options:YJCKVOOptionsInitial
                                context:NULL
                             usingBlock:^(NSString *keyPath, id object, NSDictionary *change, void *context)
    {
        NSLog(@"usingBlock %@ %@", keyPath, change);
    }];
    
    [self.kvoTest beginObservingKeyPath:@"property2"
                                options:YJCKVOOptionsInitial
                                context:NULL
                             usingBlock:^(NSString *keyPath, id object, NSDictionary *change, void *context)
     {
         NSLog(@"usingBlock %@ %@", keyPath, change);
     }];
    
    
    self.kvoTest.property1 = @"1";
    self.kvoTest.property2 = @2;
    self.kvoTest.property3 = @{@"key1":@1233};

    self.kvoTest.property2 = @3;
    self.kvoTest.property3 = @{@"key2":@5453};
}

- (void)dealloc {
    [self.kvoTest stopAllObserving];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
