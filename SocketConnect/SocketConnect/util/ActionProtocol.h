//
//  ActionCommand.h
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    CLICK = 0x001,
    FINDVIEW= 0x002,
    SWIP= 0x003,
    SCROLLTO= 0x004,
    SETTEXT= 0x005,
    GETTEXT= 0x006,
    PRESSKEY= 0x007,
    BACK= 0x008,
    MENU= 0x009,
    WAIT= 0x00A,
    WAKEUP= 0x00B,
    SCREENSHOT= 0x00C,
    VIEWDUMP= 0x00D,
    DEVICEINFO= 0x00E,
    FINISH= 0x00F,
} ActionProtocolActionType;
@interface ActionProtocol : NSObject

@property int actionCode;
@property unsigned char result;
@property int seqNo;
@property NSString * body;
- (NSDictionary *)params;
- (char *)toBytes;
@end
