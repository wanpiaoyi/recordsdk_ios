//
//  QKClipController.m
//  QukanTool
//
//  Created by yang on 2018/6/14.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "QKClipController.h"
#import "MovieClipDataBase.h"
#import "MoviePartCollection.h"
#import "MovieChooseTransfer.h"
#import "ClipPartView.h"
#import "SubTitleCollectionView.h"
#import "SubTitleShowAnimationView.h"
#import "RecordControlView.h"
#import "RecordInfoController.h"
#import "ChangeFilterColor.h"

#import "FilterChooseView.h"
#import "SubTitlesSql.h"
#import <QKLiveAndRecord/QKGPUMovieExportSession.h>
#import <QKLiveAndRecord/QKPlayerFileInfo.h>
#import "ShortMovieFinish.h"
#import "ChooseFirstImage.h"
#import "QKVideoBean.h"
#import "AddressSqlite.h"
#import "MBProgressHUD.h"
#import "QukanAlert.h"

@interface QKClipController ()

@property(strong,nonatomic) IBOutlet UIView *v_top;
@property(strong,nonatomic) IBOutlet UIView *v_player;
@property(strong,nonatomic) IBOutlet UIView *v_movies;
@property(strong,nonatomic) IBOutlet UIView *v_bottom;

@property(nonatomic) DrawType drawType;

@property(strong,nonatomic) UIImage *img_fengmian;


//视频列表
@property(strong,nonatomic) MoviePartCollection *collect_clip;
//转场动画
@property(strong,nonatomic) MovieChooseTransfer *transfer; //转场动画的类
//视频裁剪的界面
@property(strong,nonatomic) ClipPartView *clipMovie;
//字幕所在界面
@property(strong,nonatomic) SubTitleCollectionView *subTitle;
//字幕动画控制界面
@property(strong,nonatomic) SubTitleShowAnimationView *subPlayView;
//配音、背景音调节的界面
@property(strong,nonatomic) RecordControlView *recordView;
//音乐数据管理类
@property(strong,nonatomic) RecordInfoController *recordInfo;
//滤镜选择页面
@property(strong,nonatomic) FilterChooseView *filterView;
//调色的页面
@property(strong,nonatomic) ChangeFilterColor *changeColor;

@property(strong,nonatomic) IBOutlet UIButton *btn_play;
@property(strong,nonatomic) IBOutlet UIButton *btn_pause;
@property(strong,nonatomic) IBOutlet UIButton *btn_draw;
@property(strong,nonatomic) NSTimer *playtimer;//播放器状态持续更新的定时器

@property(nonatomic) NSInteger type; //0 预览界面 1 字幕 2 配音 3 调色 4 裁剪
@property(strong,nonatomic) IBOutlet UIButton *btn_recording;

@property(copy,nonatomic) NSString *disPlayname;
@property(strong,nonatomic) QKMoviePartDrafts *movieDrafts;
@property(strong,nonatomic) QKMoviePartDrafts * nowSaveDrafts;



//高清低清保存草稿
@property(strong,nonatomic) IBOutlet UIView *v_submit;

//处理编码视频
@property(strong,nonatomic) IBOutlet UIView *v_encodingVideos;
@property(strong,nonatomic) IBOutlet UIView *v_encodingVideosMain;
@property(strong,nonatomic) IBOutlet UILabel *lbl_progress;
@property(strong,nonatomic) QKGPUMovieExportSession *export;
@property(nonatomic) NSInteger flag1;

@property(strong,nonatomic) IBOutlet UILabel *lbl_scale;

@end

@implementation QKClipController

-(void)loadView{
    
    [[[clipPubthings clipBundle]  loadNibNamed:@"QKClipController" owner:self options:nil] lastObject];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //页面切到后台暂停播放器
    [self pauseIosPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];

     }else{
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
     }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)  name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //状态栏占据位置
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;

}


- (void)applicationDidEnterBackground:(NSNotification *)notification
{   //按下home键时暂停播放器
    [self pauseIosPlayer];
}
#pragma mark - 修改画幅比
-(IBAction)changeDrawType:(id)sender{
    self.drawType = (self.drawType + 1)%5;
    switch (self.drawType) {
        case DrawType1x1:
            [self.btn_draw setImage:[clipPubthings imageNamed:@"qktool_clip_1x1"] forState:UIControlStateNormal];
            self.lbl_scale.text = @"1:1";
            break;
        case DrawType3x4:
            [self.btn_draw setImage:[clipPubthings imageNamed:@"qktool_clip_3x4"] forState:UIControlStateNormal];
            self.lbl_scale.text = @"3:4";
            break;
        case DrawType4x3:
            [self.btn_draw setImage:[clipPubthings imageNamed:@"qktool_clip_4x3"] forState:UIControlStateNormal];
            self.lbl_scale.text = @"4:3";
            break;
        case DrawType9x16:
            [self.btn_draw setImage:[clipPubthings imageNamed:@"qktool_clip_9x16"] forState:UIControlStateNormal];
            self.lbl_scale.text = @"9:16";

            break;
        case DrawType16x9:
            [self.btn_draw setImage:[clipPubthings imageNamed:@"qktool_clip_16x9"] forState:UIControlStateNormal];
            self.lbl_scale.text = @"16:9";
            break;
        default:
            break;
    }
    CGRect rect = [clipData changeDrawType:self.v_player.bounds.size drawType:self.drawType];
    self.subPlayView.frame = rect;
    [self.subPlayView changeFramed];
}

#pragma mark - 结束的时候删除从相册中拷贝出来的文件缓存
-(void)dealloc{
    [self.transfer removeFromSuperview];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];

}

