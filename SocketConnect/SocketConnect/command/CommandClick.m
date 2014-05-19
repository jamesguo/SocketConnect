//
//  CommandClick.m
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "CommandClick.h"
#import "CommandFind.h"
#import "BlockDelayUtil.h"
#import "UIAccessibilityElement-KIFAdditions.h"
#import "UIView-KIFAdditions.h"
@implementation CommandClick
-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    NSDictionary* params = requestCommand.params;
    long elementID = [[params objectForKey:@"elementId"] longValue];
    UIView* view = [CommandFind findViewById:elementID];
    if (view)
    {
        void (^tapView)() = ^()
        {
            [CommandClick tapAccessibilityElement:view];
        };
        dispatch_sync(dispatch_get_main_queue(), tapView);
        
        [BlockDelayUtil waitForTimeInterval:1.0];
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 0;
        NSMutableDictionary * resultInfo = [[NSMutableDictionary alloc]init];
        [resultInfo setObject:@"success" forKey:@"value"];
        //    responseCommand.body = [resultInfo JSONString];
        NSData* resultJson =[NSJSONSerialization dataWithJSONObject:resultInfo options:NSJSONWritingPrettyPrinted error:Nil];
        responseCommand.body = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding] ;
    }else{
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 1;
        NSMutableDictionary * resultInfo = [[NSMutableDictionary alloc]init];
        [resultInfo setObject:@"view is nil" forKey:@"value"];
        //    responseCommand.body = [resultInfo JSONString];
        NSData* resultJson =[NSJSONSerialization dataWithJSONObject:resultInfo options:NSJSONWritingPrettyPrinted error:Nil];
        responseCommand.body = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding] ;
    }
    

}
+ (void)tapAccessibilityElement:(UIView *)view
{
    [BlockDelayUtil runBlock:^StepResult() {
        CGPoint tappablePointInElement ;
        tappablePointInElement.x = view.frame.size.width/2;
        tappablePointInElement.y = view.frame.size.height/2;
        [view tapAtPoint:tappablePointInElement];
        return StepResultSuccess;
    }];
}
+ (void)tapAccessibilityElement:(UIAccessibilityElement *)element inView:(UIView *)view
{
    CGRect elementFrame;
    if (CGRectEqualToRect(CGRectZero, element.accessibilityFrame)) {
        elementFrame.origin = CGPointZero;
        elementFrame.size = view.frame.size;
    } else {
        elementFrame = [view.windowOrIdentityWindow convertRect:element.accessibilityFrame toView:view];
    }
    CGPoint tappablePointInElement = [view tappablePointInRect:elementFrame];
    [view tapAtPoint:tappablePointInElement];
    
}

@end
