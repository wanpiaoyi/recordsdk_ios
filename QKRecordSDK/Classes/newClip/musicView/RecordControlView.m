//
//  RecordControlView.m
//  QukanTool
//
//  Created by yang on 2017/12/12.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "RecordControlView.h"
#import "RecordAudio.h"
#import "QKMoviePart.h"
#import "MoviesPartImgs.h"
#import "AudioRecordedView.h"
#import "RecordInfoController.h"
#import "ChooseAudio.h"
#import "ClipPubThings.h"

@interface RecordControlView()

@property(strong,nonatomic) RecordAudio *record;
//3个tab页面
@property(strong,nonatomic) IBOutlet UIView *v_value;

@property(strong,nonatomic) IBOutlet UIView *v_addBackgroundAudio;
@property(strong,nonatomic) IBOutlet UIView *v_recordAudio;
@property(strong,nonatomic) MoviesPartImgs *moviesPart;

//顶部的图片栏目
@property(strong,nonatomic) IBOutlet UIView *v_imgs;
@property(strong,nonatomic) IBOutlet UILabel *lbl_time;


//是否监听原声的按钮
@property(strong,nonatomic) IBOutlet UIButton *btn_checkOrg;
//开始录音按钮
@property(strong,nonatomic) IBOutlet UIButton *btn_startButton;
//删除按钮
@property(strong,nonatomic) IBOutlet UIButton *btn_deleteButton;
@property(strong,nonatomic) IBOutlet UIButton *btn_sure;

//音量背景音、录音音量调节
@property(strong,nonatomic) IBOutlet UISlider *sld_orgValue;
@property(strong,nonatomic) IBOutlet UISlider *sld_backValue;
@property(strong,nonatomic) IBOutlet UISlider *sld_recordValue;

@property(strong,nonatomic) RecordInfoController *recordControl;

@property BOOL listenOrg;//录音时是否显示原声

@property BOOL isRecorded; //是否在录音
@property int nowThreeTime;//录音倒计时321
@property(strong,nonatomic) NSTimer *timer;//录音倒计时的timer
@property(strong,nonatomic) NSLock *lock;

//选中的片段
@property (strong,nonatomic) AudioRecordedView *selectView;


@property(strong,nonatomic) IBOutlet UIView *v_changeValue;

@property(strong,nonatomic) IBOutlet UIView *v_music;

@property(strong,nonatomic) IBOutlet UIView *v_recordAudioType;

@property(strong,nonatomic) IBOutlet UIButton *btn_hid;

@property(strong,nonatomic) IBOutlet UIScrollView *scroll;
@property(strong,nonatomic) IBOutlet UIImageView *img1;
@property(strong,nonatomic) IBOutlet UIImageView *img2;
@property(strong,nonatomic) IBOutlet UIImageView *img3;
@property(strong,nonatomic) ChooseAudio *choose;

@end

@implementation RecordControlView

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//按下home键时候触发
- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self.lock lock];
    NSLog(@"applicationWillResignActive");
    self.nowThreeTime = -1;
    //录音中则停止
    [self.lock unlock];

    if(self.isRecorded){
        [self startOrPauseRecord:nil];
    }
}




