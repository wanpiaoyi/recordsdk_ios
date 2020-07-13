//
//  QKColorFilterGroup.h
//  QukanTool
//
//  Created by yang on 2018/6/20.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QKColorFilterGroup : NSObject
// Brightness ranges from -1.0 to 1.0, with 0.0 as the normal level
@property(nonatomic) CGFloat brightness; //亮度
/** Contrast ranges from 0.0 to 4.0 (max contrast), with 1.0 as the normal level
 */
@property(nonatomic) CGFloat contrast;   //对比度
/** Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 1.0 as the normal level
 */
@property(nonatomic) CGFloat saturation; //饱和度
// Sharpness ranges from -4.0 to 4.0, with 0.0 as the normal level
@property(nonatomic) CGFloat sharpness; //锐度

/**
 * 设置色调 0 ~ 360
 * @param hue
 */
@property (nonatomic) CGFloat hue; //色调设置色调 0 ~ 360
-(NSDictionary*)getDictionary;
+(QKColorFilterGroup*)getFilterGroupByDic:(NSDictionary*)dic;

+(QKColorFilterGroup*)getDefaultFilterGroup;
@end
