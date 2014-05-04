//
//  TypeSwapUtil.h
//  SocketConnect
//
//  Created by James_Air on 14-5-1.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TypeSwapUtil : NSObject

+ (void)  SwapIntToBytes:(int)value:(unsigned char *)bytes;
+ (int)  SwapBytesToInt:(unsigned char*)bytes;
@end
