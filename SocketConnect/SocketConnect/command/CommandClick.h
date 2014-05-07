//
//  CommandClick.h
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "BaseCommand.h"
#import "UIAccessibilityElement-KIFAdditions.h"
#import "UIView-KIFAdditions.h"

@interface CommandClick : BaseCommand
+(void)tapAccessibilityElement:(UIAccessibilityElement *)element inView:(UIView *)view;
+(void)tapAccessibilityElement:(UIView *)view;
@end
