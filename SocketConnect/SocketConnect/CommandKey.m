//
//  CommandKey.m
//  SocketConnect
//
//  Created by yrguo on 14-5-5.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "CommandKey.h"
@implementation CommandKey
-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    NSDictionary* params = requestCommand.params;
    long elementID = [[params objectForKey:@"elementId"] longValue];
    NSString* value = [params objectForKey:@"text"];
    UIView* view = [CommandFind findViewById:elementID];
    [CommandKey setText:view appendValue:value];
}
+(void)setText:(UIView*) view appendValue:(NSString*)text
{
    if (view)
    {
        
        for (NSUInteger characterIndex = 0; characterIndex < [text length]; characterIndex++) {
            NSString *characterString = [text substringWithRange:NSMakeRange(characterIndex, 1)];
            
            UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] firstResponder];
            if ([firstResponder isKindOfClass:[UIView class]]) {
                view = (UIView *)firstResponder;
            }
            if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]] || [view isKindOfClass:[UISearchBar class]]) {
                [(UITextField *)view setText:[[(UITextField *)view text] stringByAppendingString:characterString]];
            } else {
                
            }
        }
        
       
    }
}
@end
