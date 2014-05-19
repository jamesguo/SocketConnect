//
//  CommandWaitToDisappear.m
//  CTRIP_WIRELESS
//
//  Created by yrguo on 14-5-13.
//  Copyright (c) 2014年 携程. All rights reserved.
//

#import "CommandWaitToDisappear.h"
#import "CommandFind.h"
#import "CommandClick.h"
#import "BlockDelayUtil.h"
@implementation CommandWaitToDisappear
-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    NSDictionary* params = requestCommand.params;
    long elementID = [[params objectForKey:@"elementId"] longValue];
    UIView* view = [CommandFind findViewById:elementID];
    if (view)
    {
        [BlockDelayUtil runBlock:^StepResult() {
            UIView* view = [CommandFind findViewById:elementID];
            return (view==nil||[view isHidden]) ? StepResultSuccess : StepResultWait;
        } timeout:30.0f];
    }
    responseCommand.actionCode = requestCommand.actionCode;
    responseCommand.seqNo = requestCommand.seqNo;
    responseCommand.result = (unsigned char) 0;
    NSMutableDictionary * resultInfo = [[NSMutableDictionary alloc]init];
    [resultInfo setObject:@"success" forKey:@"value"];
    //    responseCommand.body = [resultInfo JSONString];
    NSData* resultJson =[NSJSONSerialization dataWithJSONObject:resultInfo options:NSJSONWritingPrettyPrinted error:Nil];
    responseCommand.body = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding] ;
    
}
@end
