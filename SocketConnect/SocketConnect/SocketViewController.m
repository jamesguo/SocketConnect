//
//  SocketViewController.m
//  SocketConnect
//
//  Created by yrguo on 14-4-30.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "SocketViewController.h"
#import "UIView-KIFAdditions.h"
#import <arpa/inet.h>
#import <netdb.h>
#import "CommandClick.h"
#import "CommandFind.h"
#import "CommandKey.h"
#define kTestHost @"http://172.16.156.234"
#define kTestPort 6100
#define TIMEOUT 10
#define CT_LABEL_WIDGET(view, tagName) do{[(view) setupAccessibility:(tagName)];}while(0)
@interface SocketViewController ()
{
    NSThread * backgroundThread;
    int socketFileDescriptor;
}
@end

@implementation SocketViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Socket";
    
    self.serverAddressTextField.delegate = self;
    self.serverPortTextField.delegate = self;
    
    self.serverAddressTextField.text = kTestHost;
    self.serverAddressTextField.accessibilityLabel = @"cthome_flight";
    self.serverPortTextField.text = [[NSNumber numberWithInt:kTestPort] stringValue];
    self.receiveTextView.text = @"";
    self.receiveTextView.editable = NO;
    [self.connectButton addTarget:self action:@selector(connectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self performSelector:@selector(doIt) withObject:nil afterDelay:5];
    
    
}
+ (UIView *)recursiveSearchClickableForView:(UIView *)parent
{
    if ([parent isKindOfClass:[UILabel class]]) {
        return parent;
    }
    for (UIView *v in [parent subviews]) {
        UIView *result = [SocketViewController recursiveSearchClickableForView:v];
        if (result) {
            return result;
        }
    }
    return nil;
}
- (void)doIt
{
    NSMutableArray* resultArray = [[NSMutableArray alloc]init];
    [CommandFind getViews:CLASS_NAME TextValue:@"UITextField" Multi:TRUE Result:resultArray];
//    [CommandFind getViews:NAME TextValue:@"http://172.16.156.234" Multi:TRUE Result:resultArray];
//    [CommandFind getViews:NAME TextValue:@"6100" Multi:TRUE Result:resultArray];
//    [CommandFind getViews:NAME TextValue:@"Connect" Multi:TRUE Result:resultArray];
    NSMutableDictionary * viewItem = [resultArray objectAtIndex:0];
    long viewID = [[viewItem objectForKey:@"id"]longValue];
    UIView* viewFinded=[SocketViewController recursiveSearchClickableForView:[CommandFind findViewById:viewID]];
    [CommandClick tapAccessibilityElement:viewFinded];
    [CommandKey setText:viewFinded appendValue:@"set up textset up textset up textset up textset up textset up text"];
//    UIView* view;
//    UIAccessibilityElement* element;
//    [UIAccessibilityElement accessibilityElement:&element view:&view withLabel:@"6100" value:nil traits:UIAccessibilityTraitNone tappable:YES error:nil];
//    [CommandClick tapAccessibilityElement:element inView:view];
}
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"Dismiss"
                                           otherButtonTitles:nil];
    [alert show];
}

- (IBAction)connectButtonClick:(id)sender
{
    NSString * serverHost = self.serverAddressTextField.text;
    NSString * serverPort = self.serverPortTextField.text;
    
    if (serverHost == nil || [serverHost isEqualToString:@""]) {
        [self showAlertWithTitle:@"Error" message:@"Server address cann't be empty!"];
        return;
    }
    
    if (serverPort == nil || [serverPort isEqualToString:@""]) {
        [self showAlertWithTitle:@"Error" message:@"Server port cann't be empty!"];
        return;
    }
    
    self.connectButton.enabled = NO;
    self.receiveTextView.text = @"Connecting to server...";
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", serverHost, serverPort]];
    if (backgroundThread==nil||!backgroundThread.isExecuting) {
        
        backgroundThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector(loadDataFromServerWithURL:)
                                                     object:url];
        [backgroundThread start];
    }
}

- (void)networkFailedWithErrorMessage:(NSString *)message
{
    // Update UI
    //
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@" >> %@", message);
        
        self.receiveTextView.text = message;
        self.connectButton.enabled = YES;
    }];
}

- (void)networkSucceedWithData:(NSData *)data
{
    // Update UI
    //
    NSString * resultsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        NSString *resultsString =[ NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
//        NSString *resultsString =[[NSString alloc] initWithBytes:[data bytes] length:strlen([data bytes]) encoding:NSUTF8StringEncoding];
        self.receiveTextView.text = resultsString;
        NSLog(@" >> Received string: %s", [data bytes]);
        self.connectButton.enabled = YES;
    }];
}

- (void)loadDataFromServerWithURL:(NSURL *)url
{
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
    setsockopt(socketFileDescriptor,SOL_SOCKET,SO_SNDTIMEO,(char *)&timeout,sizeof(struct timeval));
//    setsockopt(socketFileDescriptor,SOL_SOCKET,SO_RCVTIMEO,(char *)&timeout,sizeof(struct timeval));
    // Connect the socket
    //
    while (connect(socketFileDescriptor, (struct sockaddr *) &socketParameters, sizeof(socketParameters))==-1) {
        NSString * errorInfo = [NSString stringWithFormat:@" >> Failed to connect to %@:%@", host, port];
        [self networkFailedWithErrorMessage:errorInfo];
        sleep(10);
    }
    NSLog(@" >> Successfully connected to %@:%@", host, port);
//    [self listenSocket];
    
    NSThread * listenerThread = [[NSThread alloc] initWithTarget:self selector:@selector(listenSocket) object:nil];
    [listenerThread start];
    sleep(3);
    char heartbeat[20] = "hello server";
    [self sendMessage:heartbeat];
}
-(void)sendMessage:(char *)data
{
    NSMutableData * multData = [[NSMutableData alloc] init];
    int total  = 4+strlen(data);
    unsigned char bytes[4];
    unsigned long n = strlen(data);
    bytes[0] = (n >> 24) & 0xFF;
    bytes[1] = (n >> 16) & 0xFF;
    bytes[2] = (n >> 8) & 0xFF;
    bytes[3] = n & 0xFF;
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
        NSLog(@"Failed to sendMessage : socket is closed");
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%d", kTestHost,kTestPort]];
        [self loadDataFromServerWithURL:url];
    }
}
-(void)listenSocket
{
    NSMutableData * data ;
    while (1) {
        data = [[NSMutableData alloc] init];
        char lengthBuffer[4];
        //char *lengthBuffer;
        
        int result = recv(socketFileDescriptor, &lengthBuffer[0], 4, 0);
//        NSMutableData *lengthData = [[NSMutableData alloc] init];
        if (result==4) {
//            [lengthData appendBytes:lengthBuffer length:4];
            int totalLength = lengthBuffer[0]<<24|lengthBuffer[1]<<16|lengthBuffer[2]<<8|lengthBuffer[3];
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
                [self networkSucceedWithData:data];
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
	close(socketFileDescriptor);
    socketFileDescriptor=-1;
}

@end
