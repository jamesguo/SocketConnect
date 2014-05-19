//
//  BlockDelayUtil.m
//  SocketConnect
//
//  Created by yrguo on 14-5-7.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "BlockDelayUtil.h"
#import "KIFTypist.h"
#import <objc/runtime.h>
#import "UIApplication-KIFAdditions.h"
#define TimeOut 10.0
@implementation BlockDelayUtil

+ (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(fireBlockAfterDelay:) withObject:block afterDelay:delay];
    
}
+ (void)fireBlockAfterDelay:(void (^)(void))block {
    block();
}

+ (void)waitForKeyboard
{
    NSLog(@"Before wait Current keyborad is hidden : %d",[KIFTypist keyboardHidden]);
    [self runBlock:^StepResult() {
        WaitCondition(![KIFTypist keyboardHidden], error, @"Keyboard is not visible");
        NSLog(@"After wait Current keyborad is hidden : %d",[KIFTypist keyboardHidden]);
        return StepResultSuccess;
    } timeout:3.0];
}

+ (void)runBlock:(ExecutionBlock)executionBlock complete:(CompletionBlock)completionBlock timeout:(NSTimeInterval)timeout
{
    @autoreleasepool {
        NSDate *startDate = [NSDate date];
        StepResult result;
        NSError *error = nil;
        
        while ((result = executionBlock(&error)) == StepResultWait && -[startDate timeIntervalSinceNow] < timeout) {
            CFRunLoopRunInMode([[UIApplication sharedApplication] currentRunLoopMode] ?: kCFRunLoopDefaultMode, 0.1, false);
        }
        
        if (result == StepResultWait) {
            result = StepResultWait;
        }
        
        if (completionBlock) {
            completionBlock(result);
        }
        
        if (result == StepResultFailure) {
           
        }
    }
}
+ (void)waitForTimeInterval:(NSTimeInterval)timeInterval
{
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    
    [BlockDelayUtil runBlock:^StepResult() {
        if(([NSDate timeIntervalSinceReferenceDate] - startTime) >= timeInterval){
            return StepResultSuccess;
        }else{
            return StepResultWait;
        }
    } timeout:timeInterval + 1];
}
+ (void)runBlock:(ExecutionBlock)executionBlock complete:(CompletionBlock)completionBlock
{
    [BlockDelayUtil runBlock:executionBlock complete:completionBlock timeout:TimeOut];
}

+ (void)runBlock:(ExecutionBlock)executionBlock timeout:(NSTimeInterval)timeout
{
    [BlockDelayUtil runBlock:executionBlock complete:nil timeout:timeout];
}

+ (void)runBlock:(ExecutionBlock)executionBlock
{
    [BlockDelayUtil runBlock:executionBlock complete:nil];
}
@end