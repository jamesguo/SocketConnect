//
//  CommandFind.m
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "CommandFind.h"
#import "BlockDelayUtil.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <math.h>
#import <QuartzCore/QuartzCore.h>
#import "TypeSwapUtil.h"
#import "HVHierarchyScanner.h"
#import "UIAccessibilityElement-KIFAdditions.h"
@interface CommandFind ()
{
    int customerTimeout;
}
@end
@implementation CommandFind
-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    NSDictionary* params = requestCommand.params;
    int findType = [[params objectForKey:@"findType"] integerValue];
    customerTimeout = [[params objectForKey:@"timeout"] integerValue];
//    NSString * value = [[params objectForKey:@"value"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
    NSString * value = [TypeSwapUtil getSimpleStr:[params objectForKey:@"value"]];
    _Bool multiple = [params objectForKey:@"multiple"];
    
//    [CommandFind getViews:NAME TextValue:@"Socket Demo" Multi:TRUE];
    NSMutableArray* resultArray = [[NSMutableArray alloc]init];
    [CommandFind findViews:findType TextValue:value Multi:multiple Result:resultArray timeout:customerTimeout];
    if ([resultArray count]>0) {
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 0;
        NSMutableDictionary* dirction = [[NSMutableDictionary alloc]init];
        NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resultArray options:NSJSONWritingPrettyPrinted error:Nil];
        NSString* elementsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [dirction setObject:elementsString forKey:@"elements"];
         NSLog(@"find element %@",value);
        NSData* resultJson =[NSJSONSerialization dataWithJSONObject:dirction options:NSJSONWritingPrettyPrinted error:Nil];
        responseCommand.body = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding] ;
//        responseCommand.body = [resultArray JSONString];
    }else{
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 1;
        NSMutableDictionary * errorInfo = [[NSMutableDictionary alloc]init];
        [errorInfo setObject:[NSString stringWithFormat:@"can not find %@",value] forKey:@"errorinfo"];
        NSData* resultJson =[NSJSONSerialization dataWithJSONObject:errorInfo options:NSJSONWritingPrettyPrinted error:Nil];
        responseCommand.body = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding] ;
    }
}


