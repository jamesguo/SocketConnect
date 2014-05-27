//
//  CommandViewDump.m
//  CTRIP_WIRELESS
//
//  Created by yrguo on 14-5-27.
//  Copyright (c) 2014年 携程. All rights reserved.
//

#import "CommandViewDump.h"
#import "CommandFind.h"
#import "TypeSwapUtil.h"
@implementation CommandViewDump
-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    NSMutableArray* resultArray = [[NSMutableArray alloc]init];
    [self viewsDump:resultArray];
    responseCommand.actionCode = requestCommand.actionCode;
    responseCommand.seqNo = requestCommand.seqNo;
    responseCommand.result = (unsigned char) 0;
    NSMutableDictionary* dirction = [[NSMutableDictionary alloc]init];
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resultArray options:NSJSONWritingPrettyPrinted error:Nil];
    NSString* elementsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [dirction setObject:elementsString forKey:@"windows"];
    [dirction setObject:@"success" forKey:@"value"];
    NSData* resultJson =[NSJSONSerialization dataWithJSONObject:dirction options:NSJSONWritingPrettyPrinted error:Nil];
    responseCommand.body = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding] ;
}

-(void)viewsDump:(NSMutableArray*) resultArray
{
    UIApplication *app = [UIApplication sharedApplication];
    for (UIWindow *window in app.windows) {
        if (window) {
            [self viewDump:window Result:resultArray];
        }
    }
}
-(void)viewDump:(UIView*) view Result:(NSMutableArray*) resultArray
{
    if (view&&![view isHidden]){
        NSString *className = [NSString stringWithFormat:@":%@",[[view class] description]];
        Class class = [view class];
        NSMutableArray *properties = [[NSMutableArray alloc] initWithCapacity:10] ;
        while (class != [NSObject class])
        {
            void (^scanViews)() = ^()
            {
                [CommandFind classProperties:class object:view result:properties];
            };
            dispatch_sync(dispatch_get_main_queue(), scanViews);
            class = [class superclass];
        }
        NSString *labelOrigin = view.accessibilityLabel ? view.accessibilityLabel: @"";
        NSString *identiferOrigin = view.accessibilityIdentifier ? view.accessibilityIdentifier: @"";
        NSString *accessValueOrigin = view.accessibilityValue ? view.accessibilityValue: @"";
        NSString *label = @"";
        NSString *identifer = @"";
        NSString *accessValue = @"";
        NSMutableDictionary *viewDescription = [[NSMutableDictionary alloc] initWithCapacity:10];
        [viewDescription setValue:[NSNumber numberWithLong:(long)view] forKey:@"id"];
        if([labelOrigin isKindOfClass:[NSString class]]){
            label = [TypeSwapUtil getSimpleStr:labelOrigin];
        }
        if([identiferOrigin isKindOfClass:[NSString class]]){
            identifer = [TypeSwapUtil getSimpleStr:identiferOrigin];
        }
        if([accessValueOrigin isKindOfClass:[NSString class]]){
            accessValue = [TypeSwapUtil getSimpleStr:accessValueOrigin];
        }
        if ([label isKindOfClass:[NSString class]]&&[label length]>0){
            className = [NSString stringWithFormat:@"|%@%@",label,className];
        }
        if([identifer isKindOfClass:[NSString class]]&&[identifer length]>0){
            className = [NSString stringWithFormat:@"|%@%@",identifer,className];
        }
        if([accessValue isKindOfClass:[NSString class]]&&[accessValue length]>0){
            className = [NSString stringWithFormat:@"|%@%@",accessValue,className];
        }
        unsigned int count = [properties count];
        for (int i = 0; i < count; i++){
            NSMutableDictionary *propertyDescription = [properties objectAtIndex:i];
            if ([(NSString*)[propertyDescription objectForKey:@"name"] isEqualToString:@"text"])
            {
                NSObject * textValue=[propertyDescription objectForKey:@"value"];
                if([textValue isKindOfClass:[NSString class]]){
                    textValue = [TypeSwapUtil getSimpleStr:[propertyDescription objectForKey:@"value"]];
                }
                if([textValue isKindOfClass:[NSString class]])
                {
                    className = [NSString stringWithFormat:@"|%@%@",textValue,className];
                }
            }

        }
        [viewDescription setValue:className forKey:@"class"];
        [resultArray insertObject:viewDescription atIndex:0];
        for (UIView *subview in [view subviews])
        {
            [self viewDump:subview Result:resultArray];
        }
    }
}
@end
