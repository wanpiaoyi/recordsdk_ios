//
//  SubTitleShowAnimationView.h
//  QukanTool
//
//  Created by yang on 2017/12/21.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QKShowMovieSuntitle.h"
#import <QKLiveAndRecord/GPUTransferAndSubTitleView.h>
@class QKMoviePart;
@interface SubTitleShowAnimationView : GPUTransferAndSubTitleView

//添加一个字幕文件
-(void)addSubTitle:(QKShowMovieSuntitle *)qk;

//播放器时间改变的时候，同步修改字幕显示，currentTimeSec当前播放器的时间，isPause：当前是否暂停
-(void)setNowPlayTime:(double)currentTimeSec ispause:(BOOL)isPause;

//修改当前的视频片段的时候，要对应调整字幕的显示
-(void)changeMovieParts:(NSArray *)movies;

-(void)changeCutPart:(QKMoviePart *)oldPart newPart:(QKMoviePart *)newPart  movies:(NSArray *)movies;

//获取所有的字幕文件，用于重新添加到新的预览类中，Array中的对象为QKShowMovieSuntitle
-(NSArray *)getAllSubTitles;

//外面更改了frame时候调用
-(void)changeFramed;
//清空以前的元素
-(void)clearAllSubTitles;

-(void)hidAllSubTitle;


@end