//初始化Controller
-(id)init:(NSMutableArray*)array{
    if(self = [super init]){
        [clipData changeArrayMovies:array];
        self.saveLocalVideo = NO;
    }
    return self;
}

//通过草稿初始化Controller
-(id)initWithDrafts:(QKMoviePartDrafts*)movieDrafts{
    
    if(self = [super init]){
        self.movieDrafts = movieDrafts;
        self.saveLocalVideo = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.v_encodingVideosMain.layer.cornerRadius = 2.0;

    //初始化转场界面
    [self createTransFer];
    //初始化裁剪界面
    [self createClipMovie];
    //初始化列表
    [self createCollectClip];
    //初始化字幕
    [self createSubPlayView];
    //初始调色界面
    [self createFilterColor];

    if(self.movieDrafts != nil){
        [self initwithDrafts];
    }else{
        self.drawType = DrawType16x9;
    }
    self.v_player.frame = CGRectMake(0, self.v_player.frame.origin.y, clipPubthings.screen_width, clipPubthings.screen_height - 130 - 40 - 80);
    UIView *playerView = [clipData getPlayerView:self.v_player.bounds.size drawType:self.drawType];
    [self.v_player insertSubview:playerView atIndex:0];
    
    [clipData createAllPlayer];
    self.type = 0;
    [self playIosPlayer];
    
    self.filterView = [[FilterChooseView alloc] initWithFrame:CGRectMake(40, 30, clipPubthings.screen_width - 80, 20)];
    self.filterView.hidden = YES;
    [self.v_player addSubview:self.filterView];
    
    
//    //添加手势，用于切换滤镜
//    UISwipeGestureRecognizer *recognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
//    [recognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [self.v_player addGestureRecognizer:recognizerRight];
//    
//    UISwipeGestureRecognizer *recognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
//    [recognizerLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
//    [self.v_player addGestureRecognizer:recognizerLeft];
    UIView *v = [clipData getPlayerView:self.v_player.frame.size drawType:self.drawType];
    self.subPlayView.frame = v.frame;
    [self.subPlayView changeFramed];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//手势切换滤镜
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if(self.filterView.isHidden == NO && !clipData.isPreView){

        if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            NSLog(@"swipe left");
            int type = [self.filterView selectNextFilter];
            [clipData changeFilter:type];
        }
        if(recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            NSLog(@"swipe right");
            int type = [self.filterView selectBeforeFilter];
            [clipData changeFilter:type];
        }
    }
}



//录音的时候不能进行其他操作
-(IBAction)showIsRecording:(id)sender{
    [pgToast setText:@"当前正在录音"];
}

/*
 选择封面
 */
-(IBAction)chooseCover:(id)sender{
    [self.collect_clip chooseCover];
}

#pragma mark - 字幕页面
-(void)createSubPlayView{
    if(self.subPlayView == nil){
        self.subPlayView = [[SubTitleShowAnimationView alloc] initWithFrame:[clipData getPlayerViewFrame]];
        self.subPlayView.clipsToBounds = YES;
        //点击手势
        UITapGestureRecognizer *r5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pauseIosPlayer)];
        r5.numberOfTapsRequired = 1;
        [self.subPlayView addGestureRecognizer:r5];
        [self.v_player insertSubview:self.subPlayView belowSubview:self.btn_pause];
    }
}

//创建字幕有关的view
-(void)createSubtitle{
    if(self.subTitle == nil){
        self.subTitle = [[SubTitleCollectionView alloc] initWithFrame:CGRectMake(0,clipPubthings.screen_height - movieEidctHeight, clipPubthings.screen_width, movieEidctHeight)];
        WS(weakSelf);
        [self.subTitle setPlayControl:^(PlayerControl state, double time) {
            switch (state) {
                case PlayerControlStop:
                    [weakSelf stopPlayer];
                    break;
                case PlayerControlSeek:
                        [weakSelf pauseIosPlayer];
                        [weakSelf seekToTime:time];
                    break;
                case PlayerControlPlay:
                    [weakSelf playIosPlayer];
                    break;
                case PlayerControlPause:
                    [weakSelf pauseIosPlayer];
                    break;
                default:
                    break;
            }
        }];
        
        [self.subTitle setSelectOne:^(QKShowMovieSuntitle *qk) {
            [weakSelf pauseIosPlayer];
            //在显示界面中添加一个字幕
            [weakSelf.subPlayView addSubTitle:qk];
            NSLog(@"qk.startTime:%.3lf qk.softStartTime:%.3lf",qk.startTime,qk.softStartTime);
        }];
        
        [self.subTitle setCloseView:^(CloseViewType type) {
            switch (type) {
                case CloseViewTypeNormal:
                    break;
                case CloseViewTypeDelete:
                    break;
                case CloseViewTypeTimeChanges:
                    break;
                default:
                    break;
            }
            [weakSelf endEdictFrame];
        }];
    }
    
}

#pragma mark - tab页切换的点击事件
//点击字幕显示字幕页面
-(IBAction)showSubTitle:(id)sender{
    if(!clipData.isPreView){
        return;
    }
    [self createSubtitle];

    [self.subTitle changeArrayMovies:clipData.getMovies];
    [self.subTitle addSubTitleSign:self.subPlayView.getAllSubTitles];

    [self.subTitle setNowPlayTime:[clipData getCurrentTime]];
    [self.v_maincontroller addSubview:self.subTitle];
    self.type = 1;
    [self changeEdictFrame];
}

