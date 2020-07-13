//
//  QKMovieClipController.h
//  ClipMovie
//
//  Created by yang on 16/12/7.
//  Copyright © 2016年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSInteger,ChangeState) {
    ChangeStateNomal = 0,
    ChangeStateFinish = 1,
    ChangeStateCancel = 2,
    ChangeStateError = 3,
    ChangeStateUnknown = 4,
    ChangeStateErrorAppkey = 5
};


//img 返回的图片，time：图片对应的时间
typedef void (^GetImageFromMovie)(UIImage *img ,double time);
typedef void (^GetProgress)(double progress);
typedef void (^GetChangeState)(ChangeState state,NSError *error);

@interface QKMovieClipController : NSObject

//设置文件地址
-(void)setMovieUrl:(NSString*)address;

/*
 从视频中获取文件截图
 count：截图数量
 startTime：开始时间
 endTime：截止时间
 callbacl：获取到图片的返回
 
 */
-(void)getImagesFromMovie:(NSInteger)count startTime:(double)startTime endTime:(double)endTime getImageCallback:(GetImageFromMovie)getImg;
//取消获取图片
-(void)cancelGetImage;
//裁剪
-(void)performWithStartSecond:(Float64)startSecond andEndSecond:(Float64)endSecond outputUrl:(NSString *)outputUrl progress:(GetProgress)progress state:(GetChangeState)state;
-(void)cancelClipAvasset;
//合并
- (void)videosSave:(NSArray*)array_address url:(NSString*)outputUrl progress:(GetProgress)progress state:(GetChangeState)state;
-(void)cancelHebing;
//- (void)videoSave:(NSArray*)array_assets url:(NSURL*)url progress:(GetProgress)progress state:(GetChangeState)state;
+(NSInteger)mp4ToH264:(char*)inputFile outputPath:(char*)outputPath;
@end
