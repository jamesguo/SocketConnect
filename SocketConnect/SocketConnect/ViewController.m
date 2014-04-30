//
//  ViewController.m
//  SocketConnect
//
//  Created by yrguo on 14-4-30.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "ViewController.h"

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
               };
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, 480) style:UITableViewStylePlain];
    [self.view addSubview:self.mainTableView];
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
    
    self.title=@"Demo";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
}

@end