-(instancetype)initWithFrame:(CGRect)frame control:(RecordInfoController*)recordControl{
    self = [super initWithFrame:frame];
    if(self){
        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"RecordControlView1" owner:self options:nil];
        UIView *v_addName = [array firstObject];
        v_addName.frame = self.bounds;
        [self addSubview:v_addName];
        self.lock = [[NSLock alloc] init];
        [self requestDetermined];
        
        self.isRecorded = NO;
        self.listenOrg = YES;

        WS(weakSelf);
        [recordControl setRecordCall:^(RecordCall state, double time) {
            switch (state) {
                case RecordCallRecording:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.lbl_time.text = [weakSelf getTimeToString:time];
                        [weakSelf.moviesPart setNowPlayTime:time];
                    });
                }
                    break;
                case RecordCallRecordEnd:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf startOrPauseRecord:nil];
                        weakSelf.lbl_time.text = [weakSelf getTimeToString:time];
                        [weakSelf.moviesPart setNowPlayTime:time];
                    });
                }
                    break;
                default:
                    break;
            }
        }];
        self.recordControl = recordControl;
        self.record = [[RecordAudio alloc] init:recordControl];
        self.lbl_time.text = @"00:00:00";
        
        
        self.scroll.contentSize = CGSizeMake(self.bounds.size.width*3, self.scroll.frame.size.height);
        
        self.v_value.frame = CGRectMake(0, 0, self.bounds.size.width, self.scroll.frame.size.height);
        self.v_addBackgroundAudio.frame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.scroll.frame.size.height);
        self.v_recordAudio.frame = CGRectMake(self.bounds.size.width*2, 0, self.bounds.size.width, self.scroll.frame.size.height);

        
        self.moviesPart = [[MoviesPartImgs alloc] initWithFrame:CGRectMake(0, 42, frame.size.width, audioRecorderView_frameHeight) backGroundImage:nil];
        [self.v_imgs addSubview:self.moviesPart];
        [self.moviesPart changeMovies:[self.recordControl getArray_movies]];

        
        [self.moviesPart setChangeTime:^(double time) {
            ChangePlayerControl playControl = weakSelf.playControl;
            if(playControl){
                playControl(PlayerControlSeek,time);
            }
            weakSelf.lbl_time.text = [weakSelf getTimeToString:time];
        }];
        [self.moviesPart setSelectRecordViewCall:^(AudioRecordedView *recordView) {
            if(weakSelf.selectView == recordView){
                [weakSelf.selectView setIsSelect:NO];
                weakSelf.selectView = nil;
                
                return ;
            }
            if(weakSelf.selectView != nil){
                [weakSelf.selectView setIsSelect:NO];
            }
            weakSelf.selectView = recordView;
            [weakSelf.selectView setIsSelect:YES];
        }];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
        
        ChooseAudio *choose = [[ChooseAudio alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 108) music:[recordControl getMusicPath]];
        [choose setChooseMusic:^(QKMusicBean *music) {
            double value = weakSelf.sld_backValue.value;
            NSString*path = @"";
            if(music != nil){
                path = music.address;
            }
            [self.recordControl setMusicPath:path];
            [self change:AudioChangeBackPath value:self.sld_backValue.value path:path];
        }];
        [self.v_addBackgroundAudio addSubview:choose];
        self.choose = choose;
        QKAudioBean *bean = [recordControl getAudioBean];
        
        self.sld_orgValue.value = bean.orgVale;
        self.sld_backValue.value = bean.backVale;
        self.sld_recordValue.value = bean.recordVale;


        
        [self.sld_orgValue setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateHighlighted];
        [self.sld_orgValue setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateNormal];
        
        [self.sld_backValue setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateHighlighted];
        [self.sld_backValue setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateNormal];
        [self.sld_recordValue setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateHighlighted];
        [self.sld_recordValue setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateNormal];
        
        [self.sld_orgValue setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
        self.sld_orgValue.frame = CGRectMake(50, 15,29,80);
        
        [self.sld_backValue setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
        self.sld_backValue.frame = CGRectMake(clipPubthings.screen_width/2 - 15, 15,29,80);
        
        [self.sld_recordValue setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
        self.sld_recordValue.frame = CGRectMake(clipPubthings.screen_width - 82, 15,29,80);
        [self.btn_sure setTitleColor:clipPubthings.color forState:UIControlStateNormal];
    }
    return self;
}

-(IBAction)close:(id)sender{
    if(self.closeView){
        self.closeView(CloseViewTypeNormal);
    }
    [self removeFromSuperview];
}

-(IBAction)addNewAudio:(id)sender{
    [self.recordControl setMusicPath:@"frameChange1.pcm"];
    [self change:AudioChangeBackPath value:self.sld_backValue.value path:@"frameChange1.pcm"];
    NSLog(@"addNewAudio");
}

-(BOOL)requestDetermined{
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {// 未询问用户是否授权
        //第一次询问用户是否进行授权
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
            if (granted) {
                // Microphone enabled code
            }
            else {
                // Microphone disabled code
            }
        }];
        return NO;
    }
    else if(videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {// 未授权
        return NO;
    }else{// 已授权
        return YES;
    }
}


