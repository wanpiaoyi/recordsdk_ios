//
//  QKPlayerFileInfo.h
//  IJKMediaPlayer
//
//  Created by yang on 17/3/27.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QKPlayerFileInfo : NSObject
@property const char* pcFilePath;
@property(copy,nonatomic)NSString *strFilePath;
@property(nonatomic) float startTime;
@property(nonatomic) float endTime;
@property(nonatomic)float softStartTime;
@property(nonatomic) float softEndTime;
@property(nonatomic) float speed;
@property(nonatomic) int filterType;
@property(nonatomic) int useOrientation;//旋转角度

@property(nonatomic) int length;
@property(copy,nonatomic) NSString *img_path;
@property BOOL isImage;
@property BOOL isTitle;
@property float width;
@property float height;
@property NSInteger type; //转场动画：0 没有动画  1:左侧划入 2右侧划入 3:淡出4:闪白 5闪黑

@end
