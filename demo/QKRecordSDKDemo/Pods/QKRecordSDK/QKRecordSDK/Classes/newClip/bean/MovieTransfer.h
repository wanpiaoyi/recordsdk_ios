//
//  MovieTransfer.h
//  QukanTool
//
//  Created by yang on 2017/12/23.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieTransfer : NSObject

@property(copy,nonatomic) NSString *name; //动画名称：无特效  左侧划入  右侧划入  淡入淡出
@property(copy,nonatomic) NSString *img_name;
@property(copy,nonatomic) NSString *img_transfer;

@property int type; //转场动画：0 无特效  1:左侧划入 2右侧划入 3: 淡入淡出 4:闪白 5闪黑
+(MovieTransfer*)getDefaultTransfer;
//获取基础的动画类型
+(NSArray*)getTransfer;
-(NSDictionary*)getDictionary;
+(MovieTransfer*)getTransferByDic:(NSDictionary*)dic;
@end