-(void)setNowPlayTime:(double)nowTime{
    if(self.isRecorded){
        return;
    }
    self.lbl_time.text = [self getTimeToString:nowTime];
    [self.moviesPart setNowPlayTime:nowTime];
}


-(void)changeMovies{
    [self.moviesPart changeMovies:[self.recordControl getArray_movies]];
}

//选择调音、音乐、和配音
-(IBAction)changeType:(id)sender{
    if(self.isRecorded){
        [pgToast setText:@"当前正在录音"];
        return;
    }
    UIButton *btn = (UIButton*)sender;
    [self hidViews];
    switch (btn.tag) {
        case 0:
            self.v_changeValue.alpha = 1;
            self.img1.hidden = NO;
            [self.scroll setContentOffset:CGPointMake(0, 0) animated:YES];
            break;
        case 1:
            self.v_music.alpha = 1;
            self.img2.hidden = NO;

            [self.scroll setContentOffset:CGPointMake(self.scroll.frame.size.width, 0) animated:YES];

            break;
        case 2:
            [self.scroll setContentOffset:CGPointMake(self.scroll.frame.size.width*2, 0) animated:YES];
            self.img3.hidden = NO;

            self.v_recordAudioType.alpha = 1;
            break;
        default:
            break;
    }
}
////方法方法中 velocity 为 CGPointZero时（结束拖动时两个方向都没有速度），没有初速度，所以也没有减速过程，willBeginDecelerating 和该didEndDecelerating 也就不会被调用如果 velocity 不为 CGPointZero 时，scrollview 会以velocity 为初速度，减速直到 targetContentOffset，也就是说在你手指离开屏幕的那一刻，就计算好了停留在那个位置的坐标
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout nonnull CGPoint *)targetContentOffset{
    //    NSLog(@"scrollViewWillEndDragging:%.1lf",targetContentOffset->x);
    int page = targetContentOffset->x /self.scroll.frame.size.width;
    [self hidViews];
    
    switch (page) {
        case 0:
            self.v_changeValue.alpha = 1;
            break;
        case 1:
            self.v_music.alpha = 1;
            
            break;
        case 2:
            self.v_recordAudioType.alpha = 1;
            break;
        default:
            break;
    }
}
-(void)hidViews{
    self.v_recordAudioType.alpha = 0.5;
    self.v_music.alpha = 0.5;
    self.v_changeValue.alpha = 0.5;
    self.img1.hidden = YES;
    self.img2.hidden = YES;
    self.img3.hidden = YES;
    self.v_changeValue.hidden = NO;
    self.v_music.hidden = NO;
    self.v_recordAudioType.hidden = NO;
}

-(void)change:(AudioChange) state value:(double)value path:(NSString *)path{
    ChangeAudioControl audioControl = self.audioControl;
    if(audioControl){
        audioControl(state,value,path);
    }
}

#pragma mark - 调音
-(IBAction)changeOrgValue:(id)sender{
    double value = self.sld_orgValue.value;
    [self.recordControl setOrgValue:value];
    [self change:AudioChangeOrgValue value:value path:nil];
}
-(IBAction)changeBackAudioValue:(id)sender{
    double value = self.sld_backValue.value;
    [self.recordControl setBackValue:value];

    [self change:AudioChangeBackValue value:value path:nil];
}

-(IBAction)changRecordAudioValue:(id)sender{
    double value = self.sld_recordValue.value;
    [self.recordControl setRecordValue:value];
    [self change:AudioChangeRecordValue value:value path:nil];
}

#pragma mark - 音乐