//显示调色页面
-(IBAction)showFilterColor:(id)sender{
    [self.v_maincontroller addSubview:self.changeColor];
    self.type = 3;
    [self changeEdictFrame];
}
//显示配音页面
-(IBAction)showRecord:(id)sender{
    [self createRecordView];
    
    double currentTime = [clipData getCurrentTime];
    [self pauseIosPlayer];
    [self.recordView changeMovies];
    [self.recordView setNowPlayTime:currentTime];
    [self.subTitle setNowPlayTime:currentTime];
    [self.v_maincontroller addSubview:self.recordView];
    self.type = 2;
    [self changeEdictFrame];
}


#pragma mark - 配音页面

-(void)createRecordView{
    //声音模块
    if(self.recordView == nil){
        if(self.recordInfo == nil){
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *audioPath = [NSString stringWithFormat:@"%@/%@.pcm",path,[self ret32bitString]];
            self.recordInfo = [[RecordInfoController alloc] init:clipData.getMovies path:audioPath isOld:NO];
            clipData.recordInfo = self.recordInfo;
        }
        
        self.recordView = [[RecordControlView alloc] initWithFrame:CGRectMake(0,clipPubthings.screen_height - movieEidctHeight, clipPubthings.screen_width, movieEidctHeight) control:self.recordInfo];
        WS(weakSelf);
        [self.recordView setAudioControl:^(AudioChange state, double value, NSString *path) {
            switch (state) {
                case AudioChangeOrgValue:
                {
                    [clipData setOrgSoundValue:value];
                }
                    break;
                case AudioChangeBackValue:
                    //正在录音中，将背景音设置为静音
                    if(![weakSelf.recordView getRecordState]){
                        [clipData setBackSoundValue:value];
                    }else{
                        [clipData setBackSoundValue:0];
                    }
                    break;
                case AudioChangeBackPath:
                    [clipData setBackgroundAudio:[NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,path]];
                    break;
                case AudioChangeRecordValue:
                    //正在录音中，将配音设置为静音
                    if(![weakSelf.recordView getRecordState]){
                        [clipData setRecordValue:value];
                    }else{
                        [clipData setRecordValue:0];
                    }
                    break;
                case AudioChangeRecordPath:
                    [clipData setRecordAudio:path];
                    
                    break;
                default:
                    break;
            }
        }];
        [self.recordView setPlayControl:^(PlayerControl state, double time) {
            switch (state) {
                case PlayerControlStop:
                    [weakSelf stopPlayer];
                    break;
                case PlayerControlSeek:
                    [weakSelf pauseIosPlayer];
                    [weakSelf seekToTime:time];
                    break;
                case PlayerControlPlay:
                    [weakSelf playIosPlayer];
                    break;
                case PlayerControlPause:
                    [weakSelf pauseIosPlayer];
                    break;
                default:
                    break;
            }
        }];
        [self.recordView setNotDoThings:^(BOOL notDothings) {
            if(notDothings){
                weakSelf.btn_recording.hidden = NO;
            }else{
                weakSelf.btn_recording.hidden = YES;
            }
        }];
        [self.recordView setCloseView:^(CloseViewType type) {
            switch (type) {
                case CloseViewTypeNormal:
                    break;
                case CloseViewTypeDelete:
                    break;
                case CloseViewTypeTimeChanges:
                    break;
                default:
                    break;
            }
            [weakSelf endEdictFrame];
        }];
    }
}

-(void)createClipMovie{
    WS(weakSelf);
    self.clipMovie = [[ClipPartView alloc] initWithFrame:CGRectMake(0, clipPubthings.screen_height - movieEidctHeight, clipPubthings.screen_width, movieEidctHeight)  playControl:^(PlayerControl state, double time) {
        switch (state) {
    
            case PlayerControlDel:
                [clipData stopPlayer];
            case PlayerControlMove:
            {
                NSLog(@"PlayerControlMove");
            }
                
            case PlayerControlClip:
                break;
            case PlayerControlSeek:
                [weakSelf pauseIosPlayer];
                [weakSelf seekToTime:time];
                break;
            case PlayerControlSpeedChange:
                [weakSelf pauseIosPlayer];

                [clipData changeSpeed:time];

                [weakSelf seekToTime:0];

                [weakSelf.recordInfo changeMovies:clipData.getMovies];

                [weakSelf.subPlayView changeMovieParts:clipData.getMovies];

                break;
            case PlayerControlTransferChange:
                break;
            default:
                break;
        }
    }  closeView:^(CloseViewType type) {
        switch (type) {
            case CloseViewTypeNormal:
                break;
            case CloseViewTypeDelete:
                [clipData removeNowPart];
                [weakSelf.recordInfo changeMovies:clipData.getMovies];
                [weakSelf.subPlayView changeMovieParts:clipData.getMovies];
                break;
            case CloseViewTypeTimeChanges:
                [weakSelf.recordInfo changeMovies:clipData.getMovies];
                [weakSelf.subPlayView changeMovieParts:clipData.getMovies];
                break;
            case CloseViewTypeCut:
                [weakSelf.recordInfo changeMovies:clipData.getMovies];
                [weakSelf.subPlayView changeMovieParts:clipData.getMovies];
                break;
            default:
                break;
        }
        [weakSelf endEdictFrame];
        [weakSelf.collect_clip setSelectIndex:-1];
        [clipData createAllPlayer];
        [weakSelf playIosPlayer];
    }];
    [self.clipMovie setCutPart:^(QKMoviePart *part, double softTime) {
        QKMoviePart *partCut = [clipData setCutPart:part softTime:softTime];
        [weakSelf.subPlayView changeCutPart:part newPart:partCut movies:clipData.getMovies];
        [weakSelf.recordInfo changeCutPart:part.moviePartId newPart:partCut movies:clipData.getMovies];
    }];
}

