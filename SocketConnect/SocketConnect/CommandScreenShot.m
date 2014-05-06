//
//  CommandScreenShot.m
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "CommandScreenShot.h"

@implementation CommandScreenShot
-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    UIApplication *app = [UIApplication sharedApplication];
    NSData *pngData = [[NSData alloc]init];
    if (app && app.windows) {
        void (^gatherProperties)(NSData *pngData) = ^(NSData *pngData) {
            for (UIWindow *window in app.windows) {
                if (window) {
                    UIGraphicsBeginImageContext(window.bounds.size);
                    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
                    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                    pngData = UIImagePNGRepresentation(image);
                    UIGraphicsEndImageContext();
                    break;
                }
            }
        };
        if ([NSThread mainThread] == [NSThread currentThread]) {
            gatherProperties(pngData);
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                gatherProperties(pngData);
            });
        }
    }
//    if ([resultArray count]>0) {
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 0;
    
        NSMutableDictionary * resultInfo = [[NSMutableDictionary alloc]init];
        [resultInfo setObject:@"success" forKey:@"value"];
        [resultInfo setObject:pngData.bytes forKey:@"ImageData"];
        NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resultInfo options:NSJSONWritingPrettyPrinted error:Nil];
        responseCommand.body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
//    }else{
//        responseCommand.actionCode = requestCommand.actionCode;
//        responseCommand.seqNo = requestCommand.seqNo;
//        responseCommand.result = (unsigned char) 0;
//        NSMutableDictionary * errorInfo = [[NSMutableDictionary alloc]init];
//        [errorInfo setObject:@"can not find element" forKey:@"errorinfo"];
//        responseCommand.body = [errorInfo JSONString];
//    }
}
@end
