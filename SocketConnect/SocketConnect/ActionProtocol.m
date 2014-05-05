//
//  ActionCommand.m
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "ActionProtocol.h"

@implementation ActionProtocol

-(id)init{
	self = [super init];
	if(self) {
        self.seqNo=0;
        self.actionCode=0;
        self.result=0;
        self.body=@"";
	}
	return self;
}
-(NSDictionary*)params{
    NSDictionary* json = [self.body objectFromJSONString];
    NSString* paramString = (NSString *)[json objectForKey:@"params"];
    return [paramString objectFromJSONString];
}
@end
