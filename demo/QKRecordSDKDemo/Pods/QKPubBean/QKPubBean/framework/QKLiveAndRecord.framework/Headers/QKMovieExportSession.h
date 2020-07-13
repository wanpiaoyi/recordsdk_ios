//
//  QKMovieExportSession.h
//  IPRecordCameraSDK
//
//  Created by yang on 17/6/29.
//  Copyright © 2017年 ReNew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QKMovieClipController.h"
#import "QKClipsMovie.h"
@protocol QkLocalMoviesExportSessionDelegate;

@protocol QkLocalMoviesExportSessionDelegate <NSObject>

- (CVPixelBufferRef)exportSession:(CMSampleBufferRef )sampleBuffer withPresentationTime:(CMTime)presentationTime orientation:(int)orientation;

@end

@interface QKMovieExportSession : NSObject
-(void)performWithOutputUrl:(NSString *)v_strSavePath  progress:(GetProgress)progress  state:(GetChangeState)state width:(double)width height:(double)height array:(NSArray*)array delegate:(id<QkLocalMoviesExportSessionDelegate>)delegate;
-(void)cancelClipAvasset;
//设置原声音量
-(void)changeOrgSoundValue:(float) value;
//设置背景音量
-(void)changeBackSoundValue:(float) value;
//设置配音音量
-(void)changeRecordSoundValue:(float) value;

-(void)setBackgroundAudio:(NSString*)path;
-(void)closeBackgroundAudio;

//设置配音地址
-(void)setRecordAudio:(NSString*)path;
-(void)closeRecordAudio;
@end
