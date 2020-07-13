//
//  QKGPUMovieExportSession.h
//  IPRecordCameraSDK
//
//  Created by yang on 2018/6/22.
//  Copyright © 2018年 ReNew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QKMovieClipController.h"
#import "QKClipsMovie.h"
#import "GPUTransferAndSubTitleView.h"


@interface QKGPUMovieExportSession : NSObject
-(id)init:(NSString *)v_strSavePath  progress:(GetProgress)progress  state:(GetChangeState)state width:(double)width height:(double)height array:(NSArray*)array_movies gpuview:(GPUTransferAndSubTitleView *)gpuview;
-(void)startEncode;
-(void)cancelClipAvasset;


//修改原始声音大小，建议设置值 0～1之间。可以超过1，超过即放大音量
-(void)setOrgSoundValue:(float)value;
//修改背景声音大小，建议设置值 0～1之间。可以超过1，超过即放大音量
-(void)setBackSoundValue:(float)value;
//修改配音声音大小，建议设置值 0～1之间。可以超过1，超过即放大音量
-(void)setRecordValue:(float)value;
//设置背景音地址
-(void)setBackgroundAudio:(NSString*)path;
//关闭背景音
-(void)closeBackgroundAudio;
//设置配音地址
-(void)setRecordAudio:(NSString*)path;
//取消配音地址
-(void)closeRecordAudio;


-(void)changeBrightness:(CGFloat)brightness; //亮度-1~1 0是正常色
-(void)changeContrast:(CGFloat)contrast;    //对比度 0.0 to 4.0 1.0是正常色
-(void)changeSaturation:(CGFloat)saturation;    //饱和度  0.0  to 2.0 1是正常色
-(void)changeSharpness:(CGFloat)sharpness;    //锐度 -4.0 to 4.0, with 0.0 是正常色
-(void)changeHue:(CGFloat)hue;    //设置色调 0 ~ 360 0.0 是正常色
@end

@interface ImageBuffer : NSObject
@property CVPixelBufferRef pixelBuffer;
@property CMTime time;
@end