#pragma mark - 监听原声
//打开或关闭原声
-(IBAction)openOrCloseOrgValue:(id)sender{
    self.listenOrg = !self.listenOrg;
    double value = self.sld_orgValue.value;

    if(self.listenOrg){
        [self.btn_checkOrg setImage:[clipPubthings imageNamed:@"qk_clipview_listened"] forState:UIControlStateNormal];
        [pgToast setText:@"配音时监听原声"];
    }else{
        [self.btn_checkOrg setImage:[clipPubthings imageNamed:@"qk_clipview_listen"] forState:UIControlStateNormal];
        value = 0;
        [pgToast setText:@"配音时关闭原声"];
    }
    //录音中生成原声
    if(self.isRecorded){
        //修改原声静音
        [self change:AudioChangeOrgValue value:value path:nil];
    }
}

-(IBAction)showCantChangeTab:(id)sender{
    [pgToast setText:@"当前正在录音"];
}

#pragma mark - 配音
//删除一个片段
-(IBAction)deleteRecordView:(id)sender{
    if(self.selectView == nil){
        NSLog(@"error:请选择片段");
        return;
    }
    
    if(self.isRecorded){
        NSLog(@"请先停止录音");
        return;
    }
    ChangePlayerControl playControl = self.playControl;
    if(playControl){
        playControl(PlayerControlPause,0);
    }
    [self.recordControl removePart:self.selectView.startTime endTime:self.selectView.endTime];
    [self.selectView removeFromSuperview];
    QKAudioBean *audioBean = [self.recordControl getAudioBean];
    double value = audioBean.recordVale;
    [self change:AudioChangeRecordPath value:value path:[self.recordControl getRecordPath]];
    
}
//开始或者暂停
-(IBAction)startOrPauseRecord:(id)sender{
    [self.lock lock];
    if([self requestDetermined]){
        if(!self.isRecorded){
            if([self.moviesPart getNowTime] >= [self.recordControl getAllMovieTime]){
                [self.lock unlock];
                return;
            }
            ChangePlayerControl playControl = self.playControl;
            if(playControl){
                playControl(PlayerControlPause,0);
            }
            //增加界面覆盖，除了录音其他界面均变为不可操作状态
            CanNotDoAnythings notDoThings = self.notDoThings;
            if(notDoThings){
                notDoThings(YES);
                self.btn_hid.hidden = NO;
            }
            self.isRecorded = YES;
            //开启录音
            double startTime = [self.moviesPart getNowTime];
            [self.record startRecord:startTime];
            self.nowThreeTime = 0;
            if(self.timer != nil && [self.timer isValid]){
                [self.timer invalidate];
            }
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(startRecordByThreeTime:)
                                           userInfo:nil
                                            repeats:YES];
            [self.btn_startButton setTitle:[NSString stringWithFormat:@"3"] forState:UIControlStateNormal];
            [self.btn_startButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@""] inBundle:[clipPubthings clipBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

            [self change:AudioChangeRecordPath value:0 path:@""];
            [self change:AudioChangeBackValue value:0 path:nil];
            [self change:AudioChangeRecordValue value:0 path:nil];
            if(!self.listenOrg){
                [self change:AudioChangeOrgValue value:0 path:nil];
            }else{
                double value = self.sld_orgValue.value;
                [self change:AudioChangeOrgValue value:value path:nil];
            }
            self.scroll.scrollEnabled = NO;
        }else{
            self.scroll.scrollEnabled = YES;
            self.nowThreeTime = -1;
            if(self.timer != nil && [self.timer isValid]){
                [self.timer invalidate];
            }
             self.isRecorded = NO;
            [self.moviesPart endRecord];
            //取消界面覆盖，变为可操作状态
            CanNotDoAnythings notDoThings = self.notDoThings;
            if(notDoThings){
                notDoThings(NO);
                self.btn_hid.hidden = YES;
            }
            ChangePlayerControl playControl = self.playControl;
            if(playControl){
                playControl(PlayerControlPause,0);
            }
            //暂停录音
            [self.record pauseRecord];

            double value = self.sld_backValue.value;

            [self change:AudioChangeRecordPath value:value path:[self.recordControl getRecordPath]];

            [self.btn_startButton setBackgroundImage:[clipPubthings imageNamed:@"qk_record_startrecord"] forState:UIControlStateNormal];
            [self.btn_startButton setTitle:@"" forState:UIControlStateNormal];

            [self.moviesPart changeRecordedView:[self.recordControl getArray_movies]];

            value = self.sld_backValue.value;
            [self change:AudioChangeBackValue value:value path:nil];
            value = self.sld_recordValue.value;
            [self change:AudioChangeRecordValue value:value path:nil];
            value = self.sld_orgValue.value;
            [self change:AudioChangeOrgValue value:value path:nil];

            
            
            if(playControl){
                playControl(PlayerControlSeek,[self.moviesPart getNowTime]);
            }

        }
        
    }else{
        [pgToast setText:@"请开启麦克风权限"];
    }
	[self.lock unlock];
}

