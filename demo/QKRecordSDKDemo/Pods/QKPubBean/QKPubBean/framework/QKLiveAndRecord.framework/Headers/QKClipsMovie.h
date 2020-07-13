//
//  QKClipsMovie.h
//  IPRecordCameraSDK
//
//  Created by yang on 17/6/29.
//  Copyright © 2017年 ReNew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QKClipsMovie : NSObject
@property (copy,nonatomic) NSString* address;

@property BOOL isImage;
@property NSInteger isTitle; //是否是片头，1片头，2片尾

@property double startTime;
@property double endTime;
@property double beginTime;//在总视频的时间轴重的开始时间
@property NSInteger transfer_type; //转场动画：0 无特效  1:左侧划入 2右侧划入 3: 淡入淡出

@end
