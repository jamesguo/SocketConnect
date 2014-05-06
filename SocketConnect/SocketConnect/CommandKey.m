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
//    UIView* view = [CommandFind findViewById:elementID];
    UIView* view=[CommandKey recursiveSearchClickableForView:[CommandFind findViewById:elementID]];
    [CommandClick tapAccessibilityElement:view];
    [CommandKey setText:view appendValue:value];
    responseCommand.actionCode = requestCommand.actionCode;
    responseCommand.seqNo = requestCommand.seqNo;
    responseCommand.result = (unsigned char) 0;
    NSMutableDictionary * resultInfo = [[NSMutableDictionary alloc]init];
    [resultInfo setObject:@"success" forKey:@"value"];
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resultInfo options:NSJSONWritingPrettyPrinted error:Nil];
    responseCommand.body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
}
+ (UIView *)recursiveSearchClickableForView:(UIView *)parent
{
    if ([parent isKindOfClass:[UILabel class]]) {
        return parent;
    }
    for (UIView *v in [parent subviews]) {
        UIView *result = [CommandKey recursiveSearchClickableForView:v];
        if (result) {
            return result;
        }
    }
    return nil;
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
