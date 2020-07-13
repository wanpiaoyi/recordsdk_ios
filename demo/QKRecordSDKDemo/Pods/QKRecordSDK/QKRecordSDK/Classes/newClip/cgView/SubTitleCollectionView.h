//
//  SubTitleCollectionView.h
//  QukanTool
//
//  Created by yang on 2017/12/21.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClipPubThings.h"
#import "QKShowMovieSuntitle.h"
#import "PlayController.h"

typedef void (^selectOneSubTitle)(QKShowMovieSuntitle *qk);

@interface SubTitleCollectionView : UIView
//选中一个字幕文件时候调用的回调
@property(copy,nonatomic) selectOneSubTitle selectOne;
//会触发的对播放器的控制，主要用于拖动时间轴的时候，播放器界面跟着改动
@property(copy,nonatomic) ChangePlayerControl playControl;
@property(copy,nonatomic) closeEdictView closeView;
//arrayMovies:视频片段
-(instancetype)initWithFrame:(CGRect)frame array:(NSArray*)arrayMovies;
//视频改动的时候，要修改
-(void)changeArrayMovies:(NSArray*)array;
-(void)addSubTitleSign:(NSArray*)array;
//设置当前播放的时间进度
-(void)setNowPlayTime:(double)nowTime;

@end
