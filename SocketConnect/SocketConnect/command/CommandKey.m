//
//  CommandKey.m
//  SocketConnect
//
//  Created by yrguo on 14-5-5.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "CommandKey.h"
#import "KIFTypist.h"
#import "BlockDelayUtil.h"
@implementation CommandKey
-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    NSDictionary* params = requestCommand.params;
    long elementID = [[params objectForKey:@"elementId"] longValue];
    NSString* value = [params objectForKey:@"text"];
    //    UIView* view=[CommandKey recursiveSearchClickableForView:[CommandFind findViewById:elementID]];
    
    void (^tapText)() = ^()
    {
        UIView* view = nil;
        if(elementID>=0){
            view = [CommandFind findViewById:elementID];
            [CommandClick tapAccessibilityElement:view];
            [BlockDelayUtil waitForKeyboard];
            [self clearTextFromViewWithAccessibilityLabel:view];
        }
        [CommandKey setText:view appendValue:value];
    };
    dispatch_sync(dispatch_get_main_queue(), tapText);
    
    //    [self performSelectorOnMainThread:@selector(doIt:) withObject:view waitUntilDone:TRUE];
    //    [self performSelector:@selector(doIt:) withObject:view afterDelay:1];
    
    responseCommand.actionCode = requestCommand.actionCode;
    responseCommand.seqNo = requestCommand.seqNo;
    responseCommand.result = (unsigned char) 0;
    NSMutableDictionary * resultInfo = [[NSMutableDictionary alloc]init];
    [resultInfo setObject:@"success" forKey:@"value"];
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resultInfo options:NSJSONWritingPrettyPrinted error:Nil];
    responseCommand.body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
}
- (void)clearTextFromViewWithAccessibilityLabel:(UIView *)view
{
    
    UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] firstResponder];
    if ([firstResponder isKindOfClass:[UIView class]]) {
        view = (UIView *)firstResponder;
    }
    NSUInteger numberOfCharacters = 0 ;
    if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]] || [view isKindOfClass:[UISearchBar class]]) {
        numberOfCharacters = [(UITextField *)view text].length ;
    }
    // Per issue #294, the tap occurs in the center of the text view.  If the text is too long, this means not all text gets cleared.  To address this for most cases, we can check if the selected view conforms to UITextInput and select the whole text range.
    if ([view conformsToProtocol:@protocol(UITextInput)]) {
        id <UITextInput> textInput = (id <UITextInput>)view;
        [textInput setSelectedTextRange:[textInput textRangeFromPosition:textInput.beginningOfDocument toPosition:textInput.endOfDocument]];
        
        [BlockDelayUtil waitForTimeInterval:0.1];
        [CommandKey setText:view appendValue:@"\b"];
    } else {
        
        NSMutableString *text = [NSMutableString string];
        for (NSInteger i = 0; i < numberOfCharacters; i ++) {
            [text appendString:@"\b"];
        }
        [CommandKey setText:view appendValue:text];
    }
    
    [self expectView:view toContainText:@""];
}

- (void)expectView:(UIView *)view toContainText:(NSString *)expectedResult
{
    // We will perform some additional validation if the view is UITextField or UITextView.
    if (![view respondsToSelector:@selector(text)]) {
        return;
    }
    
    UITextView *textView = (UITextView *)view;
    
    // Some slower machines take longer for typing to catch up, so wait for a bit before failing
    [BlockDelayUtil runBlock:^StepResult() {
        
        NSString *expected = [expectedResult stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSString *actual = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        return StepResultSuccess;
    } timeout:1.0];
}

+(void)setText:(UIView*) view appendValue:(NSString*)text
{
    if (view)
    {
        
        for (NSUInteger characterIndex = 0; characterIndex < [text length]; characterIndex++) {
            NSString *characterString = [text substringWithRange:NSMakeRange(characterIndex, 1)];
            if (![KIFTypist enterCharacter:characterString])
            {
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
    }else
    {
        for (NSUInteger characterIndex = 0; characterIndex < [text length]; characterIndex++) {
            NSString *characterString = [text substringWithRange:NSMakeRange(characterIndex, 1)];
            if (![KIFTypist enterCharacter:characterString])
            {
                UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] firstResponder];
                if ([firstResponder isKindOfClass:[UIView class]]) {
                    view = (UIView *)firstResponder;
                }
                if (view!=nil) {
                    if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]] || [view isKindOfClass:[UISearchBar class]]) {
                        [(UITextField *)view setText:[[(UITextField *)view text] stringByAppendingString:characterString]];
                    }
                }
            }
        }
    }
}
@end
