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
#import "HVHierarchyScanner.h"

@implementation CommandFind

-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    NSDictionary* params = requestCommand.params;
    int findType = [[params objectForKey:@"findType"] integerValue];
    NSString * value = [params objectForKey:@"value"];
    _Bool multiple = [params objectForKey:@"multiple"];
    
//    [CommandFind getViews:NAME TextValue:@"Socket Demo" Multi:TRUE];
    NSMutableArray* resultArray = [[NSMutableArray alloc]init];
    [CommandFind getViews:findType TextValue:value Multi:multiple Result:resultArray];
    if ([resultArray count]>0) {
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 0;
        NSMutableDictionary* dirction = [[NSMutableDictionary alloc]init];
        NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resultArray options:NSJSONWritingPrettyPrinted error:Nil];
        NSString* elementsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [dirction setObject:elementsString forKey:@"elements"];
        
        NSData* resultJson =[NSJSONSerialization dataWithJSONObject:dirction options:NSJSONWritingPrettyPrinted error:Nil];
        responseCommand.body = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding] ;
//        responseCommand.body = [resultArray JSONString];
    }else{
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 1;
        NSMutableDictionary * errorInfo = [[NSMutableDictionary alloc]init];
        [errorInfo setObject:@"can not find element" forKey:@"errorinfo"];
        NSData* resultJson =[NSJSONSerialization dataWithJSONObject:errorInfo options:NSJSONWritingPrettyPrinted error:Nil];
        responseCommand.body = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding] ;
    }
}


+ (UIView *)recursiveSearchForView:(long)_id parent:(UIView *)parent
{
    if ((__bridge void *)parent == (void *)_id) {
        return parent;
    }
    for (UIView *v in [parent subviews]) {
        UIView *result = [CommandFind recursiveSearchForView:_id parent:v];
        if (result) {
            return result;
        }
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
    }
    return nil;
}

+(void)getViews:(FindType)findType TextValue:(NSString *)value Multi:(BOOL)multiple Result:(NSMutableArray*) resultArray
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
            };
            if ([NSThread mainThread] == [NSThread currentThread])
            {
                gatherProperties();
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), gatherProperties);
            }
        }
        return StepResultSuccess;
    }];
}

+ (void)classProperties:(Class)class object:(NSObject *)obj result:(NSMutableArray *)propertiesArray
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    
    // handle UITextInputTraits properties which aren't KVO compilant
    BOOL conformsToUITextInputTraits = [class conformsToProtocol:@protocol(UITextInputTraits)];
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        
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
        } else if ( type && ( [type hasPrefix:@"{CGRect="] ) ) {
            readValue = NO;
            NSValue *propertyValue;
            @try {
                propertyValue = [obj valueForKey:propertyName];
            }
            @catch (NSException *exception) {
                propertyValue = nil;
            }
            [propertyDescription setValue:[NSString stringWithFormat:@"%@", NSStringFromCGRect([propertyValue CGRectValue])] forKey:@"value"];
            [propertyDescription setValue:@"CGRect" forKey:@"type"];
        } else if ( type && ( [type hasPrefix:@"{CGPoint="] ) ) {
            readValue = NO;
            NSValue *propertyValue;
            @try {
                propertyValue = [obj valueForKey:propertyName];
            }
            @catch (NSException *exception) {
                propertyValue = nil;
            }
            [propertyDescription setValue:[NSString stringWithFormat:@"%@", NSStringFromCGPoint([propertyValue CGPointValue])] forKey:@"value"];
            [propertyDescription setValue:@"CGPoint" forKey:@"type"];
        } else if ( type && ( [type hasPrefix:@"{CGSize="] ) ) {
            readValue = NO;
            NSValue *propertyValue;
            @try {
                propertyValue = [obj valueForKey:propertyName];
            }
            @catch (NSException *exception) {
                propertyValue = nil;
            }
            [propertyDescription setValue:[NSString stringWithFormat:@"%@", NSStringFromCGSize([propertyValue CGSizeValue])] forKey:@"value"];
            [propertyDescription setValue:@"CGSize" forKey:@"type"];
        } else if (type && [type hasPrefix:@"@"] && [type length] > 3) {
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
        }
        [propertiesArray addObject:propertyDescription];
        
    }
    free(properties);
}

+ (void)ViewScan:(UIView *)view Find:(FindType)findType TextValue:(NSString *)value Result:(NSMutableArray*) resultArray
{
    if (view)
    {
        // put base properties
        NSString *className = [[view class] description];
        Class class = [view class];
        NSMutableArray *properties = [[NSMutableArray alloc] initWithCapacity:10] ;
        while (class != [NSObject class])
        {
           [CommandFind classProperties:class object:view result:properties];
            class = [class superclass];
        }
        switch (findType) {
            case CLASS_NAME:
            {
                NSMutableDictionary *viewDescription = [[NSMutableDictionary alloc] initWithCapacity:10] ;
                if ([className compare:value]==0) {
                    [viewDescription setValue:[NSNumber numberWithLong:(long)view] forKey:@"id"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.origin.x)] forKey:@"layer_bounds_x"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.origin.y)] forKey:@"layer_bounds_y"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.size.width)] forKey:@"layer_bounds_w"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.bounds.size.height)] forKey:@"layer_bounds_h"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.position.x)] forKey:@"layer_position_x"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.position.y)] forKey:@"layer_position_y"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.anchorPoint.x)] forKey:@"layer_anchor_x"];
                    [viewDescription setValue:[NSNumber numberWithFloat:handleNotFinite(view.layer.anchorPoint.y)] forKey:@"layer_anchor_y"];
                    [resultArray addObject:viewDescription];
                }
                break;
            }
            case NAME:
            {
                unsigned int count = [properties count];
                int i;
                for (i = 0; i < count; i++){
                   NSMutableDictionary *propertyDescription = [properties objectAtIndex:i];
                    if ([(NSString*)[propertyDescription objectForKey:@"name"] compare:@"text"]==0)
                    {
                        if([(NSString *)[propertyDescription objectForKey:@"value"] compare:value] == 0)
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
                            [resultArray addObject:viewDescription];
                        }
                    }
                }
                break;
            }
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
                [resultArray addObject:viewDescription];
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