+ (UIView *)recursiveSearchForView:(long)_id parent:(UIView *)parent
{
    if ((__bridge void *)parent == (void *)_id) {
        return parent;
    }
    @try {
        if (parent&&[parent isKindOfClass:[UIView class]]) {
            NSArray* subviews = [parent subviews];
            if(subviews&&subviews.count>0){
                for (UIView *v in subviews) {
                    UIView *result = [CommandFind recursiveSearchForView:_id parent:v];
                    if (result) {
                        return result;
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",[exception description]);
    }
    @finally {
        
    }
    return nil;
}

+ (UIView *)findViewById:(long)_id
{
    UIApplication *app = [UIApplication sharedApplication];
    if (app) {
        for (UIView *v in [app windows]) {
            UIView *result = [CommandFind recursiveSearchForView:_id parent:v];
            if (result) {
                return result;
            }
        }
        if (app.keyWindow&&![app.windows containsObject:app.keyWindow]) {
            UIView *result = [CommandFind recursiveSearchForView:_id parent:app.keyWindow];
            if (result) {
                return result;
            }
        }
    }
    return nil;
}

+(void)findViews:(FindType)findType TextValue:(NSString *)value Multi:(BOOL)multiple Result:(NSMutableArray*) resultArray timeout:(int)maxTime
{
    [BlockDelayUtil runBlock:^StepResult() {
        UIApplication *app = [UIApplication sharedApplication];
        if (app && app.windows)
        {
            void (^gatherProperties)() = ^()
            {
                for (UIWindow *window in app.windows)
                {
                    [CommandFind ViewScan:window Find:findType TextValue:value Result:resultArray];
                }
                if (app.keyWindow&&![app.windows containsObject:app.keyWindow]) {
                    [CommandFind ViewScan:app.keyWindow Find:findType TextValue:value Result:resultArray];
                }
            };
            //            if ([NSThread mainThread] == [NSThread currentThread])
            //            {
            gatherProperties();
            //            }
            //            else
            //            {
            //                dispatch_sync(dispatch_get_main_queue(), gatherProperties);
            //            }
        }
        if([resultArray count]>0)
        {
            return StepResultSuccess;
        }else{
            return StepResultWait;
        }
    } timeout:maxTime];
}
+ (void)classProperties:(Class)class object:(NSObject *)obj result:(NSMutableArray *)propertiesArray
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    
    // handle UITextInputTraits properties which aren't KVO compilant
    BOOL conformsToUITextInputTraits = [class conformsToProtocol:@protocol(UITextInputTraits)];
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
//        NSString * propertyName = [[NSString alloc]initWithCString:property_getName(property)  encoding:NSUTF8StringEncoding];
        NSString *className = [class description];
        
        NSMutableDictionary *propertyDescription = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:[NSString defaultCStringEncoding]] ;
        
        if (conformsToUITextInputTraits) {
            if (protocol_getMethodDescription(@protocol(UITextInputTraits), NSSelectorFromString(propertyName), NO, YES).name != NULL) {
                continue;
            }
            if ([@"secureTextEntry" isEqualToString:propertyName]) {
                continue;
            }
        }
        
        NSString *propertyType = [[NSString alloc] initWithCString:property_getAttributes(property) encoding:[NSString defaultCStringEncoding]];
        [propertyDescription setValue:propertyName forKey:@"name"];
        
        if([propertyName isEqualToString:@"name"]||[propertyName isEqualToString:@"text"]||[propertyName isEqualToString:@"cacheKey"])
        {
            NSArray *attributes = [propertyType componentsSeparatedByString:@","];
            NSString *typeAttribute = [attributes objectAtIndex:0];
            NSString *type = [typeAttribute substringFromIndex:1];
            const char *rawPropertyType = [type UTF8String];
            
            BOOL readValue = NO;
            BOOL checkOnlyIfNil = NO;
            
            if (strcmp(rawPropertyType, @encode(float)) == 0) {
                [propertyDescription setValue:@"float" forKey:@"type"];
                readValue = YES;
            } else if (strcmp(rawPropertyType, @encode(double)) == 0) {
                [propertyDescription setValue:@"double" forKey:@"type"];
                readValue = YES;
            } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
                [propertyDescription setValue:@"int" forKey:@"type"];
                readValue = YES;
            } else if (strcmp(rawPropertyType, @encode(long)) == 0) {
                [propertyDescription setValue:@"long" forKey:@"type"];
                readValue = YES;
            } else if (strcmp(rawPropertyType, @encode(BOOL)) == 0) {
                [propertyDescription setValue:@"BOOL" forKey:@"type"];
                readValue = NO;
                NSNumber *propertyValue;
                @try {
                    propertyValue = [obj valueForKey:propertyName];
                }
                @catch (NSException *exception) {
                    propertyValue = nil;
                }
                [propertyDescription setValue:([propertyValue boolValue] ? @"YES" : @"NO") forKey:@"value"];
            } else if (strcmp(rawPropertyType, @encode(char)) == 0) {
                [propertyDescription setValue:@"char" forKey:@"type"];
            }
            //        else if ( type && ( [type hasPrefix:@"{CGRect="] ) ) {
            //            readValue = NO;
            //            NSValue *propertyValue;
            //            @try {
            //                propertyValue = [obj valueForKey:propertyName];
            //            }
            //            @catch (NSException *exception) {
            //                propertyValue = nil;
            //            }
            //            [propertyDescription setValue:[NSString stringWithFormat:@"%@", NSStringFromCGRect([propertyValue CGRectValue])] forKey:@"value"];
            //            [propertyDescription setValue:@"CGRect" forKey:@"type"];
            //        } else if ( type && ( [type hasPrefix:@"{CGPoint="] ) ) {
            //            readValue = NO;
            //            NSValue *propertyValue;
            //            @try {
            //                propertyValue = [obj valueForKey:propertyName];
            //            }
            //            @catch (NSException *exception) {
            //                propertyValue = nil;
            //            }
            //            [propertyDescription setValue:[NSString stringWithFormat:@"%@", NSStringFromCGPoint([propertyValue CGPointValue])] forKey:@"value"];
            //            [propertyDescription setValue:@"CGPoint" forKey:@"type"];
            //        } else if ( type && ( [type hasPrefix:@"{CGSize="] ) ) {
            //            readValue = NO;
            //            NSValue *propertyValue;
            //            @try {
            //                propertyValue = [obj valueForKey:propertyName];
            //            }
            //            @catch (NSException *exception) {
            //                propertyValue = nil;
            //            }
            //            [propertyDescription setValue:[NSString stringWithFormat:@"%@", NSStringFromCGSize([propertyValue CGSizeValue])] forKey:@"value"];
            //            [propertyDescription setValue:@"CGSize" forKey:@"type"];
            //        }
            else if (type && [type hasPrefix:@"@"] && [type length] > 3) {
                readValue = YES;
                checkOnlyIfNil = YES;
                NSString *typeClassName = [type substringWithRange:NSMakeRange(2, [type length] - 3)];
                [propertyDescription setValue:typeClassName forKey:@"type"];
                if ([typeClassName isEqualToString:[[NSString class] description]]) {
                    checkOnlyIfNil = NO;
                }
                if ([typeClassName isEqualToString:[[UIFont class] description]]) {
                    checkOnlyIfNil = NO;
                }
            } else {
                [propertyDescription setValue:propertyType forKey:@"type"];
            }
            if (readValue) {
                id propertyValue;
                @try {
                    propertyValue = [obj valueForKey:propertyName];
                }
                @catch (NSException *exception) {
                    propertyValue = nil;
                }
                if (checkOnlyIfNil) {
                    [propertyDescription setValue:(propertyValue != nil ? @"OBJECT" : @"nil") forKey:@"value"];
                } else {
                    [propertyDescription setValue:(propertyValue != nil ? [NSString stringWithFormat:@"%@", propertyValue] : @"nil") forKey:@"value"];
                }
                
                //            if (propertyValue!=nil) {
                //                if ([propertyValue isKindOfClass:[NSString class]]) {
                //                    NSLog(@"class Name is = %@ property = %@ && attr = %s && value = %@",className,propertyName, property_getAttributes(property),propertyValue);
                //                }
                //            }
            }
            
            
            [propertiesArray addObject:propertyDescription];
        }
        
    }
    free(properties);
}

