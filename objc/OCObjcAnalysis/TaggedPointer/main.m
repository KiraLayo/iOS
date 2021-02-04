//
//  main.m
//  TaggedPointer
//
//  Created by yp-tc-m-2548 on 2021/2/4.
//  Copyright © 2021 KiraLayo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSNumber *obj = [NSNumber numberWithInt:1];
    
        NSLog(@"0x%6lx %@ %@", obj, obj, object_getClass(obj));
    }
    return 0;
}
