//
//  BlockDelayUtil.h
//  SocketConnect
//
//  Created by yrguo on 14-5-7.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, StepResult) {
    StepResultFailure = 0,
    StepResultSuccess,
    StepResultWait,
};
typedef StepResult (^ExecutionBlock)();
typedef void (^CompletionBlock)(StepResult result);
#define \
WaitCondition(condition, error, ...) ({\
if (!(condition)) {\
    return StepResultWait;\
}else{\
    return StepResultSuccess;\
}\
})
@interface BlockDelayUtil : NSObject
+ (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
+ (void)fireBlockAfterDelay:(void (^)(void))block;
+ (void)runBlock:(ExecutionBlock)executionBlock complete:(CompletionBlock)completionBlock timeout:(NSTimeInterval)timeout;

+ (void)runBlock:(ExecutionBlock)executionBlock complete:(CompletionBlock)completionBlock;
+ (void)runBlock:(ExecutionBlock)executionBlock timeout:(NSTimeInterval)timeout;
+ (void)waitForTimeInterval:(NSTimeInterval)timeInterval;
+ (void)runBlock:(ExecutionBlock)executionBlock;
+ (void)waitForKeyboard;
@end