#pragma mark-调色
-(void)createFilterColor{
    if(self.changeColor == nil){
        self.changeColor = [[ChangeFilterColor alloc] initWithFrame:CGRectMake(0, clipPubthings.screen_height - movieEidctHeight, clipPubthings.screen_width,movieEidctHeight) group:clipData.group];
        WS(weakSelf);
        [self.changeColor setCloseView:^(CloseViewType type) {
            switch (type) {
                case CloseViewTypeNormal:
                    break;
                case CloseViewTypeDelete:
                    break;
                case CloseViewTypeTimeChanges:
                    break;
                default:
                    break;
            }
            [weakSelf endEdictFrame];
        }];
     
        [self.changeColor setChange:^(QKColorFilterGroup *group) {
            [clipData changeColorFilterGroup:group];
        }];
    }
}


//
//-(IBAction)changeFengmian:(id)sender{
//    ChooseFirstImage *choose = [[ChooseFirstImage alloc] init];
//    choose.array_movies = [clipData getMovies];
//    choose.drawType = self.drawType;
//    WS(weakSelf);
//    [choose setChoose:^(UIImage *img) {
//        weakSelf.img_fengmian = img;
//    }];
//    choose.nowImg = self.img_fengmian;
//    [self.navigationController pushViewController:choose animated:YES];
//}


#pragma mark-创建转场动画页面
-(void)createTransFer{
    self.transfer = [[MovieChooseTransfer alloc] initWithFrame:CGRectMake(0, clipPubthings.screen_height - movieEidctHeight, clipPubthings.screen_width,movieEidctHeight)];
    [self.v_maincontroller addSubview:self.transfer];
    self.transfer.hidden = YES;
    /*
     state:0 应用当前选中的  1:应用全部
     type:转场动画：0 没有动画  1:左侧划入 2右侧划入 3:淡出
     */
    WS(weakSelf);
    [self.transfer setChoose:^(NSInteger state,MovieTransfer *transfer,double time) {
        switch (state) {
            case 0:
                [clipData changeTransfers];
                break;
            case 1:
                [clipData changeAllTransfer:transfer];
                break;
            default:
                break;
        }
        [weakSelf.collect_clip.collect reloadData];
        [weakSelf pauseIosPlayer];
        [weakSelf seekToTime:time];
        [weakSelf playIosPlayer];
    }];
    
    [self.transfer setClose:^(CloseViewType type) {
        switch (type) {
            case CloseViewTypeNormal:
                break;
            case CloseViewTypeDelete:
                break;
            case CloseViewTypeTimeChanges:
                break;
            default:
                break;
        }
        [weakSelf endEdictFrame];
    }];
}
#pragma mark-创建视频列表显示的页面
-(void)createCollectClip{
    self.collect_clip = [[MoviePartCollection alloc] initWithFrame:CGRectMake(0, 18,clipPubthings.screen_width, 46) array:[clipData getMovies]];
    WS(weakSelf);
    [self.collect_clip setChoose:^(QKMoviePart *moviePart,NSInteger state){
        if(state == 0){
            [weakSelf showClipsView:moviePart];
        }else if(state == 1){
            double startTime = 0;
            for(int i =0;i<clipData.getMovies.count;i++){
                QKMoviePart *part = clipData.getMovies[i];
                part.beginTime = startTime;
                if(moviePart == part){
                    break;
                }
                startTime = startTime + part.movieDuringTime;
            }
            //点击某个转场动画的效果
            [weakSelf.transfer setMoviePart:moviePart];
            [weakSelf changeEdictFrame];
            weakSelf.transfer.hidden = NO;
        }else if(state == 2){
            //添加视频
            [weakSelf.recordInfo changeMovies:clipData.getMovies];
            [weakSelf.subPlayView changeMovieParts:clipData.getMovies];
            [clipData createAllPlayer];
            [weakSelf playIosPlayer];
        }
    }];
    [self.v_movies insertSubview:self.collect_clip atIndex:0];
    [self.collect_clip setPlayControl:^(PlayerControl state, double time) {
        switch (state) {
            case PlayerControlDel:
                [clipData stopPlayer];
            case PlayerControlMove:
            {
                NSLog(@"PlayerControlMove");
            }
                
            case PlayerControlClip:
                break;
            case PlayerControlSeek:
                [weakSelf pauseIosPlayer];
                [weakSelf seekToTime:time];
                break;
            case PlayerControlPause:
                [weakSelf pauseIosPlayer];
                break;
            case PlayerControlTransferChange:
                break;
            default:
                break;
        }
    }];
}

//点击某个视频的时候，显示单个视频
-(void)showClipsView:(QKMoviePart *)moviePart{
    [self.filterView showFilterType:moviePart.filterType];
    self.filterView.hidden = NO;
    [self changeEdictFrame];
    [self.v_maincontroller addSubview:self.clipMovie];
    [self.clipMovie showMoviePart:moviePart];
    [clipData showOnePart:moviePart];
    [self playIosPlayer];
    [self.subPlayView hidAllSubTitle];
}


//重新计算播放器的大小和位置
-(void)changeEdictFrame{
    self.v_player.frame = CGRectMake(0, 25, clipPubthings.screen_width, clipPubthings.screen_height - movieEidctHeight - 50);
    UIView *v = [clipData getPlayerView:self.v_player.frame.size drawType:self.drawType];
    self.v_top.hidden = YES;
    self.subPlayView.frame = v.frame;
    [self.subPlayView changeFramed];
}

