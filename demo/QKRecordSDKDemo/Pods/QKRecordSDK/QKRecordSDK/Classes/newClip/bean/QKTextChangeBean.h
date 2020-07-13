//
//  QKTextChangeBean.h
//  QukanTool
//
//  Created by yang on 2017/12/25.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QKTextChangeBean : NSObject
@property (strong,nonatomic) NSNumber* moviePartId;

@property double startTime; //在总视频的时间轴重的开始时间
@property double endTime;   //持续时间
@property double softStartTime;//在moviePart中的开始时间
@property (copy,nonatomic) NSString *textValue;
@property (strong,nonatomic) UIColor *textColor;
@property double size; //字体
@end
