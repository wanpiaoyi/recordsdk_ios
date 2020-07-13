//
//  ChooseFirstImage.m
//  QukanTool
//
//  Created by yang on 2018/1/11.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "ChooseFirstImage.h"
#import <QKLiveAndRecord/QKLocalFilePlayer.h>
#import <QKLiveAndRecord/QKPlayerFileInfo.h>
#import "MoviesPartImgs.h"
#import "QKMoviePart.h"
#import "QKShowMovieSuntitle.h"
#import "ClipReckon.h"

@interface ChooseFirstImage ()


@property(strong,nonatomic) QKLocalFilePlayer *iosplay;
@property(strong,nonatomic) MoviesPartImgs *moviesPart;
//播放器界面
@property(strong,nonatomic) IBOutlet UIView *v_playviews;
//时间
@property(strong,nonatomic) IBOutlet UILabel *lbl_time;
//预览帧
@property(strong,nonatomic) IBOutlet UIView *v_imgs;
//设置封面
@property(strong,nonatomic) IBOutlet UIButton *btn_choose;
@property(strong,nonatomic) IBOutlet UIButton *btn_cancel;
@property(strong,nonatomic) IBOutlet UIImageView *img_video;
@property(strong,nonatomic) IBOutlet UIButton *btn_play;
@property(strong,nonatomic) NSTimer *playtimer;//播放器状态持续更新的定时器

@property double allLength;
@end

@implementation ChooseFirstImage
-(void)dealloc{
    [self stopPlayer];
}
-(void)loadView{
    
    [[[clipPubthings clipBundle]  loadNibNamed:@"ChooseFirstImage" owner:self options:nil] lastObject];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self pauseIosPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//按下home键时候触发
- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self pauseIosPlayer];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];

     }else{
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
     }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)  name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.btn_choose.layer.cornerRadius = 4.0;
    self.btn_cancel.layer.cornerRadius = 4.0;
    self.moviesPart = [[MoviesPartImgs alloc] initWithFrame:CGRectMake(0, 30, qk_screen_width, audioRecorderView_frameHeight) backGroundImage:nil];
    [self.v_imgs addSubview:self.moviesPart];
    [self.moviesPart changeMovies:self.array_movies];
    
    WS(weakSelf);
    [self.moviesPart setChangeTime:^(double time) {
        [weakSelf pauseIosPlayer];
        [weakSelf seekToTime:time];
        weakSelf.lbl_time.text = [weakSelf timeToString:time];
    }];
    [self showNewPlayer:self.array_movies];
    if(self.nowImg != nil){
        self.img_video.image = self.nowImg;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 播放器的Action

//开始播放
-(IBAction)play:(id)sender{
    [self playIosPlayer];
}
//暂停
-(IBAction)pausePlayer:(id)sender{
    [self pauseIosPlayer];
}

-(void)seekToTime:(double)time{
    [self.iosplay seekToTime:time];
}

#pragma mark - 播放器显示画面
-(void)showNewPlayer:(NSArray*)array{
    @synchronized (self) {
        
        if(array == nil || array.count == 0){
            return;
        }
        if(self.iosplay != nil){
            QKLocalFilePlayer *iosplay = self.iosplay;
            [self.iosplay.view removeFromSuperview];
            self.iosplay = nil;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [iosplay stopPlayer];
            });
        }
        
        
        double seekToTime = 0;
        NSMutableArray *array_playInfos = [[NSMutableArray alloc] init];
        double startTime = 0;
        for(int i =0;i<array.count;i++){
            QKMoviePart *moviePart = array[i];

            QKPlayerFileInfo *qk = [[QKPlayerFileInfo alloc] init];
      
            qk.softStartTime = moviePart.movieStartTime;
            qk.softEndTime = moviePart.movieEndTime;
            
            qk.startTime = startTime;
            qk.endTime = startTime + qk.softEndTime - qk.softStartTime;
            startTime = qk.endTime;
            const char *part = (char*)[moviePart.filePath UTF8String];
            qk.length = strlen(part);
            qk.pcFilePath = part;
            qk.strFilePath = moviePart.filePath;
            qk.type = moviePart.transfer.type;
            qk.isImage = moviePart.isImage;
            qk.width = moviePart.width;
            qk.height = moviePart.height;
            [array_playInfos addObject:qk];
        }
        double scale = 1;
        QKMoviePart *moviePart = array[0];
        
        if(moviePart.isImage){
            scale = moviePart.width/moviePart.height;
        }else{
            scale = [moviePart.data getMovieScale];
        }
        CGRect rect = [ClipReckon reckonRect:CGSizeMake(qk_screen_width, self.v_playviews.frame.size.height) drawType:self.drawType];
        self.allLength = startTime;

        
        self.iosplay = [[QKLocalFilePlayer alloc] init:rect];
        [self.iosplay.view setContentMode:UIViewContentModeScaleAspectFit];
        [self.v_playviews insertSubview:self.iosplay.view atIndex:0];
        [self.iosplay setLocalFiles:array_playInfos];
        [self.iosplay startPlayerWithTime:seekToTime];
        
        
        [self startPlayTimer];
    }
}
//开始播放
-(void)playIosPlayer{
    [self startPlayTimer];
    
    double currentTimeSec = [self.iosplay getCurrentTime];
    

    if(self.iosplay.isPlayerEnd){
        [self.iosplay seekToTimeSync:0];
    }
    [self.iosplay pause:NO];
    self.btn_play.hidden = YES;
}
//暂停
-(void)pauseIosPlayer{
    [self stopPlayTimer];
    [self.iosplay pause:YES];
    self.btn_play.hidden = NO;
}
//结束并释放播放器
-(void)stopPlayer{
    [self stopPlayTimer];
    QKLocalFilePlayer *iosplay = self.iosplay;
    [self.iosplay.view removeFromSuperview];
    self.iosplay = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [iosplay stopPlayer];
    });
    self.btn_play.hidden = YES;
}

//开始监听时间的定时器
-(void)startPlayTimer{
    if(self.playtimer != nil && [self.playtimer isValid]){
        return;
    }
    double betweentime = 0.1;
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
//播放器播放时间显示
-(void)dealTime{
    if(self.iosplay == nil){
        [self stopPlayTimer];
        return;
    }
    //    BOOL isPause = [self.iosplay getPauseState];
    double currentTimeSec = [self.iosplay getCurrentTime];

    if(self.iosplay.isPlayerEnd){
        if(self.iosplay.isPlayerEnd){
            currentTimeSec = self.allLength;
            self.btn_play.hidden = NO;
        }else{
            [self pauseIosPlayer];
        }
    }
    [self.moviesPart setNowPlayTime:currentTimeSec];
    self.lbl_time.text = [self timeToString:currentTimeSec];
}
#pragma mark - 获取封面图
//获取封面图
-(IBAction)getVideoImage:(id)sender{
    if(self.iosplay == nil){
        return;
    }
    [self pauseIosPlayer];
    UIImage *img = [self.iosplay thumbnailImageAtCurrentTime];
    self.img_video.image = img;
    chooseImg choose = self.choose;
    if(choose){
        choose(img);
    }
    [pgToast setText:@"封面设置成功"];
}

//取消封面
-(IBAction)cancelVideoImage:(id)sender{
    self.img_video.image = nil;
    chooseImg choose = self.choose;
    if(choose){
        choose(nil);
    }
    [pgToast setText:@"封面已取消"];
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
