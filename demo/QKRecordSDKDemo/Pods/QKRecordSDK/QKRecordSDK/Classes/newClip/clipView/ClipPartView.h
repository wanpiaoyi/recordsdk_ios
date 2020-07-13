//
//  ClipPartView.h
//  QukanTool
//
//  Created by yang on 2018/6/15.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayController.h"
#import "QKMoviePart.h"
typedef void (^MovieCutPart)(QKMoviePart*part,double time);
@interface ClipPartView : UIView

@property(copy,nonatomic) MovieCutPart cutPart;


- (id)initWithFrame:(CGRect)frame playControl:(ChangePlayerControl)playControl closeView:(closeEdictView)closeView;

-(void)showMoviePart:(QKMoviePart *)part;
-(void)insertSubTitle:(QKMoviePart *)part;
-(void)addSubTitle:(QKMoviePart *)part;

-(void)setSelectIndex:(NSInteger)index;

//当前播放器预览画面预览的时间，然后在当前的裁剪列表中增加遮盖层表示正在预览该片段
-(void)showSelectTile:(double)time;
-(void)setNowPlayTime:(double)time;


//视频帧剪辑界面控制
-(void)changeTime:(double)time;
-(double)getClipStartTime;
-(double)getClipEndTime;
-(double)getPlayStartTime;
-(double)getPlayEndTime;
@end