//编辑状态的播放器大小和位置调整
-(void)endEdictFrame{
    self.filterView.hidden = YES;

    self.v_player.frame = CGRectMake(0, 80, clipPubthings.screen_width, self.v_movies.frame.origin.y- 80 - 40);
    UIView *v = [clipData getPlayerView:self.v_player.frame.size drawType:self.drawType];
    self.v_top.hidden = NO;
    self.subPlayView.frame = v.frame;
    [self.subPlayView changeFramed];
    if(clipData.isPreView){
        double currentTimeSec = [clipData getCurrentTime];
        [self.subPlayView setNowPlayTime:currentTimeSec ispause:[clipData getPauseState]];
        [self.collect_clip showSelectTile:currentTimeSec];
    }
}

#pragma mark - 退出
-(IBAction)back:(id)sender{
    if(self.movieDrafts){
        [clipData resetThings:NO];;
    }else{
        [clipData resetThings:YES];;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 完成
-(IBAction)completeVideo:(id)sender{
//    [self stopPlayer];
    [self.v_submit removeFromSuperview];

    UIButton *btn = (UIButton*)sender;
    CGSize size = [self getFitSize:btn.tag];
    
    
    NSMutableArray *array_playInfos = [[NSMutableArray alloc] init];
    double startTime = 0;
    NSArray *array_movies = clipData.getMovies;
    
    NSMutableArray *useArray = [[NSMutableArray alloc] initWithArray:array_movies];
//    if(self.img_fengmian != nil){
//        QKMoviePart *moviePart = useArray[0];
//
//        NSString *path = @"tmp4_1.jpg";
//        NSString *img_path = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,path];
//        NSData *imageData = UIImageJPEGRepresentation(self.img_fengmian, 1.0);
//        [imageData writeToFile:img_path atomically:YES];
//
//        QKVideoBean *bean = [QKVideoBean getVideoByAddress:path];
//        bean.type = selectFromPhotoImg;
//        QKMoviePart *part = [QKMoviePart startWithRecord:bean];
//        part.movieEndTime = 0.05;
//        part.filterType = moviePart.filterType;
//        [useArray insertObject:part atIndex:0];
//    }
    

    
    for(int i =0;i<useArray.count;i++){
        QKMoviePart *moviePart = useArray[i];
        QKPlayerFileInfo *qk = [[QKPlayerFileInfo alloc] init];
        
        qk.softStartTime = moviePart.movieStartTime;
        qk.softEndTime = moviePart.movieEndTime;
        qk.speed = moviePart.speed;
        qk.filterType = moviePart.filterType;
        qk.useOrientation = moviePart.orientation;
        
        qk.startTime = startTime;
        qk.endTime = startTime + (qk.softEndTime - qk.softStartTime)/moviePart.speed;
        startTime = qk.endTime;
        const char *part = (char*)[moviePart.filePath UTF8String];
        qk.length = strlen(part);
        qk.pcFilePath = part;
        qk.strFilePath = moviePart.filePath;
        qk.type = moviePart.transfer.type;
        qk.isImage = moviePart.isImage;
        qk.isTitle = moviePart.isTitle;
        qk.width = moviePart.width;
        qk.height = moviePart.height;
        [array_playInfos addObject:qk];
    }
    
   
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filename = [self getFilename]; //文件名必须唯一，所以更具时间与随机数创建;
    NSString * uploadfileName = filename;
    //给文件名加上后缀如.mov  .mp4之类的
    uploadfileName = [NSString stringWithFormat:@"%@_upload1.%@",filename,@"MP4"];
    filename = [NSString stringWithFormat:@"%@_0.%@",filename,@"MP4"];
    
    
    NSString *filePath= [NSString stringWithFormat:@"%@/%@/%@", clipPubthings.pressfixPath,localRecordType,filename];
    NSString *address = [NSString stringWithFormat:@"%@/%@",localRecordType,filename];
    [fileManager removeItemAtPath:filePath error:nil];
//    NSLog(@"address:%@",address);
    WS(weakSelf);
    QKGPUMovieExportSession *export = [[QKGPUMovieExportSession alloc] init:filePath progress:^(double progress) {
//        NSLog(@"progress:%.2lf",progress);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.lbl_progress.text = [NSString stringWithFormat:@"%.1lf%%",progress*100];
        });
    } state:^(ChangeState state, NSError *error) {
        switch (state) {
            case ChangeStateNomal:
                NSLog(@"裁剪开始");
                break;
            case ChangeStateUnknown:
                break;
            case ChangeStateFinish:
            {
                NSLog(@"EncodeType_Finish");
                NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                      
                                                                 forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
                AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:opts];
                NSString *fileInsertName = [self getLiveuuid];
                
                CMTime assetTime = [myAsset duration];
                NSInteger duration = (NSInteger)CMTimeGetSeconds(assetTime);
                
                
                NSString * uploadfileName = filename;
                NSArray *arr = [filename componentsSeparatedByString:@"."];
                
                NSString *showName = @"测试";;
                
                if(arr.count>1){
                    uploadfileName = [NSString stringWithFormat:@"%@_upload1.%@",arr[0],arr[arr.count-1]];
                }
                
                
                
                //initMultipart 标示是断点续传，以后可能会有其他新的传输模式
//                [ossSynch insertLiveLocal:filename type:@"localvideo" address:address updatefilename:uploadfileName time:(NSInteger)startTime updatetype:@"initMultipart" appendPosition:0 liveendname:fileInsertName];
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    
                    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.v_maincontroller];
                    [self.v_maincontroller addSubview:HUD];
                    
                    HUD.labelText = @"视频导入相册中";
                    
                    //显示对话框
                    [HUD showAnimated:YES whileExecutingBlock:^{
                        //对话框显示时需要执行的操作
                        
                        weakSelf.flag1 = 0;
                        
                        if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filePath))
                        {
                            UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                            
                            while (weakSelf.flag1 == 0)
                            {
                                //RenewTOOL_INFO(@"save waiting ......");
                                
                                usleep(50*1000);
                            }
                            
                        }else
                        {
                            QukanAlert *alert = [[QukanAlert alloc] initWithCotent:@"文件异常,无法导入相册" Delegate:nil] ;
                            [alert show];
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            if(!weakSelf.saveLocalVideo){
                                Boolean removeFile =  [fileManager removeItemAtPath:filePath error:nil];
                                NSLog(@"removeFile:%d",removeFile);
                            }else{
                                if(clipPubthings.completeUrl != nil){
                                    clipPubthings.completeUrl(address);
                                }
                            }
                        }
                        
                    }completionBlock:^{
                        
                        //操作执行完后取消对话框
                        [HUD removeFromSuperview];
                        if(!weakSelf.saveLocalVideo){
                            [fileManager removeItemAtPath:filePath error:nil];
                        }else{
                            if(clipPubthings.completeUrl != nil){
                                clipPubthings.completeUrl(address);
                            }
                        }
                        if(weakSelf.flag1 == -1){
                            [pgToast setText:@"文件导出失败，请检查相册权限是否开启"];
                        }else{
                            [pgToast setFinishText:@"文件导出成功"];
                            if(weakSelf.movieDrafts || clipPubthings.saveDraft != nil){
                                [clipData resetThings:NO];;
                            }else{
                                [clipData resetThings:YES];;
                            }
                            
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                    
                });
                NSLog(@"saveVideo1");
                break;
            }
                
            case ChangeStateError:
                NSLog(@"裁剪出错");
                [weakSelf.export cancelClipAvasset];
                break;
            case ChangeStateErrorAppkey:
                NSLog(@"APPKEY裁剪出错");
                [weakSelf.export cancelClipAvasset];
                break;
            case ChangeStateCancel:
                NSLog(@"人为停止");
                [fileManager removeItemAtPath:filePath error:nil];
                break;
        };
        if(state != ChangeStateNomal){
            weakSelf.export = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.v_encodingVideos removeFromSuperview];
            });
        }
    } width:size.width height:size.height array:array_playInfos gpuview:self.subPlayView];
    
    if(clipData.recordInfo != nil){
        //设置背景音乐等
        QKAudioBean *audio = [self.recordInfo getAudioBean];
        [export setOrgSoundValue:audio.orgVale];
        [export setBackSoundValue:audio.backVale];
        [export setRecordValue:audio.recordVale];
        
        [export setBackgroundAudio:[NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,audio.backMusic]];
        [export setRecordAudio:audio.recordPath];
    }
    if(clipData.group != nil){
        [export changeBrightness:clipData.group.brightness];
        [export changeSaturation:clipData.group.saturation];
        [export changeSharpness:clipData.group.sharpness];
        [export changeContrast:clipData.group.contrast];
        [export changeHue:clipData.group.hue];
    }
    [export startEncode];
    self.export = export;
    self.v_encodingVideos.frame = self.v_maincontroller.bounds;
    
    [self.v_maincontroller addSubview:self.v_encodingVideos];
    [self saveDrafts];

    
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error != nil){
        self.flag1 = -1;
    }else{
        self.flag1 = 1;
    }
    
}
-(IBAction)finish:(id)sender{
    [self pauseIosPlayer];
    self.v_submit.frame = self.v_maincontroller.bounds;
    [self.v_maincontroller addSubview:self.v_submit];
}

