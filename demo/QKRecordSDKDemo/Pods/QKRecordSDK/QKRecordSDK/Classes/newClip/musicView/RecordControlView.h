//
//  RecordControlView.h
//  QukanTool
//
//  Created by yang on 2017/12/12.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayController.h"
#import "QKAudioBean.h"
#import "PlayController.h"
//录音时候，不能做任何事情的回调
typedef void (^CanNotDoAnythings)(BOOL notDothings);

@class RecordInfoController;

@interface RecordControlView : UIView

//音量改变，或者添加新的背景音、添加配音时候的回调，通知播放器添加这些元素
@property(copy,nonatomic) ChangeAudioControl audioControl;
//控制播放器开始和结束的泪
@property(copy,nonatomic) ChangePlayerControl playControl;
//在界面上增加遮盖层，用户用户配音的时候，不能进行暂停等操作
@property(copy,nonatomic) CanNotDoAnythings notDoThings;
@property(copy,nonatomic) closeEdictView closeView;


//初始化方法，请传入RecordInfoController
-(instancetype)initWithFrame:(CGRect)frame control:(RecordInfoController*)recordControl;
//yes:在录音  NO：不在录音
-(BOOL)getRecordState;
//设置当前播放时间
-(void)setNowPlayTime:(double)nowTime;
//改变轨道上面的音频遮盖片段
-(void)changeMovies;
-(RecordInfoController*)getRecordInfo:(RecordInfoController*)info;

@end
