//
//  ViewController.m
//  messageForwarding
//
//  Created by chenjiangchuan on 16/8/15.
//  Copyright © 2016年 JC'Chan. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface JCStudent : NSObject

- (void)test;

- (void)setPersonName:(NSString *)name andAge:(int)age;

@end

@implementation JCStudent

- (void)test {
    NSLog(@"%s", __func__);
}

- (void)setPersonName:(NSString *)name andAge:(int)age {
    NSLog(@"person name is %@, age is %d", name, age);
}

@end

@interface JCPerson : NSObject

- (void)test;
- (void)setPersonName:(NSString *)name andAge:(int)age;
@end

@implementation JCPerson

#if 0 // 方式一
void dynamicMethodIMP(id self, SEL _cmd)
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {

    if (sel == @selector(test)) {
        class_addMethod([self class], sel, (IMP)dynamicMethodIMP, "V@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
#endif

#if 0 // 方式二
- (id)forwardingTargetForSelector:(SEL)aSelector {

    if (aSelector == @selector(test)) {

        JCStudent *std = [[JCStudent alloc] init];
        return std;
    }

    return [super forwardingTargetForSelector:aSelector];
}
#endif

// 方式三

// 生成方法签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {

    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        JCStudent *std = [[JCStudent alloc] init];
        signature = [std methodSignatureForSelector:@selector(setPersonName: andAge:)];
    }

    return signature;
}

// 消息转发
- (void)forwardInvocation:(NSInvocation *)anInvocation {

    // 定义两个参数
    NSString *name = @"jc";
    int age = 26;

    // 设置参数
    [anInvocation setArgument:&name atIndex:2];
    [anInvocation setArgument:&age atIndex:3];

    // 绑定SEL
    anInvocation.selector = @selector(setPersonName: andAge:);

    JCStudent *std = [[JCStudent alloc] init];

    // 判断JCStudent中是否实现了绑定的SEL
    if ([std respondsToSelector:anInvocation.selector]) {
        // 绑定接收消息对象
        [anInvocation invokeWithTarget:std];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    JCPerson *person = [[JCPerson alloc] init];

    // 方式一：test方法只在JCPerson中声明没有实现
//    [person test];

    // 方式二：
//    [person performSelector:@selector(jcTest)];
    [person setPersonName:@"a" andAge:12];
}

@end
