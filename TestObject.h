//
//  TestObject.h
//  KVO
//
//  Created by 崇 on 2018/9/10.
//  Copyright © 2018年 崇. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TestKVOProtocol<NSObject>

- (void)testObserveValueForKeyPath:(NSString *)keyPath change:(NSDictionary *)change;

@end

@interface TestObject : NSObject

@property (nonatomic,copy) NSString *name;

- (void)testAddObserver:(id)observer forKeyPath:(NSString *)keyPath;

@end
