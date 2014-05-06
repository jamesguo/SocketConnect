//
//  ActionCommand.m
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "ActionProtocol.h"
#import "TypeSwapUtil.h"
@implementation ActionProtocol

-(id)init{
	self = [super init];
	if(self) {
        self.actionCode=0;
        self.result=(unsigned char)0;
        self.seqNo=0;
        self.body=@"";
	}
	return self;
}
-(NSDictionary*)params{
    NSDictionary* json = [self.body objectFromJSONString];
    NSString* paramString = (NSString *)[json objectForKey:@"params"];
    return [paramString objectFromJSONString];
}
- (unsigned char *)toBytes{
    NSMutableData * data = [[NSMutableData alloc]init];
    unsigned char* self_ActionCode = NULL ;
    [TypeSwapUtil SwapIntToBytes:self.actionCode Result:self_ActionCode];
    unsigned char* self_seqNo = NULL;
    [TypeSwapUtil SwapIntToBytes:self.actionCode Result:self_seqNo];
    
    unsigned char* self_result = NULL;
    self_result[0] = self.result;
    [data appendBytes:self_ActionCode length:4];
    [data appendBytes:self_result length:1];
    [data appendBytes:self_seqNo length:4];
    [data appendData:[self.body dataUsingEncoding: NSUTF8StringEncoding]];
    return (unsigned char *)[data bytes];
    
}
@end
