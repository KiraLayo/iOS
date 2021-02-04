//
//  NSObject.m
//  OCObjcAnalysis
//
//  Created by yp-tc-m-2548 on 2021/2/1.
//  Copyright © 2021 KiraLayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

@interface NSObjectSub : NSObject

@property (strong, nonatomic) NSObject *obj;
@property (strong, nonatomic) NSNumber *num;

@end

@implementation NSObjectSub

@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSObject *obj = [[NSObject alloc] init];

        // 获得NSObject实例对象的成员变量所占用的大小 >> 8
        NSLog(@"%zd", class_getInstanceSize([NSObject class]));

        // 获得obj指针所指向内存的大小 >> 16
        NSLog(@"%zu", malloc_size((__bridge const void *)obj));
        
        NSObjectSub *objSub = [[NSObjectSub alloc] init];

        // 获得NSObjectSub实例对象的成员变量所占用的大小 >> 24
        // 每个指针在64位系统中占8个字节
        NSLog(@"%zd", class_getInstanceSize([NSObjectSub class]));
        
        // 获得objSub 指针所指向内存的大小 >> 32
        // 因为内存对齐，最终分配的内存大小会增加
        NSLog(@"%zu", malloc_size((__bridge const void *)objSub));
    }
    return 0;
}
