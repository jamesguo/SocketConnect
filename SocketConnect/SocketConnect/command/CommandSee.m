//
//  CommandSee.m
//  CTRIP_WIRELESS
//
//  Created by yrguo on 14-5-12.
//  Copyright (c) 2014年 携程. All rights reserved.
//

#import "CommandSee.h"
#import "CommandFind.h"
@implementation CommandSee

-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    NSDictionary* params = requestCommand.params;
    int findType = [[params objectForKey:@"findType"] integerValue];
    NSString * value = [[params objectForKey:@"value"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
    _Bool multiple = [params objectForKey:@"multiple"];
    
    //    [CommandFind getViews:NAME TextValue:@"Socket Demo" Multi:TRUE];
    NSMutableArray* resultArray = [[NSMutableArray alloc]init];
    [CommandFind getViews:findType TextValue:value Multi:multiple Result:resultArray];
    if ([resultArray count]>0) {
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 0;
        NSMutableDictionary* dirction = [[NSMutableDictionary alloc]init];
        NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resultArray options:NSJSONWritingPrettyPrinted error:Nil];
        NSString* elementsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [dirction setObject:elementsString forKey:@"elements"];
        
        NSData* resultJson =[NSJSONSerialization dataWithJSONObject:dirction options:NSJSONWritingPrettyPrinted error:Nil];
        responseCommand.body = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding] ;
        //        responseCommand.body = [resultArray JSONString];
    }else{
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 1;
        NSMutableDictionary * errorInfo = [[NSMutableDictionary alloc]init];
        [errorInfo setObject:@"can not find element" forKey:@"errorinfo"];
        NSData* resultJson =[NSJSONSerialization dataWithJSONObject:errorInfo options:NSJSONWritingPrettyPrinted error:Nil];
        responseCommand.body = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding] ;
    }
}

@end
