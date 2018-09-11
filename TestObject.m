//
//  TestObject.m
//  KVO
//
//  Created by 崇 on 2018/9/10.
//  Copyright © 2018年 崇. All rights reserved.
//

#import "TestObject.h"
#import <objc/runtime.h>
#import <objc/message.h>


@interface TestObject()

@property (nonatomic, strong) id<TestKVOProtocol> observer;

@end

@implementation TestObject

- (void)setName:(NSString *)name {
    _name = name;
    NSLog(@"执行原赋值方法");
}

- (void)willChangeValueForKey:(NSString *)key {
    NSLog(@"willChangeValueForKey==Begin");
    [super willChangeValueForKey:key];
    NSLog(@"willChangeValueForKey==End");
}

- (void)didChangeValueForKey:(NSString *)key {
    NSLog(@"didChangeValueForKey==Begin");
    [super didChangeValueForKey:key];
    NSLog(@"didChangeValueForKey==End");
}

// setName = v24@0:8@16  setAge(NSInteger) = v24@0:8q16  setAge(CGFloat) = v24@0:8d16
- (void)testAddObserver:(id)observer forKeyPath:(NSString *)keyPath {
    self.observer = observer;
    
    if ([NSStringFromClass(object_getClass(self)) containsString:@"GCKVONotifiying"]) {
        NSString *selName = [NSString stringWithFormat:@"set%@:",uppercaseFirstLetter(keyPath)];
        class_addMethod(object_getClass(self), NSSelectorFromString(selName), (IMP)GCSetObjectValueAndNotify, "v@:@");
    }
    else {
        NSString *kvoClsName = [NSString stringWithFormat:@"GCKVONotifiying_%@",NSStringFromClass(object_getClass(self))];
        NSString *selName = [NSString stringWithFormat:@"set%@:",uppercaseFirstLetter(keyPath)];
        
        Class kvoCls = objc_allocateClassPair(object_getClass(self), [kvoClsName UTF8String], 0);
        class_addMethod(kvoCls, NSSelectorFromString(selName), (IMP)GCSetObjectValueAndNotify, "v@:@");
        class_addMethod(kvoCls, NSSelectorFromString(@"class"), (IMP)GCClass, "#@:@");
        
        objc_registerClassPair(kvoCls);
        object_setClass(self, kvoCls);
    }
}

static void GCSetObjectValueAndNotify(id self, SEL _cmd, id value) {

    NSString *setMethodName = NSStringFromSelector(_cmd);
    NSString *getMethodNameTemp = lowercaseFirstLetter([setMethodName stringByReplacingOccurrencesOfString:@"set" withString:@""]);
    NSString *getMethodName = [getMethodNameTemp stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    // 1.判断新值与旧值是否相同
    id oldValue = objc_getAssociatedObject(self,NSSelectorFromString(getMethodName));
    if ([value isEqual:oldValue]) return;

    Class subCls = object_getClass(self);
    Class supCls = class_getSuperclass(subCls);
    struct objc_super superInfo = {
        self,
        supCls
    };

    // 2.触发testWillChangeValueForKey
    ((void (*) (void * , SEL, ...))objc_msgSendSuper)(&superInfo, NSSelectorFromString(@"testWillChangeValueForKey:"), getMethodName);

    // 3.调用父类赋值方法给属性赋新值
    ((void (*) (void * , SEL, ...))objc_msgSendSuper)(&superInfo, _cmd, value);

    // 4.触发testDidChangeValueForKey
    ((void (*) (void * , SEL, ...))objc_msgSendSuper)(&superInfo, NSSelectorFromString(@"testDidChangeValueForKey:"), getMethodName);

    // 5.保存旧值
    objc_setAssociatedObject(self, NSSelectorFromString(getMethodName), value, OBJC_ASSOCIATION_RETAIN);
}

static Class GCClass(id self, SEL _cmd) {
    Class selfClass = object_getClass(self);
    return class_getSuperclass(selfClass);
}

- (void)testWillChangeValueForKey:(NSString *)key {
    NSLog(@"自定义%s",__func__);
}

- (void)testDidChangeValueForKey:(NSString *)key {
    NSLog(@"自定义%s",__func__);
    if (self.observer && [self.observer respondsToSelector:@selector(testObserveValueForKeyPath:change:)]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        if (!objc_getAssociatedObject(self, NSSelectorFromString(key))) {
            [dict setObject:@"<null>" forKey:@"old"];
        }
        else {
            [dict setObject:objc_getAssociatedObject(self, NSSelectorFromString(key)) forKey:@"old"];
        }
        [dict setObject:[self valueForKey:key] forKey:@"new"];
        [self.observer testObserveValueForKeyPath:key change:dict];
    }
}

static NSString * lowercaseFirstLetter(NSString *string) {
    if (!string.length) {
        return nil;
    }
    NSString *firstLetter = [string substringToIndex:1];
    NSString *otherString = [string substringFromIndex:1];
    
    NSString *result = [NSString stringWithFormat:@"%@%@",[firstLetter lowercaseString],otherString];
    return result;
}

static NSString * uppercaseFirstLetter(NSString *string) {
    if (!string.length) {
        return nil;
    }
    NSString *firstLetter = [string substringToIndex:1];
    NSString *otherString = [string substringFromIndex:1];
    
    NSString *result = [NSString stringWithFormat:@"%@%@",[firstLetter uppercaseString],otherString];
    return result;
}

- (void)dealloc {
    NSLog(@"销毁了");
}

@end
