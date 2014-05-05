//
//  CommandDeviceInfo.m
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "CommandDeviceInfo.h"

@implementation CommandDeviceInfo
-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    UIDevice *device_=[[UIDevice alloc] init];
    UIScreen *currentScreen = [[UIScreen alloc] init];
    NSMutableDictionary* deviceInfo = [[NSMutableDictionary alloc] init];
    [deviceInfo setObject:[NSNumber numberWithFloat:currentScreen.bounds.size.height] forKey:@"height"];
    [deviceInfo setObject:[NSNumber numberWithFloat:currentScreen.bounds.size.width] forKey:@"width"];
    [deviceInfo setObject:device_.model forKey:@"MODEL"];
    [deviceInfo setObject:@""forKey:@""@"BOARD" ];
    [deviceInfo setObject:@"" forKey:@"MANUFACTUER"];
    [deviceInfo setObject:device_.identifierForVendor.UUIDString forKey:@"UUID"];
    [deviceInfo setObject:device_.systemVersion forKey:@"VERSION"];
    [deviceInfo setObject:device_.name forKey:@"NAME"];
//    if ([resultArray count]>0) {
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 0;
        NSMutableDictionary * resultInfo = [[NSMutableDictionary alloc]init];
        [resultInfo setObject:@"success" forKey:@"value"];
        responseCommand.body = [resultInfo JSONString];
//    }else{
//        responseCommand.actionCode = requestCommand.actionCode;
//        responseCommand.seqNo = requestCommand.seqNo;
//        responseCommand.result = (unsigned char) 0;
//        NSMutableDictionary * errorInfo = [[NSMutableDictionary alloc]init];
//        [errorInfo setObject:@"can not find element" forKey:@"errorinfo"];
//        responseCommand.body = [errorInfo JSONString];
//    }
}
@end
