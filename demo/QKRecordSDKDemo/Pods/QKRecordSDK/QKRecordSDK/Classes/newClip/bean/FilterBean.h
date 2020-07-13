//
//  FilterBean.h
//  QukanTool
//
//  Created by yang on 2018/6/15.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterBean : NSObject
@property(copy,nonatomic) NSString *name;
@property(nonatomic) int type; //0 原始  1怀旧 2、素描
@end