-(IBAction)cancelExport:(id)sender{
    [self.v_submit removeFromSuperview];
}

-(IBAction)cancelVideo:(id)sender{
    [self.export cancelClipAvasset];
    if(self.movieDrafts == nil){
        [subsql deleteSql:self.nowSaveDrafts];
        self.nowSaveDrafts = nil;
    }
}

#pragma mark - 保存草稿
-(IBAction)saveToCaogao:(id)sender{
    
    [self saveDrafts];
    [self.recordInfo deleteOldFile];
    [clipData resetThings:NO];;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initwithDrafts{
    NSArray *array_movieParts = self.movieDrafts.dict_save[@"array_movieParts"];
    NSMutableArray *array_parts = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in array_movieParts){
        [array_parts addObject:[QKMoviePart getMoviePartByBean:dict]];
    }
    [clipData changeArrayMovies:array_parts];

    
    NSArray *array_titles = self.movieDrafts.dict_save[@"array_titles"];

    for(NSDictionary *dict in array_titles){
        [self.subPlayView addSubTitle:[QKShowMovieSuntitle getShowMovieSub:dict]];
    }
    
    NSNumber *orgVoice = [self.movieDrafts.dict_save objectForKey:@"orgVoice"];
    NSNumber *backVoice = [self.movieDrafts.dict_save objectForKey:@"backVoice"];
    NSNumber *recordVoice = [self.movieDrafts.dict_save objectForKey:@"recordVoice"];
    NSString *recordPath = [self.movieDrafts.dict_save objectForKey:@"recordPath"];
    NSString *backMusic = [self.movieDrafts.dict_save objectForKey:@"selectMusic"];

    NSNumber *drawType = [self.movieDrafts.dict_save objectForKey:@"drawType"];
    if(drawType != nil){
        self.drawType = [drawType intValue];
        switch (self.drawType) {
            case DrawType1x1:
                [self.btn_draw setImage:[clipPubthings imageNamed:@"qktool_clip_1x1"] forState:UIControlStateNormal];
                break;
            case DrawType3x4:
                [self.btn_draw setImage:[clipPubthings imageNamed:@"qktool_clip_3x4"] forState:UIControlStateNormal];
                break;
            case DrawType4x3:
                [self.btn_draw setImage:[clipPubthings imageNamed:@"qktool_clip_4x3"] forState:UIControlStateNormal];
                break;
            case DrawType9x16:
                [self.btn_draw setImage:[clipPubthings imageNamed:@"qktool_clip_9x16"] forState:UIControlStateNormal];
                break;
            case DrawType16x9:
                [self.btn_draw setImage:[clipPubthings imageNamed:@"qktool_clip_16x9"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
    NSDictionary *group = [self.movieDrafts.dict_save objectForKey:@"filterGroup"];
    [clipData setGroup:[QKColorFilterGroup getFilterGroupByDic:group] ];
    
    NSLog(@"%@",self.movieDrafts.dict_save);
    if(self.recordInfo == nil){
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        BOOL isOld = NO;
        NSString *audioPath = [NSString stringWithFormat:@"%@/%@.pcm",path,[self ret32bitString]];
        if(recordPath != nil && recordPath.length > 0){
            audioPath = [NSString stringWithFormat:@"%@/%@",path,recordPath];
            isOld = YES;
        }
        self.recordInfo = [[RecordInfoController alloc] init:array_parts path:audioPath isOld:isOld];
        [self.recordInfo setMusicPath:backMusic];
        if(orgVoice != nil){
            [self.recordInfo setOrgValue:[orgVoice floatValue]];
        }
        if(backVoice != nil){
            [self.recordInfo setBackValue:[backVoice floatValue]];
        }
        if(recordVoice != nil){
            [self.recordInfo setRecordValue:[recordVoice floatValue]];
        }
        clipData.recordInfo = self.recordInfo;
    }
}

-(void)saveDrafts{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复
    
    [formater setDateFormat:@"MM-dd HH:mm"];
    self.disPlayname = [NSString stringWithFormat:@"短视频_%@",[formater stringFromDate:[NSDate date]]];

    QKMoviePartDrafts * drafts = [[QKMoviePartDrafts alloc] init];
    
    {
        if(self.movieDrafts.img_address != nil&&self.movieDrafts.img_address.length > 0){
            
            NSString *path = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,self.movieDrafts.img_address];
            NSFileManager *fileManager = [[NSFileManager alloc]init];
            
            [fileManager removeItemAtPath:path error:nil];
        }
        
    }
    
    
    
    NSString *img_address = nil;
    
    
    NSMutableArray *array_movieParts = [[NSMutableArray alloc] init];
    NSArray *movie_parts = [clipData getMovies];
    if(self.recordInfo != nil){
        NSArray *array = [self.recordInfo getArray_movies];
        for(int i = 0 ;i < array.count;i++){
            QKMoviePart *part = array[i];
            QKMoviePart *clip = movie_parts[i];
            part.transfer = clip.transfer;
            part.filterType = clip.filterType;
            part.speedType = clip.speedType;
            part.orientation = clip.orientation;
        }
        movie_parts = array;
    }
    for(QKMoviePart *moviePart in movie_parts){
        if(img_address == nil){
            if(moviePart.isImage){
                img_address= [NSString stringWithFormat:@"localImage/%.0lf%d.jpg",[[NSDate date] timeIntervalSince1970],[self getRandomNumber:10000000 to:99999999]];
                NSString *path = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,img_address];
                NSData *data = [NSData dataWithContentsOfFile:[moviePart getOrgPath]];
                [data writeToFile:path atomically:YES];
            }else{
                moviePart.data.type = selectFromPhotoVideo;
                [moviePart.data saveImageAddress];
                img_address = moviePart.data.finish_localImgaddress;
                moviePart.data.finish_localImgaddress = @"";
            }
            
        }
        [array_movieParts addObject:[moviePart getDictionaryByBean]];
    }
    
    NSMutableArray *array_titles = [[NSMutableArray alloc] init];
    NSArray *array = [self.subPlayView getAllSubTitles];
    for(QKShowMovieSuntitle *qkshow in array){
        if(qkshow.isTitle == 0){
            [array_titles addObject:[qkshow getDictionaryByBean]];
        }
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:array_movieParts,@"array_movieParts",array_titles,@"array_titles", nil];
    if(self.recordInfo != nil){
        QKAudioBean *bean = [self.recordInfo getAudioBean];
        if(bean.backMusic != nil){
            [dict setObject:bean.backMusic forKey:@"selectMusic"];
        }
        if(bean.recordPath != nil){
            [dict setObject:[bean getSaveRecordPath] forKey:@"recordPath"];
        }
        
        [dict setObject:@(bean.orgVale) forKey:@"orgVoice"];
        [dict setObject:@(bean.backVale) forKey:@"backVoice"];
        [dict setObject:@(bean.recordVale) forKey:@"recordVoice"];
        drafts.musicPath = bean.backMusic;
    }else{
        [dict setObject:@(1) forKey:@"orgVoice"];
        [dict setObject:@(1) forKey:@"backVoice"];
        [dict setObject:@(1) forKey:@"recordVoice"];
    }
    
    [dict setObject:@(self.drawType) forKey:@"drawType"];

    if(clipData.group != nil){
        [dict setObject:[clipData.group getDictionary] forKey:@"filterGroup"];
    }

    
    
    drafts.dict_save = dict;
    drafts.img_address = img_address;
    [drafts changeNewChangeTime];
    drafts.part_name = self.disPlayname;
    drafts.during = clipData.allLength;
    drafts.isBroken = NO;
    
    if(self.movieDrafts != nil){
        drafts.part_id = self.movieDrafts.part_id;
    }

    self.nowSaveDrafts = drafts;
    
    if(clipPubthings.saveDraft != nil){
        clipPubthings.saveDraft(drafts);
    }
}

//开始播放
-(IBAction)play:(id)sender{
    [self playIosPlayer];
}
//暂停
-(IBAction)pausePlayer:(id)sender{
    [self pauseIosPlayer];
}

//开始播放
-(void)playIosPlayer{
    [self startPlayTimer];
    
    double currentTimeSec = [clipData getCurrentTime];
    
    if(!clipData.isPreView){
        //在裁剪界面，判断播放器状态，如果已经超过了裁剪的末尾时间，那么从头播放
        if(clipData.isPlayerEnd || currentTimeSec >= [self.clipMovie getPlayEndTime]-0.001||currentTimeSec < [self.clipMovie getPlayStartTime]-0.001){
            [clipData seekToTimeSync:[self.clipMovie getPlayStartTime]];
        }
    }else{
        if(clipData.isPlayerEnd){
            [clipData seekToTimeSync:0];
        }
    }
    [clipData playIosPlayer];
    self.btn_play.hidden = YES;
    self.btn_pause.hidden = NO;
}
//暂停
-(void)pauseIosPlayer{
    [self stopPlayTimer];
    [clipData pauseIosPlayer];
    self.btn_play.hidden = NO;
    self.btn_pause.hidden = YES;
    double currentTimeSec = [clipData getCurrentTime];
    
    if(clipData.isPreView){
        [self.subPlayView setNowPlayTime:currentTimeSec ispause:[clipData getPauseState]];
    }
    
}



//开始监听时间的定时器
-(void)startPlayTimer{
    if(self.playtimer != nil && [self.playtimer isValid]){
        return;
    }
    CGFloat duration = clipData.allLength; //视频总时间
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

//结束并释放播放器
-(void)stopPlayer{
    [self stopPlayTimer];
    [clipData stopPlayer];
    self.btn_play.hidden = YES;
    self.btn_pause.hidden = YES;
}

-(void)seekToTime:(double)time{
    if(time < 0){
        time = 0;
    }
    [clipData seekToTime:time];
    if(clipData.isPreView){
        [self.subPlayView setNowPlayTime:time ispause:[clipData getPauseState]];
    }
}
-(void)seekSyncToTime:(double)time{
    if(time < 0){
        time = 0;
    }
    [clipData seekToTimeSync:time];
    if(clipData.isPreView){
        [self.subPlayView setNowPlayTime:time ispause:[clipData getPauseState]];
    }
}
//播放器播放时间显示
-(void)dealTime{
    if(clipData == nil){
        [self stopPlayTimer];
        return;
    }
    //    BOOL isPause = [clipData getPauseState];
    double currentTimeSec = [clipData getCurrentTime];
    if(!clipData.isPreView){
        if(clipData.isPlayerEnd || currentTimeSec > [self.clipMovie getPlayEndTime]){
            if(clipData.isPlayerEnd){
                currentTimeSec = [self.clipMovie getPlayEndTime];
                self.btn_play.hidden = NO;
                self.btn_pause.hidden = YES;
                [self stopPlayTimer];
                
            }else{
                [self pauseIosPlayer];
            }
        }
        
    }else{
        if(clipData.isPlayerEnd){
            currentTimeSec = clipData.allLength;
            self.btn_play.hidden = NO;
            self.btn_pause.hidden = YES;
            [self pauseIosPlayer];
        }
    }
    
    
    if(self.type == 1){
        [self.subTitle setNowPlayTime:currentTimeSec];
    }
    
    if(self.type == 2){
        [self.recordView setNowPlayTime:currentTimeSec];
    }
    if(clipData.isPreView){
        [self.subPlayView setNowPlayTime:currentTimeSec ispause:[clipData getPauseState]];
        [self.collect_clip showSelectTile:currentTimeSec];
    }else{
        [self.clipMovie setNowPlayTime:currentTimeSec];
    }
    
}

-(CGSize)getFitSize:(NSInteger)tag{
    NSInteger height = 0;
    NSInteger width = 0;

    switch (tag) {
        case 0:
            width = 1920;
            height = 1080;
            break;
        case 1:
            width = 1280;
            height = 720;
            break;
        case 2:
            width = 1280;
            height = 720;
            break;
        default:
            break;
    }
    //0 超清  1高清 2 标清
    switch (self.drawType) {
        case DrawType1x1:
            width = height;
            height = height;
            break;
        case DrawType4x3:
            height = height;
            width = height/3*4;
            break;
        case DrawType3x4:
            width = height;
            height = width/3*4;
            break;
        case DrawType16x9:
            height = height;
            width = height/9*16;
            break;
        case DrawType9x16:
            width = height;
            height = width/9*16;
            break;

        default:
            break;
    }
    return CGSizeMake(width, height);
}



-(NSString *)ret32bitString

{
    
    char data[32];
    
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
    
}
-(int)getRandomNumber:(int)from to:(int)to

{
    srand((unsigned)time(0)); //不加这句每次产生的随机数不变
    return (int)(from + (arc4random() % (to - from + 1)));
    
}


-(NSString*)getFilename
{
    int time = [self getRandomNumber:10000000 to:99999999];
    NSString *str =nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [[NSDate alloc] init];
    str = [formatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@%d",str,time];
}
//生成一个随机的32为字符串，当做数据库唯一标示
-(NSString*)getLiveuuid
{
    NSString *str =nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [[NSDate alloc] init];
    str = [formatter stringFromDate:date];
    
    str = [NSString stringWithFormat:@"%@_%@",str,[self ret32bitString]];
    
    return str;
}


@end
