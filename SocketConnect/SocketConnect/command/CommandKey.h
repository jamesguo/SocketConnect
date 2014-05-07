//
//  CommandKey.h
//  SocketConnect
//
//  Created by yrguo on 14-5-5.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "BaseCommand.h"
#import "CommandFind.h"
#import "UIView-KIFAdditions.h"
#import "CommandClick.h"
#import "UIWindow-KIFAdditions.h"
@interface CommandKey : BaseCommand
+(void)setText:(UIView*) view appendValue:(NSString*)text;
@end
