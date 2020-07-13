//
//  ShortMovieFinish.m
//  QukanTool
//
//  Created by yang on 17/6/22.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "ShortMovieFinish.h"
#import <AVFoundation/AVFoundation.h>
#import "PubBundle.h"
@interface ShortMovieFinish ()

@property(strong,nonatomic) IBOutlet UIView *v_player;
@property(strong,nonatomic) AVPlayer *player;
@property(strong,nonatomic) IBOutlet UILabel *lbl_startTime;
@property(strong,nonatomic) IBOutlet UILabel *lbl_allTime;
@property(strong,nonatomic) IBOutlet UISlider *sld_time;

@property(strong,nonatomic) IBOutlet UIButton *btn_play;
@property(strong,nonatomic) IBOutlet UIButton *btn_complete;



@property(strong,nonatomic) AVAsset *asset;

@property(strong,nonatomic) NSTimer *playtimer;
@property BOOL isPause;
@property BOOL playEnd;
@end

@implementation ShortMovieFinish
-(void)loadView{
    // Initialization code
    [[[PubBundle bundle]  loadNibNamed:@"ShortMovieFinish" owner:self options:nil] lastObject];

}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//按下home键时候触发
- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self stopAvplayer];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.btn_complete.layer.cornerRadius = 4;

    _asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.address]];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:_asset];
    self.player = [[AVPlayer alloc]initWithPlayerItem:playerItem];
    
    float allWidth = [[UIScreen mainScreen] bounds].size.width;
    float allHeight = [[UIScreen mainScreen] bounds].size.height;
    float safeTop = 20;
    float safeBottom = 0;
    // iPhone X以上设备iOS版本一定是11.0以上。
    if (@available(iOS 11.0, *)) {
        // 利用safeAreaInsets.bottom > 0.0来判断是否是iPhone X以上设备。
        UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
        if (window.safeAreaInsets.bottom > 0.0) {
            safeTop = window.safeAreaInsets.top;
            safeBottom = window.safeAreaInsets.bottom;
        }
    }


    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = CGRectMake(0, 0, allWidth, allHeight - 90 - 35 - safeTop - safeBottom);
    [self playAvplayer];
    [self.v_player.layer insertSublayer:playerLayer atIndex:0];
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(playerItemDidReachEnd:)
     
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
     
                                               object:playerItem];
    
    CGFloat duration = _asset.duration.value *1.0 / _asset.duration.timescale; //视频总时间
    self.lbl_allTime.text = [self timeToString:duration];
    
    [self.sld_time setMinimumValue:0];
    [self.sld_time setMaximumValue:duration];
    
    [self.sld_time setThumbImage:[UIImage imageNamed:@"qktool_selectslider"  inBundle:[PubBundle bundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.sld_time setThumbImage:[UIImage imageNamed:@"qktool_selectslider"  inBundle:[PubBundle bundle] compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)finish:(id)sender{
    [self.btn_play setBackgroundImage:[UIImage imageNamed:@"qktool_shortmovie_play"  inBundle:[PubBundle bundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.player pause];
    self.isPause = YES;
    [self stopPlayTimer];
    [self.navigationController popViewControllerAnimated:YES];

}

-(IBAction)playOrPause:(id)sender{
    if(self.isPause){
        [self playAvplayer];
    }else{
        [self stopAvplayer];
    }
}

-(IBAction)changeTime:(id)sender{
    [self stopAvplayer];
    [self.player seekToTime:CMTimeMakeWithSeconds(self.sld_time.value,200) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    self.lbl_startTime.text = [self timeToString:self.sld_time.value];

}

//播放器播放结束的回调
- (void)playerItemDidReachEnd:(NSNotification *)notify {

    [self.btn_play setBackgroundImage:[UIImage imageNamed:@"qktool_shortmovie_play"  inBundle:[PubBundle bundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.isPause = YES;
    self.playEnd = YES;
    NSLog(@"playerItemDidReachEnd");
}


-(void)playAvplayer{
    NSLog(@"playAvplayer");
    if(self.playEnd){
        [self.player seekToTime:CMTimeMakeWithSeconds(0,200) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        self.playEnd = NO;
    }
    [self.btn_play setBackgroundImage:[UIImage imageNamed:@"qktool_shortmovie_pause"  inBundle:[PubBundle bundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    [self.player play];
    [self startPlayTimer];
    self.isPause = NO;
    
}

-(void)stopAvplayer{
    
    [self.btn_play setBackgroundImage:[UIImage imageNamed:@"qktool_shortmovie_play"  inBundle:[PubBundle bundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.player pause];
    self.isPause = YES;
    [self stopPlayTimer];
}
//开始监听时间的定时器
-(void)startPlayTimer{
    if(self.playtimer != nil && [self.playtimer isValid]){
        return;
    }
    CGFloat duration = _asset.duration.value / _asset.duration.timescale; //视频总时间
    double betweentime = duration / 120;
    if(betweentime > 1){
        betweentime = 1;
    }
    
    if(betweentime < 0.1){
        betweentime = 0.1;
    }
    
    
    self.playtimer =
    [NSTimer scheduledTimerWithTimeInterval:betweentime
                                     target:self
                                   selector:@selector(dealTime)
                                   userInfo:nil
                                    repeats:YES];
}
//结束监听时间的定时器
-(void)stopPlayTimer{
    if(self.playtimer != nil && [self.playtimer isValid]){
        [self.playtimer invalidate];
        self.playtimer = nil;
    }
}

-(void)dealTime{
    //    BOOL isPause = [self.iosplay getPauseState];
    CMTime ctime = self.player.currentTime;
    double currentTimeSec = ctime.value * 1.0 /ctime.timescale;

    self.sld_time.value = currentTimeSec;
    self.lbl_startTime.text = [self timeToString:currentTimeSec];
}


-(NSString*)timeToString:(NSInteger)time{
    NSInteger second = time % 60;
    NSInteger min = time/60%60;
    NSInteger hour = time/3600;
    
    NSString *str_second = [NSString stringWithFormat:@"%ld",second];
    if(second<10){
        str_second = [NSString stringWithFormat:@"0%ld",second];
    }
    NSString *str_min = [NSString stringWithFormat:@"%ld",min];
    if(min<10){
        str_min = [NSString stringWithFormat:@"0%ld",min];
    }
    NSString *str_hour = [NSString stringWithFormat:@"%ld",hour];
    if(hour<10){
        str_hour = [NSString stringWithFormat:@"0%ld",hour];
    }
    return [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_min,str_second];
}



@end
