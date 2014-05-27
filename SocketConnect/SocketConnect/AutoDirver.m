//
//  AutoDirver.m
//  SocketConnect
//
//  Created by yrguo on 14-5-5.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import <arpa/inet.h>
#import <netdb.h>

#import "AutoDirver.h"
#import "ActionProtocol.h"
#import "TypeSwapUtil.h"
#import "CommandFind.h"
#import "CommandDeviceInfo.h"
#import "CommandClick.h"
#import "CommandKey.h"
#import "CommandSee.h"
#import "CommandViewDump.h"
#import "CommandScreenShot.h"
#import "CommandWaitToDisappear.h"
#import "KIFTypist.h"
#import "AppDelegate.h"
#import "CTNavigationController.h"
#import "CTRootViewController.h"
#import "CTHomeTabViewController.h"

#define kTestHost @"http://172.16.45.233"
//#define kTestHost @"http://172.16.45.233"

#define kTestPort @"6100"
#define TIMEOUT 30
@interface AutoDirver ()
{
    NSThread * backgroundThread;
    int socketFileDescriptor;
    BOOL finished;
}
@end
@implementation AutoDirver


- (void)popToRootHomePage
{

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    CTNavigationController *navCtr = (CTNavigationController*)delegate.window.rootViewController;
    CTRootViewController *visibleCtr = (CTRootViewController*)navCtr.visibleViewController;
    do {
        [visibleCtr.navigationController popToRootViewControllerAnimated:NO];
        [visibleCtr dismissModalViewControllerAnimated:NO];
        visibleCtr = (CTRootViewController*)navCtr.visibleViewController;;
    } while (![visibleCtr isKindOfClass:[CTHomeTabViewController class]]);
    
    [navCtr popToCtripRootViewControllerAnimated:YES];
}

-(BOOL)start
{
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", kTestHost, kTestPort]];
    if (backgroundThread==nil||!backgroundThread.isExecuting)
    {
        finished = FALSE;
        backgroundThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector(loadDataFromServerWithURL:)
                                                     object:url];
        [backgroundThread start];
    }
    [KIFTypist registerForNotifications];
    return TRUE;
}

- (void)networkFailedWithErrorMessage:(NSString *)message
{
    // Update UI
    //
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@" >> %@", message);
    }];
}

