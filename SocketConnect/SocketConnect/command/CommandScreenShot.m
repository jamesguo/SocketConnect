//
//  CommandScreenShot.m
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "CommandScreenShot.h"
#import "BlockDelayUtil.h"
@implementation CommandScreenShot
-(void) excute:(ActionProtocol*)requestCommand ActionResult:(ActionProtocol*)responseCommand{
    UIApplication *app = [UIApplication sharedApplication];
    NSMutableData *pngData = [[NSMutableData alloc]init];
//    if (app && app.windows) {
//        [BlockDelayUtil runBlock:^StepResult() {
//            [self screenShot:pngData];
//             return StepResultSuccess;
//        }];
//    }
    for (UIWindow *window in app.windows) {
        if (window) {
            UIGraphicsBeginImageContext(window.bounds.size);
            [window.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            pngData = UIImageJPEGRepresentation(image, 1);
            break;
        }
    }
    
    if ([pngData bytes]>0) {
        NSUInteger len = [pngData length];
        unsigned char *bytePtr = (unsigned char *)[pngData bytes];
        //Byte *byteData = (Byte*)malloc(len);
        NSMutableString *imageData=[[NSMutableString alloc]init];
        for (int i=0; i<len; i++) {
            [imageData appendFormat:@"%02hhX",(unsigned char)bytePtr[i]];
        }
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 0;
        NSMutableDictionary * resultInfo = [[NSMutableDictionary alloc]init];
        [resultInfo setObject:@"success" forKey:@"value"];
        [resultInfo setObject:imageData forKey:@"ImageData"];
        NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resultInfo options:NSJSONWritingPrettyPrinted error:nil];
        responseCommand.body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
    }else{
        responseCommand.actionCode = requestCommand.actionCode;
        responseCommand.seqNo = requestCommand.seqNo;
        responseCommand.result = (unsigned char) 0;
        NSMutableDictionary * errorInfo = [[NSMutableDictionary alloc]init];
        [errorInfo setObject:@"can not screen shot" forKey:@"errorinfo"];
        NSData* resultJson =[NSJSONSerialization dataWithJSONObject:errorInfo options:NSJSONWritingPrettyPrinted error:Nil];
        responseCommand.body = [[NSString alloc] initWithData:resultJson encoding:NSUTF8StringEncoding] ;
    }
    UIGraphicsEndImageContext();
}

-(void)screenShot:(NSData *)pngData
{
        UIApplication *app = [UIApplication sharedApplication];
        for (UIWindow *window in app.windows) {
            if (window) {
                UIGraphicsBeginImageContext(window.bounds.size);
                [window.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                pngData = UIImagePNGRepresentation(image);
                break;
            }
        }
}
@end
