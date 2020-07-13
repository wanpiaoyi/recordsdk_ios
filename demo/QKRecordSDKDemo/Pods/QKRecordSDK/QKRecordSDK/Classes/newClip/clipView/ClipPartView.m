//
//  ClipPartView.m
//  QukanTool
//
//  Created by yang on 2018/6/15.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "ClipPartView.h"
#import "RawPartImages.h"
#import <QKLiveAndRecord/QKMovieClipController.h>
#import "MovieClipDataBase.h"
#import "RawSpeedChoose.h"
#import "ClipPubThings.h"

@interface ClipPartView()

@property(copy,nonatomic) ChangePlayerControl playControl; //控制播放器的状态
@property(copy,nonatomic) closeEdictView closeView;


@property(strong,nonatomic) RawPartImages *ramovieImages;
@property(strong,nonatomic) IBOutlet UIView *v_ramovieImages;


@property(strong,nonatomic) RawSpeedChoose *speedChoose;
@property(strong,nonatomic) IBOutlet UIView *v_speedChoose;
@property(strong,nonatomic) IBOutlet UIButton *btn_sure;

@property(strong,nonatomic) IBOutlet UIView *v_delete;
@property(strong,nonatomic) IBOutlet UIView *v_deleteMain;

@property(strong,nonatomic) IBOutlet UILabel *lbl_delete;


@property(strong,nonatomic) QKMoviePart *clipPart;
@property(nonatomic) CloseViewType closeType;

@property double nowTime;

@end

@implementation ClipPartView

-(instancetype)initWithFrame:(CGRect)frame playControl:(ChangePlayerControl)playControl closeView:(closeEdictView)closeView{
    self = [super initWithFrame:frame];
    if(self){
        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"ClipPartView1" owner:self options:nil];
        UIView *v_addName = [array firstObject];
        v_addName.frame = self.bounds;
        [self addSubview:v_addName];
        self.backgroundColor = [UIColor clearColor];
        self.closeView = closeView;
        self.playControl = playControl;
        self.speedChoose = [[RawSpeedChoose alloc] initWithFrame: [self.v_speedChoose bounds]];
        WS(weakSelf);
        [self.speedChoose setChangeSpeed:^(int speedType) {
            weakSelf.clipPart.speedType = speedType;
            [weakSelf.ramovieImages changeSpeed:weakSelf.clipPart.speed];
            if(weakSelf.playControl){
                weakSelf.playControl(PlayerControlSpeedChange, weakSelf.clipPart.speed);
            }
            [weakSelf.ramovieImages setNowPlayTime:0];
        }];
        [self.v_speedChoose addSubview:self.speedChoose];
        [self.btn_sure setTitleColor:clipPubthings.color forState:UIControlStateNormal];
        self.v_delete =  [array lastObject];
        self.v_deleteMain.layer.cornerRadius = 2.0;
    }
    return self;
}

-(IBAction)CutMoviePart:(id)sender{
    double softTime = self.nowTime * self.clipPart.speed;

    if(softTime > [self getClipEndTime]||softTime < [self getClipStartTime]){
        [pgToast setText:@"裁剪时间点必须在开始时间与结束时间中间"];
        return;
    }
    
    if(self.cutPart){
        self.cutPart(self.clipPart, softTime);
    }
    self.closeType = CloseViewTypeCut;
    [self finishView:nil];
}

-(void)showMoviePart:(QKMoviePart *)part{
    self.nowTime = 0;
    self.closeType = CloseViewTypeNormal;
    self.clipPart = part;
    QKMoviePart *moviePart = part;
    if(self.ramovieImages == nil){
        self.ramovieImages = [[RawPartImages alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 105)];
        [self.v_ramovieImages addSubview:self.ramovieImages];
    }
    //清空现有图片
    if(self.ramovieImages != nil){
        [self.ramovieImages clearGetImages];
    }
    [self.ramovieImages changeSpeed:part.speed];
    if(moviePart.isImage){
        self.speedChoose.canChangeSpeed = NO;
        self.ramovieImages.canChangeStartTime = NO;
        self.ramovieImages.minTime = 0.2;
    }else{
        self.speedChoose.canChangeSpeed = YES;
        self.ramovieImages.canChangeStartTime = YES;
        self.ramovieImages.minTime = 3;
    }
    
    QKMovieClipController *qkMovieClip = [[QKMovieClipController alloc] init];
    [qkMovieClip setMovieUrl:[moviePart getOrgPath]];
    __weak __typeof(&*self) weakSelf = self;
    
    
    [self.ramovieImages setSelTime:^(double selectTime,BOOL isEnd){
        if(weakSelf.playControl){
            weakSelf.playControl(PlayerControlSeek, selectTime/weakSelf.clipPart.speed);
        }
        weakSelf.clipPart.movieStartTime = [weakSelf.ramovieImages getClipStartTime];
        weakSelf.clipPart.movieEndTime = [weakSelf.ramovieImages getClipEndTime];
        weakSelf.clipPart.data.clipStartTime = weakSelf.clipPart.movieStartTime;
        
        weakSelf.closeType = CloseViewTypeTimeChanges;

    }];
    [self.ramovieImages getImageFromAvAsset:qkMovieClip startTime:0 endTime:moviePart.allDuring];
    [self.ramovieImages changeStartTime:moviePart.movieStartTime];
    
    [self.ramovieImages changeEndTime:moviePart.movieEndTime];
    
    [self.speedChoose showNowSpeed:part.speedType];
}

-(IBAction)changeOrientation:(id)sender{
    //0 不旋转 1 90，2 180，3 270
    self.clipPart.orientation = self.clipPart.orientation + 1;
    [clipData changeUseOrientation:self.clipPart.orientation];
}

//删除视频
-(IBAction)deleteVideo:(id)sender{
    if(clipData.getMovies.count == 1){
        [pgToast setText:@"请保留至少一个文件"];
        return;
    }
    if(self.clipPart != nil){
        self.lbl_delete.text = @"确认删除该视频吗？";
        self.v_delete.frame = CGRectMake(0, 0, clipPubthings.allWidth, clipPubthings.allHeight);
        [clipPubthings.window addSubview:self.v_delete];
    }else{
        [pgToast setText:@"没有选中任何视频"];
    }
}
-(IBAction)deleteView:(id)sender{
    [self.v_delete removeFromSuperview];
}

-(IBAction)sureView:(id)sender{
    [self.v_delete removeFromSuperview];
    [pgToast setText:@"视频移除成功"];
    [self.ramovieImages removeFromSuperview];
    self.ramovieImages = nil;
    if(self.playControl){
        self.playControl(PlayerControlDel, 0);
    }
    self.clipPart = nil;
    if(self.closeView){
        self.closeView(CloseViewTypeDelete);
    }
    [self removeFromSuperview];
}


-(IBAction)finishView:(id)sender{
    if(self.closeView){
        self.closeView(self.closeType);
    }
    [self removeFromSuperview];
}

#pragma mark - 视频帧剪辑的

-(double)getClipStartTime{
    return [self.ramovieImages getClipStartTime];
}

-(double)getClipEndTime{
    return [self.ramovieImages getClipEndTime];
}
-(double)getPlayStartTime{
    return [self.ramovieImages getPlayStartTime];
}

-(double)getPlayEndTime{
    return [self.ramovieImages getPlayEndTime];
}
-(void)setNowPlayTime:(double)time{
    self.nowTime = time;
    [self.ramovieImages setNowPlayTime:time];
}

@end
