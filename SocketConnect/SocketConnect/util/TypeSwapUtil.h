//
//  TypeSwapUtil.h
//  SocketConnect
//
//  Created by James_Air on 14-5-1.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TypeSwapUtil : NSObject

+ (void)  SwapIntToBytes:(int)value  Result:(unsigned char[])bytes;
+ (int)  SwapBytesToInt:(char[])bytes;
+(NSString*)getSimpleStr:(NSString*)origin;
@end
