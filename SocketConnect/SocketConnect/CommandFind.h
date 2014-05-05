//
//  CommandFind.h
//  SocketConnect
//
//  Created by yrguo on 14-5-4.
//  Copyright (c) 2014年 yrguo. All rights reserved.
//

#import "BaseCommand.h"
typedef enum {
    CLASS_NAME,
    NAME,
    ID,
}FindType;
@interface CommandFind : BaseCommand
+ (void)getViews:(FindType)findType TextValue:(NSString *)value Multi:(BOOL)multiple Result:(NSMutableArray*) resultArray;
+ (void)classProperties:(Class)class object:(NSObject *)obj result:(NSMutableArray *)properties;
+ (void)ViewScan:(UIView *)view Find:(FindType)findType TextValue:(NSString *)value Result:(NSMutableArray*) resultArray;
+ (UIView *)findViewById:(long)_id;
@end
