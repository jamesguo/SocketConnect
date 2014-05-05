//
//  BaseCommand.h
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ActionProtocol.h"
@interface BaseCommand : NSObject

-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand;
@end
