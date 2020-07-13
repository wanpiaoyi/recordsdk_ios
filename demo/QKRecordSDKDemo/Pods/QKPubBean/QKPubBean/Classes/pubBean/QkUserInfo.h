//
//  QkUserInfo.h
//  QukanTool
//
//  Created by yangpeng on 2020/3/17.
//  Copyright © 2020 yang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QkUserInfo : NSObject
@property(strong,nonatomic) NSNumber *userId;
@property(strong,nonatomic) NSString *token;
@property(strong,nonatomic) NSString *name;

+(QkUserInfo*)getBeanByDic:(NSDictionary*)dic;
@end

NS_ASSUME_NONNULL_END
