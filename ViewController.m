//
//  ViewController.m
//  KVO
//
//  Created by 崇 on 2018/9/10.
//  Copyright © 2018年 崇. All rights reserved.
//

#import "ViewController.h"
#import "TestObject.h"
#import <objc/runtime.h>


@interface ViewController ()<TestKVOProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testMyKVO];
//    [self testSystemKVO];
}

#pragma mark - 自己实现的KVO

- (void)testMyKVO {
    TestObject *obj = [TestObject new];
    [self checkIMP:obj];
    
    [obj testAddObserver:self forKeyPath:@"name"];

    obj.name = @"Sam";
    [self checkIMP:obj];
    
    /*
     
     控制台打印：
     
     2018-09-11 12:40:45.701555+0800 KVO[2197:141771] ISA指向=TestObject      class指向=TestObject      imp地址=0x10d63c060
     2018-09-11 12:41:01.035249+0800 KVO[2197:141771] 自定义-[TestObject testWillChangeValueForKey:]
     2018-09-11 12:41:01.035420+0800 KVO[2197:141771] 执行原赋值方法
     2018-09-11 12:41:01.035547+0800 KVO[2197:141771] 自定义-[TestObject testDidChangeValueForKey:]
     2018-09-11 12:41:01.035825+0800 KVO[2197:141771] {
     new = Sam;
     old = "<null>";
     }
     2018-09-11 12:41:21.800980+0800 KVO[2197:141771] ISA指向=GCKVONotifiying_TestObject      class指向=TestObject      imp地址=0x10d63c730
     
     原imp：   address=0x10d63c060   (KVO`-[TestObject setName:]at TestObject.m:23)
     修改后imp：address=0x10d63c730   (KVO`GCSetObjectValueAndNotify at TestObject.m:60)
     */
}

- (void)testObserveValueForKeyPath:(NSString *)keyPath change:(NSDictionary *)change {
    NSLog(@"%@",change);
}

#pragma mark - 系统提供的KVO

- (void)testSystemKVO {
    TestObject *obj = [TestObject new];
    [self checkIMP:obj];
    
    [obj addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    obj.name = @"Tom";
    [self checkIMP:obj];
    
    /*
     
     控制台打印：
     
     2018-09-11 12:28:43.905682+0800 KVO[2062:130369] ISA指向=TestObject      class指向=TestObject      imp地址=0x10a99c140
     2018-09-11 12:29:05.082271+0800 KVO[2062:130369] willChangeValueForKey==Begin
     2018-09-11 12:29:05.082533+0800 KVO[2062:130369] willChangeValueForKey==End
     2018-09-11 12:29:05.082691+0800 KVO[2062:130369] 执行原赋值方法
     2018-09-11 12:29:05.082795+0800 KVO[2062:130369] didChangeValueForKey==Begin
     2018-09-11 12:29:05.083211+0800 KVO[2062:130369] 触发观察者observeValueForKeyPath=={
     kind = 1;
     new = Tom;
     old = "<null>";
     }
     2018-09-11 12:29:05.083396+0800 KVO[2062:130369] didChangeValueForKey==End
     2018-09-11 12:29:32.825053+0800 KVO[2062:130369] ISA指向=NSKVONotifying_TestObject      class指向=TestObject      imp地址=0x10acdea7a
     
     原imp：   address=0x10a99c140   (KVO`-[TestObject setName:]at TestObject.m:23)
     修改后imp：address=0x10acdea7a   (Foundation`_NSSetObjectValueAndNotify)
     */
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"触发观察者observeValueForKeyPath==%@",change);
}

#pragma mark - 公共方法

- (void)checkIMP:(id)obj {
    SEL sel = @selector(setName:);
    IMP imp = [obj methodForSelector:sel];
    NSLog(@"ISA指向=%@ \t class指向=%@ \t imp地址=%p",object_getClass(obj),[obj class],imp);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
