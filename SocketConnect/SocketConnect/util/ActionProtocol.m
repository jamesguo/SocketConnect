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
    
//    if(self.image)
//    {
//        NSString* result = [NSString stringWithCharacters:[self.image bytes] length:[self.image length]];
////        NSString* result = [[NSString alloc] initWithBytes:[self.image bytes] length:[self.image length] encoding:NSSTring] ;
////        char imageData[[self.image length]];
//        
//        NSUInteger len = [self.image length];
//        unsigned char *bytePtr = (unsigned char *)[self.image bytes];
//        //Byte *byteData = (Byte*)malloc(len);
//        NSMutableString *resultString=[[NSMutableString alloc] init];
//        for (int i=0; i<len; i++) {
//            [resultString appendFormat:@"%02hhx",(unsigned char)bytePtr[i]];
//        }
//        
////        [self.image getBytes:imageData];
////        char * bytes = (char *)[self.image bytes];
//        return (char *)[resultString UTF8String];
//    }
//    else
//    {
        NSMutableDictionary * resultInfo = [[NSMutableDictionary alloc]init];
        [resultInfo setObject:[NSNumber numberWithInt:self.actionCode] forKey:@"actionCode"];
        [resultInfo setObject:[NSNumber numberWithInt:self.seqNo] forKey:@"seqNo"];
        [resultInfo setObject:[NSNumber numberWithInt:self.result] forKey:@"result"];
        [resultInfo setObject:self.body forKey:@"body"];
        NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resultInfo options:NSJSONWritingPrettyPrinted error:Nil];
        NSString* result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
        return (char *)[result UTF8String];
//    }
}
@end