- (void)networkSucceedWithData:(NSData *)data
{
    // Update UI
    //
    ActionProtocol * actionCommand = [[ActionProtocol alloc] init];
    NSDictionary* messageJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    actionCommand.actionCode = [[messageJSON objectForKey:@"actionCode"]integerValue];
    actionCommand.seqNo = [[messageJSON objectForKey:@"seqNo"]integerValue];
    actionCommand.result = [[messageJSON objectForKey:@"result"]integerValue];
    actionCommand.body = [messageJSON objectForKey:@"body"];
    
     NSLog(@"Recevie %@",actionCommand.body );
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self excutorCommand:actionCommand];
//    }];
}
- (void) excutorCommand:(ActionProtocol *)actionCommand{
    ActionProtocol * reponseCommand = [[ActionProtocol alloc]init];
    switch (actionCommand.actionCode) {
        case FINDVIEW:
        {
            CommandFind * findCommand = [[CommandFind alloc]init];
            [findCommand excute:actionCommand ActionResult:reponseCommand];
            break;
        }
        case SEE:
        {
            CommandSee * seeCommand = [[CommandSee alloc]init];
            [seeCommand excute:actionCommand ActionResult:reponseCommand];
            break;
        }
        case CLICK:
        {
            CommandClick * clickCommand = [[CommandClick alloc]init];
            [clickCommand excute:actionCommand ActionResult:reponseCommand];
            break;
        }
        case SCREENSHOT:
        {
            CommandScreenShot * command = [[CommandScreenShot alloc]init];
            [command excute:actionCommand ActionResult:reponseCommand];
            break;
        }
        case DEVICEINFO:
        {
            CommandDeviceInfo * command = [[CommandDeviceInfo alloc]init];
            [command excute:actionCommand ActionResult:reponseCommand];
            break;
        }
        case PRESSKEY:
        {
            CommandKey * command = [[CommandKey alloc]init];
            [command excute:actionCommand ActionResult:reponseCommand];
            break;
        }
        case VIEWDUMP:
        {
            CommandViewDump * command = [[CommandViewDump alloc]init];
            [command excute:actionCommand ActionResult:reponseCommand];
            break;
        }
        case WAITTODISAPPEAR:
        {
            CommandWaitToDisappear * command = [[CommandWaitToDisappear alloc]init];
            [command excute:actionCommand ActionResult:reponseCommand];
            break;
        }
        case FINISH:
        {
            reponseCommand.actionCode = actionCommand.actionCode;
            reponseCommand.seqNo = actionCommand.seqNo;
            reponseCommand.result = (unsigned char) 0;
            NSMutableDictionary * resultInfo = [[NSMutableDictionary alloc]init];
            [resultInfo setObject:@"success" forKey:@"value"];
            NSData* jsonData =[NSJSONSerialization dataWithJSONObject:resultInfo options:NSJSONWritingPrettyPrinted error:Nil];
            reponseCommand.body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] ;
        }
        default:
            break;
    }
    if (reponseCommand) {
        [self sendMessage:[reponseCommand toBytes]];
    }
    if(reponseCommand.actionCode==FINISH){
        close(socketFileDescriptor);
    }
}
- (void)restart
{
    if (!finished) {
        finished = TRUE;
        [self popToRootHomePage];
        if(backgroundThread!=nil){
            [backgroundThread cancel];
            backgroundThread = nil;
        }
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", kTestHost, kTestPort]];
        if (backgroundThread==nil||!backgroundThread.isExecuting)
        {
            backgroundThread = [[NSThread alloc] initWithTarget:self
                                                       selector:@selector(loadDataFromServerWithURL:)
                                                         object:url];
            [backgroundThread start];
        }
    }
}
- (void)loadDataFromServerWithURL:(NSURL *)url
{
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    
    NSString * host = [url host];
    NSNumber * port = [url port];
    // Create socket
    //
    socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
    if (-1 == socketFileDescriptor) {
        NSLog(@"Failed to create socket.");
        return;
    }
    
    // Get IP address from host
    //
    struct hostent * remoteHostEnt = gethostbyname([host UTF8String]);
    if (NULL == remoteHostEnt) {
        close(socketFileDescriptor);
        [self networkFailedWithErrorMessage:@"Unable to resolve the hostname of the warehouse server."];
        return;
    }
    
    struct in_addr * remoteInAddr = (struct in_addr *)remoteHostEnt->h_addr_list[0];
    
    // Set the socket parameters
    //
	struct sockaddr_in socketParameters;
    bzero(&socketParameters,sizeof(socketParameters));
	socketParameters.sin_family = AF_INET;
	socketParameters.sin_addr = *remoteInAddr;
	socketParameters.sin_port = htons([port intValue]);
    //    memset(&(socketParameters.sin_zero), 0, 8);
    
    struct timeval timeout;
    timeout.tv_sec = TIMEOUT;
    timeout.tv_usec = 0;
//    setsockopt(socketFileDescriptor,SOL_SOCKET,SO_SNDTIMEO,(char *)&timeout,sizeof(struct timeval));
//    setsockopt(socketFileDescriptor,SOL_SOCKET,SO_RCVTIMEO,(char *)&timeout,sizeof(struct timeval));
    // Connect the socket
    //
    if(connect(socketFileDescriptor, (struct sockaddr *) &socketParameters, sizeof(socketParameters))==-1) {
        NSString * errorInfo = [NSString stringWithFormat:@" >> Failed to connect to %@:%@", host, port];
        [self networkFailedWithErrorMessage:errorInfo];
        sleep(10);
        [self loadDataFromServerWithURL:url];
        return;
    }
    
    finished = FALSE;
    
    NSLog(@" >> Successfully connected to %@:%@", host, port);
    //    [self listenSocket];
    
    NSThread * listenerThread = [[NSThread alloc] initWithTarget:self selector:@selector(listenSocket) object:nil];
    [listenerThread start];
    sleep(3);
//    char heartbeat[20] = "hello server";
//    [self sendMessage:heartbeat];
    
}
-(void)sendMessage:(char[])data
{
    NSMutableData * multData = [[NSMutableData alloc] init];
    int total  = 4+strlen(data);
    unsigned char bytes[4];
    unsigned char size[4];
    unsigned long n = strlen(data);
    [TypeSwapUtil SwapIntToBytes:n Result:bytes];
    
    size[0] = (n >> 24) & 0xFF;
    size[1] = (n >> 16) & 0xFF;
    size[2] = (n >> 8) & 0xFF;
    size[3] = n & 0xFF;
    
    [multData appendBytes:bytes length:4];
    [multData appendBytes:data length:strlen(data)];
    
    if(socketFileDescriptor!=-1){
        int result = send(socketFileDescriptor, multData.bytes, total, 0);
        if(result==-1){
            if((errno == EAGAIN)||(errno==EWOULDBLOCK)){
                NSLog(@"Need To Resend ?");
            }else{
                close(socketFileDescriptor);
                socketFileDescriptor=-1;
                NSLog(@"Failed to sendMessage");
            }
        }else{
            NSLog(@"SendMessage %s",data);
        }
    }else{
//        NSLog(@"Failed to sendMessage : socket is closed");
//        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", kTestHost,kTestPort]];
//        [self loadDataFromServerWithURL:url];
    }
}
-(void)listenSocket
{
    NSMutableData * data ;
    while (!finished) {
        data = [[NSMutableData alloc] init];
        char lengthBuffer[4];
        int result = recv(socketFileDescriptor, lengthBuffer, 4, 0);
        if (result==4) {
//           [lengthData appendBytes:lengthBuffer length:4];
            int totalLength = [TypeSwapUtil SwapBytesToInt:lengthBuffer];
//            int totalLength = lengthBuffer[0]<<24|lengthBuffer[1]<<16|lengthBuffer[2]<<8|lengthBuffer[3];
//            int totalLength = CFSwapInt32BigToHost(*(int*)([lengthData bytes]));
            //            int totalLength = *(int*)lengthBuffer;
            int currentOffset = 0;
            const char * buffer[1024];
            int length = sizeof(buffer);
            // Read a buffer's amount of data from the socket; the number of bytes read is returned
            while (currentOffset<totalLength) {
                if(totalLength-currentOffset>1024){
                    result = recv(socketFileDescriptor, &buffer, length, 0);
                }else{
                    result = recv(socketFileDescriptor, &buffer, length, 0);
                }
                
                if(result==-1){
                    if((errno == EAGAIN)||(errno==EWOULDBLOCK)){
                        continue;
                    }else{
                        break;
                    }
                }else{
                    [data appendBytes:buffer length:result];
                    currentOffset+=result;
                }
            }
            if(currentOffset==totalLength){
               NSThread* thread = [[NSThread alloc] initWithTarget:self
                                        selector:@selector(networkSucceedWithData:) object:data];
                [thread start];
//                [self networkSucceedWithData:data];
            }else{
                NSLog(@"Failed to readContent");
            }
        }else{
            if(result==-1){
                NSLog(@"Failed to readLength :%s",strerror(errno));
                if((errno == EAGAIN||errno == EWOULDBLOCK||errno == EINTR)){
                    continue;
                }else{
                    break;
                }
            }else{
                break;
            }
        }
    }
    
    //当然一定要慎用，记着退出程序时把自动休眠功能开启
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    [self restart];
}

@end
