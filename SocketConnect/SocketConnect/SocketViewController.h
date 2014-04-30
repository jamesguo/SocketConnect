//
//  SocketViewController.h
//  SocketConnect
//
//  Created by yrguo on 14-4-30.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocketViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *serverAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverPortTextField;
@property (weak, nonatomic) IBOutlet UITextView *receiveTextView;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@end
