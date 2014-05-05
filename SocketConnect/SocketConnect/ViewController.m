//
//  ViewController.m
//  SocketConnect
//
//  Created by yrguo on 14-4-30.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/NSObject.h>
#import <UIKit/UIApplication.h>
#import <math.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "TypeSwapUtil.h"
#import "CommandFind.h"
#import "CommandClick.h"
@interface ViewController ()
{
    NSDictionary * _items;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _items = @{@"Socket Demo":@"SocketViewController",
               @"Socket Demo2":@"",
               @"Socket Demo3":@"",
               @"Socket Demo4":@"",
               @"Socket Demo5":@"",
               @"Socket Demo6":@"",
               };
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, 480) style:UITableViewStylePlain];
    [self.view addSubview:self.mainTableView];
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
    
    self.title=@"Demo";
    
    
//    [self performSelector:@selector(doIt) withObject:nil afterDelay:5];
    

    
}
-(void)doIt
{
//    UIView* view;
//    UIAccessibilityElement* element;
//    [UIAccessibilityElement accessibilityElement:&element view:&view withLabel:@"Socket Demo5" value:nil traits:UIAccessibilityTraitNone tappable:YES error:nil];
//    [CommandClick tapAccessibilityElement:element inView:view];
//    NSMutableArray* resultArray = [[NSMutableArray alloc]init];
//    [CommandFind getViews:NAME TextValue:@"Socket Demo" Multi:TRUE Result:resultArray];
//    NSMutableDictionary * viewItem = [resultArray objectAtIndex:0];
//    long viewID = [[viewItem objectForKey:@"id"]longValue];
//    UIView* view=[CommandFind findViewById:viewID];
//    [CommandClick tapAccessibilityElement:view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (id) keyInDictionary:(NSDictionary *)dict atIndex:(NSInteger)index
{
    NSArray * keys = [dict allKeys];
    if (index >= [keys count]) {
        NSLog(@" >> Error: index out of bounds. %s", __FUNCTION__);
        return nil;
    }
    
    return keys[index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"NetworkCellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString * key = [self keyInDictionary:_items atIndex:indexPath.row];
    cell.textLabel.text = key;
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [self keyInDictionary:_items atIndex:indexPath.row];
    NSString * controllerName = [_items objectForKey:key];
    
    Class controllerClass = NSClassFromString(controllerName);
    if (controllerClass != nil) {
        id controller = [[controllerClass alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        NSMutableArray* resultArray = [[NSMutableArray alloc]init];
        [CommandFind getViews:NAME TextValue:@"Socket Demo" Multi:TRUE Result:resultArray];
        NSMutableDictionary * viewItem = [resultArray objectAtIndex:0];
        long viewID = [[viewItem objectForKey:@"id"]longValue];
//        UIView* view=[CommandFind findViewById:viewID];
        UIView* view;
        UIAccessibilityElement* element;
        [UIAccessibilityElement accessibilityElement:&element view:&view withLabel:@"Socket Demo" value:nil traits:UIAccessibilityTraitNone tappable:YES error:nil];
        [CommandClick tapAccessibilityElement:element inView:view];
//        if (view)
//        {
//            
//        }
    }
}


@end
