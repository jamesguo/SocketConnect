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
    NSData* data = [self.body dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* bodyJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString* paramString = (NSString *)[bodyJSON objectForKey:@"params"];
    NSData* paramsData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:paramsData options:NSJSONReadingMutableLeaves error:nil];
}
- (char *)toBytes{
    NSMutableDictionary * resultInfo = [[NSMutableDictionary alloc]init];
    [resultInfo setObject:[NSNumber numberWithInt:self.actionCode] forKey:@"actionCode"];
    [resultInfo setObject:[NSNumber numberWithInt:self.seqNo] forKey:@"seqNo"];
    [resultInfo setObject:[NSNumber numberWithInt:self.result] forKey:@"result"];
    [resultInfo setObject:self.body forKey:@"body"];
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resultInfo options:NSJSONWritingPrettyPrinted error:Nil];
    NSString* result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
    return (char *)[result UTF8String];
}
@end
