//
//  TypeSwapUtil.m
//  SocketConnect
//
//  Created by James_Air on 14-5-1.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "TypeSwapUtil.h"

@implementation TypeSwapUtil

+ (void) SwapIntToBytes:(int)value Result:(unsigned char[])bytes
{
    bytes[0] = (value >> 24) & 0xFF;
    bytes[1] = (value >> 16) & 0xFF;
    bytes[2] = (value >> 8) & 0xFF;
    bytes[3] = value & 0xFF;
};
+ (int) SwapBytesToInt:(char[])pBlah
{
//    printf("SwapBytesToInt\n");
//    printf("%d\n", pBlah [0]);
//    printf("%d\n", pBlah [1]);
//    printf("%d\n", pBlah [2]);
//    printf("%d\n", pBlah [3]);
    int result = ((pBlah[0]& 0xFF)<<24)|((pBlah[1]& 0xFF)<<16)|((pBlah[2]&0xFF)<<8)|(pBlah[3]&0xFF);
    return result;
};
@end
