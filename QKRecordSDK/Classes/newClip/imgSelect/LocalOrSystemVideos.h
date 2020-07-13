//
//  LocalOrSystemVideos.h
//  QukanTool
//
//  Created by yang on 17/1/9.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QKVideoBean;
typedef void (^BlockselectVideos)(NSArray<QKVideoBean *> *array);

@interface LocalOrSystemVideos : UIView
/*
 选择的文件
 */
@property(copy,nonatomic) BlockselectVideos selectVideos;

+(void)getVideos:(BlockselectVideos)blcSelect copyFile:(NSInteger)copyFile showimg:(BOOL)showimg justOne:(BOOL)justOne showVideo:(BOOL)showAudio;

+(void)getVideosFastPhoto:(BlockselectVideos)blcSelect copyFile:(NSInteger)copyFile showimg:(BOOL)showimg justOne:(BOOL)justOne showVideo:(BOOL)showVideo;
+(void)removeSelf;
@end