-(BOOL)getRecordState{
    return _isRecorded;
}
#pragma mark - 倒计时 3，2，1
//倒计时 3 2 1
-(void)startRecordByThreeTime:(id)sender{
    [self.lock lock];
    if(self.nowThreeTime == -1){
        NSTimer *timer = (NSTimer *)sender;
        if([timer isValid]){
            [timer invalidate];
        }
        [self.lock unlock];
        return;
    }

    self.nowThreeTime++;
    if(self.nowThreeTime >= 3|| self.nowThreeTime<=0){
        NSTimer *timer = (NSTimer *)sender;
        if([timer isValid]){
            [timer invalidate];
        }
        [self.btn_startButton setBackgroundImage:[clipPubthings imageNamed:@"qk_record_endrecord"] forState:UIControlStateNormal];
        [self.btn_startButton setTitle:@"" forState:UIControlStateNormal];
        ChangePlayerControl playControl = self.playControl;
        if(playControl){
            playControl(PlayerControlPlay,0);
        }
        [self.record startBegin];
        double startTime = [self.moviesPart getNowTime];
        [self.moviesPart setRecordStartTime:startTime];

    }else{
        [self.btn_startButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@""] inBundle:[clipPubthings clipBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.btn_startButton setTitle:[NSString stringWithFormat:@"%d",3 - self.nowThreeTime] forState:UIControlStateNormal];
    }
    [self.lock unlock];
}






//随机生成32位字符串党文件名
-(NSString *)ret32bitString
{
    
    char data[32];
    
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
    
}


//时间转化
-(NSString*)getTimeToString:(double)time{
    @synchronized(self){
        NSString *returnTime = @"";
        
        NSInteger hour = time / 3600;
        if(hour>=10){
            returnTime = [NSString stringWithFormat:@"%ld",hour];
        }else{
            returnTime = [NSString stringWithFormat:@"0%ld",hour];
        }
        NSInteger min = time / 60;
        if(min>=10){
            returnTime = [NSString stringWithFormat:@"%@:%ld",returnTime,min];
        }else{
            returnTime = [NSString stringWithFormat:@"%@:0%ld",returnTime,min];
        }
        NSInteger sec = (int)time % 60;
        
        if(sec>=10){
            returnTime = [NSString stringWithFormat:@"%@:%ld",returnTime,sec];
        }else{
            returnTime = [NSString stringWithFormat:@"%@:0%ld",returnTime,sec];
        }
        NSInteger endTime = (int)(time*100)%100;
        if(endTime>=10){
            returnTime = [NSString stringWithFormat:@"%@.%ld",returnTime,endTime];
        }else{
            returnTime = [NSString stringWithFormat:@"%@.0%ld",returnTime,endTime];
        }
        return returnTime;
    }
}

-(RecordInfoController*)getRecordInfo:(RecordInfoController*)info{
    [self.recordControl changeRecordPath:info.getRecordPath];
    return self.recordControl;
}
@end
