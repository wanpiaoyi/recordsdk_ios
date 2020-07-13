//
//  QKImageChangeBean.h
//  QukanTool
//
//  Created by yang on 2019/1/28.
//  Copyright © 2019 yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QKImageChangeBean : NSObject
@property (strong,nonatomic) NSNumber* moviePartId;

@property double startTime; //在总视频的时间轴重的开始时间
@property double endTime;   //持续时间
@property double softStartTime;//在moviePart中的开始时间
@property double scale; //大小

@end
