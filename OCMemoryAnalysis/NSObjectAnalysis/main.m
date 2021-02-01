//
//  NSObject.m
//  OCMemoryAnalysis
//
//  Created by yp-tc-m-2548 on 2021/2/1.
//  Copyright © 2021 KiraLayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSObject *obj = [[NSObject alloc] init];

        // 获得NSObject实例对象的成员变量所占用的大小 >> 8
        NSLog(@"%zd", class_getInstanceSize([NSObject class]));

        // 获得obj指针所指向内存的大小 >> 16
        NSLog(@"%zu", malloc_size((__bridge const void *)obj));
    }
    return 0;
}
