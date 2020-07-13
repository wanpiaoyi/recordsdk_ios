//
//  QkUserInfo.m
//  QukanTool
//
//  Created by yangpeng on 2020/3/17.
//  Copyright © 2020 yang. All rights reserved.
//

#import "QkUserInfo.h"

@implementation QkUserInfo

+(QkUserInfo*)getBeanByDic:(NSDictionary*)dic{
    if(dic == nil || [dic isKindOfClass:[NSNull class]]){
        return nil;
    }
    QkUserInfo *info = [[QkUserInfo alloc] init];
    info.name = dic[@"name"];
    info.token  = dic[@"token"];
    info.userId = dic[@"userId"];
    return info;
}
@end