+ (UIView *)waitForViewWithAccessibilityLabel:(NSString *)label valueStr:(NSString *)value traits:(UIAccessibilityTraits)traits tappable:(BOOL)mustBeTappable
{
    UIView *view = nil;
    [self waitForAccessibilityElement:NULL view:&view withLabel:label value:value traits:traits tappable:mustBeTappable];
    return view;
}

+ (void)waitForAccessibilityElement:(UIAccessibilityElement **)element view:(out UIView **)view withLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits tappable:(BOOL)mustBeTappable
{
//    [[[KIFUITestActor alloc]init] runBlock:^KIFTestStepResult(NSError *__autoreleasing *error) {
//        return [UIAccessibilityElement accessibilityElement:element view:view withLabel:label value:value traits:traits tappable:mustBeTappable error:error] ? KIFTestStepResultSuccess : KIFTestStepResultWait;
//    }];
    
    
    [BlockDelayUtil runBlock:^StepResult() {
        return [UIAccessibilityElement accessibilityElement:element view:view withLabel:label value:value traits:traits tappable:mustBeTappable error:Nil] ? StepResultSuccess : StepResultWait;
    }];
}
+ (void)ViewScan:(UIView *)view Find:(FindType)findType TextValue:(NSString *)value Result:(NSMutableArray*) resultArray
{
    if (view&&![view isHidden])
    {
        // put base properties
        NSString *className = [[view class] description];
        Class class = [view class];
        NSMutableArray *properties = [[NSMutableArray alloc] initWithCapacity:10] ;
        while (class != [NSObject class])
        {
            void (^scanViews)() = ^()
            {
                [CommandFind classProperties:class object:view result:properties];
            };
            dispatch_sync(dispatch_get_main_queue(), scanViews);
//           [CommandFind classProperties:class object:view result:properties];
            class = [class superclass];
        }
        switch (findType) {
            case CLASS_NAME:
            {
                NSMutableDictionary *viewDescription = [[NSMutableDictionary alloc] initWithCapacity:10] ;
                if ([className isEqualToString:value]) {
                    [viewDescription setValue:[NSNumber numberWithLong:(long)view] forKey:@"id"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.origin.x)] forKey:@"layer_bounds_x"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.origin.y)] forKey:@"layer_bounds_y"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.size.width)] forKey:@"layer_bounds_w"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.size.height)] forKey:@"layer_bounds_h"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.position.x)] forKey:@"layer_position_x"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.position.y)] forKey:@"layer_position_y"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.anchorPoint.x)] forKey:@"layer_anchor_x"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.anchorPoint.y)] forKey:@"layer_anchor_y"];
                    [resultArray insertObject:viewDescription atIndex:0];
                }
                break;
            }
            case NAME:
            {
//                UICascadingTextStorage
                NSString *labelOrigin = view.accessibilityLabel ? view.accessibilityLabel: @"";
                NSString *identiferOrigin = view.accessibilityIdentifier ? view.accessibilityIdentifier: @"";
                NSString *accessValueOrigin = view.accessibilityValue ? view.accessibilityValue: @"";
                NSString *label = @"";
                NSString *identifer = @"";
                NSString *accessValue = @"";
                if([labelOrigin isKindOfClass:[NSString class]]){
                   label = [TypeSwapUtil getSimpleStr:labelOrigin];
                }
                if([identiferOrigin isKindOfClass:[NSString class]]){
                    identifer = [TypeSwapUtil getSimpleStr:identiferOrigin];
                }
                if([accessValueOrigin isKindOfClass:[NSString class]]){
                    accessValue = [TypeSwapUtil getSimpleStr:accessValueOrigin];
                }
                if (
                    ([labelOrigin isKindOfClass:[NSString class]] &&
                     [label isEqualToString:value])
                    ||
                    ([identiferOrigin isKindOfClass:[NSString class]] &&
                     [identifer isEqualToString:value])
                    ||
                    ([accessValueOrigin isKindOfClass:[NSString class]] &&
                     [accessValue isEqualToString:value])
                    )
                {
                    NSMutableDictionary *viewDescription = [[NSMutableDictionary alloc] initWithCapacity:10];
                    [viewDescription setValue:[NSNumber numberWithLong:(long)view] forKey:@"id"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.origin.x)] forKey:@"layer_bounds_x"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.origin.y)] forKey:@"layer_bounds_y"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.size.width)] forKey:@"layer_bounds_w"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.size.height)] forKey:@"layer_bounds_h"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.position.x)] forKey:@"layer_position_x"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.position.y)] forKey:@"layer_position_y"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.anchorPoint.x)] forKey:@"layer_anchor_x"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.anchorPoint.y)] forKey:@"layer_anchor_y"];
                    [resultArray insertObject:viewDescription atIndex:0];
                    break;
                }
                unsigned int count = [properties count];
                for (int i = 0; i < count; i++){
                    if(i==97){
                        [properties objectAtIndex:i];
                    }
                   NSMutableDictionary *propertyDescription = [properties objectAtIndex:i];
                    if([[NSString stringWithUTF8String:object_getClassName(view)] isEqualToString:@"UIKBKeyView"])
                    {
                        if ([(NSString*)[propertyDescription objectForKey:@"name"] isEqualToString:@"cacheKey"])
                        {
                            NSObject * textValue=[propertyDescription objectForKey:@"value"];
                            if([textValue isKindOfClass:[NSString class]])
                            {
                                textValue = [TypeSwapUtil getSimpleStr:[propertyDescription objectForKey:@"value"]];
                                NSRange range = [(NSString*)textValue rangeOfString:value];
                                if (range.length >0){
                                    NSMutableDictionary *viewDescription = [[NSMutableDictionary alloc] initWithCapacity:10] ;
                                    [viewDescription setValue:[NSNumber numberWithLong:(long)view] forKey:@"id"];
                                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.origin.x)] forKey:@"layer_bounds_x"];
                                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.origin.y)] forKey:@"layer_bounds_y"];
                                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.size.width)] forKey:@"layer_bounds_w"];
                                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.size.height)] forKey:@"layer_bounds_h"];
                                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.position.x)] forKey:@"layer_position_x"];
                                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.position.y)] forKey:@"layer_position_y"];
                                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.anchorPoint.x)] forKey:@"layer_anchor_x"];
                                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.anchorPoint.y)] forKey:@"layer_anchor_y"];
                                    [resultArray insertObject:viewDescription atIndex:0];
                                    break;
                                }
                            }
                        }
                    }
                    if ([(NSString*)[propertyDescription objectForKey:@"name"] isEqualToString:@"text"])
                    {
                        NSObject * textValue=[propertyDescription objectForKey:@"value"];
                        if([textValue isKindOfClass:[NSString class]]){
                            textValue = [TypeSwapUtil getSimpleStr:[propertyDescription objectForKey:@"value"]];
                        }
                        if([textValue isKindOfClass:[NSString class]]
                           && [(NSString*)textValue isEqualToString:value])
                        {
                            NSMutableDictionary *viewDescription = [[NSMutableDictionary alloc] initWithCapacity:10] ;
                            [viewDescription setValue:[NSNumber numberWithLong:(long)view] forKey:@"id"];
                            [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.origin.x)] forKey:@"layer_bounds_x"];
                            [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.origin.y)] forKey:@"layer_bounds_y"];
                            [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.size.width)] forKey:@"layer_bounds_w"];
                            [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.size.height)] forKey:@"layer_bounds_h"];
                            [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.position.x)] forKey:@"layer_position_x"];
                            [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.position.y)] forKey:@"layer_position_y"];
                            [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.anchorPoint.x)] forKey:@"layer_anchor_x"];
                            [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.anchorPoint.y)] forKey:@"layer_anchor_y"];
                            [resultArray insertObject:viewDescription atIndex:0];
                        }
                    }
                }
            }
            break;
            case ID:{
                
                UIView* findView = [CommandFind findViewById:[value intValue]];
                NSMutableDictionary *viewDescription = [[NSMutableDictionary alloc] initWithCapacity:10] ;
                [viewDescription setValue:[NSNumber numberWithLong:(long)findView] forKey:@"id"];
                [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(findView.layer.bounds.origin.x)] forKey:@"layer_bounds_x"];
                [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(findView.layer.bounds.origin.y)] forKey:@"layer_bounds_y"];
                [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(findView.layer.bounds.size.width)] forKey:@"layer_bounds_w"];
                [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(findView.layer.bounds.size.height)] forKey:@"layer_bounds_h"];
                [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(findView.layer.position.x)] forKey:@"layer_position_x"];
                [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(findView.layer.position.y)] forKey:@"layer_position_y"];
                [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(findView.layer.anchorPoint.x)] forKey:@"layer_anchor_x"];
                [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(findView.layer.anchorPoint.y)] forKey:@"layer_anchor_y"];
                [resultArray insertObject:viewDescription atIndex:0];
                break;
            }
            default:
                break;
        }
        for (UIView *subview in [view subviews])
        {
            [CommandFind ViewScan:subview Find:findType TextValue:value Result: resultArray];
        }
    }
}
@end

