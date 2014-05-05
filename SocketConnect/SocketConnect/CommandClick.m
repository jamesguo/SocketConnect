//
//  CommandClick.m
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "CommandClick.h"
#import "CommandFind.h"
#import "UIAccessibilityElement-KIFAdditions.h"
#import "UIView-KIFAdditions.h"
@implementation CommandClick
-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    NSDictionary* params = requestCommand.params;
    long elementID = [[params objectForKey:@"elementId"] longValue];
    UIView* view = [CommandFind findViewById:elementID];
    if (view)
    {
        [CommandClick tapAccessibilityElement:view];
    }
}
+ (void)tapAccessibilityElement:(UIView *)view
{
    CGPoint tappablePointInElement ;
    tappablePointInElement.x = view.frame.size.width/2+view.frame.origin.x;
    tappablePointInElement.y = view.frame.size.height/2+view.frame.origin.y;
    [view tapAtPoint:tappablePointInElement];
    
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
