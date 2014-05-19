//
//  CommandFind.h
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "BaseCommand.h"
typedef enum {
    CLASS_NAME,
    NAME,
    ID,
}FindType;
@interface CommandFind : BaseCommand
+(void)findViews:(FindType)findType TextValue:(NSString *)value Multi:(BOOL)multiple Result:(NSMutableArray*) resultArray timeout:(int)maxTime;
+ (void)classProperties:(Class)class object:(NSObject *)obj result:(NSMutableArray *)properties;
+ (void)ViewScan:(UIView *)view Find:(FindType)findType TextValue:(NSString *)value Result:(NSMutableArray*) resultArray;
+ (UIView *)findViewById:(long)_id;
+ (UIView *)waitForViewWithAccessibilityLabel:(NSString *)label valueStr:(NSString *)value traits:(UIAccessibilityTraits)traits tappable:(BOOL)mustBeTappable;
+ (void)waitForAccessibilityElement:(UIAccessibilityElement **)element view:(out UIView **)view withLabel:(NSString *)label value:(NSString *)value traits:(UIAccessibilityTraits)traits tappable:(BOOL)mustBeTappable;
@end
