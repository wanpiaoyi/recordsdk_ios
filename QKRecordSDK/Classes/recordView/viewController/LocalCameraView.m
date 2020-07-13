//
//  LocalCameraView.m
//  QukanTool
//
//  Created by yang on 2018/7/3.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "LocalCameraView.h"
#import <QKLiveAndRecord/IPLocalCameraSDK.h>
#import "CmsRecordData.h"
#include <sys/mount.h>
#import "RecorDdata.h"
#import "ClipPubThings.h"
#import "MBProgressHUD.h"
#import "QukanAlert.h"

@interface LocalCameraView()

@property(strong,nonatomic) UIView *v_videoView;
@property(strong,nonatomic) UIView *v_main;
@property(strong,nonatomic) NSTimer *timer;
@property(strong,nonatomic) CmsRecordData *oldRecord;
@property(strong,nonatomic) NSMutableArray *arrayRecords;
@property(nonatomic) int outputType;
@property(nonatomic) NSInteger start_stopcontrol;


@property(nonatomic) BOOL cameraIsStart;
@property(nonatomic) BOOL use4K;
@property(nonatomic) BOOL IsForntCamera;

@property double nowScale;
@property(nonatomic) NSInteger flag1;
@end

@implementation LocalCameraView

//按下home键时候触发
- (void)applicationDidEnterBackground:(NSNotification *)notification

{
    if ([IPLocalCameraSDK cameraIsRecord]) {
        [self stopRecord];
    }
    [self stopCamera];
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopRecord];
    [self stopCamera];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self comeFront];
}


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioSessionWasInterrupted:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:sessionInstance];

        
        [IPLocalCameraSDK changeRenderOutPut:self.outputType];
        [IPLocalCameraSDK changeSpeed:1.0];
        
        UIView *v_main = [[[clipPubthings clipBundle] loadNibNamed:@"LocalCameraView1" owner:self options:nil] objectAtIndex:0];
        v_main.frame = self.bounds;
        [self addSubview:v_main];
        self.v_main = v_main;

        self.backgroundColor = [UIColor blackColor];

        self.img1.layer.cornerRadius = 3;
        self.img1.layer.borderWidth = 1;
        self.img1.layer.borderColor = [UIColor whiteColor].CGColor;
        self.img2.layer.cornerRadius = 3;
        self.img2.layer.borderWidth = 1;
        self.img2.layer.borderColor = [UIColor whiteColor].CGColor;
        self.img3.layer.cornerRadius = 3;
        self.img3.layer.borderWidth = 1;
        self.img3.layer.borderColor = [UIColor whiteColor].CGColor;
        
        self.use4K = NO;
        self.v_videoView = [[UIView alloc] init];
        self.outputType = kLocalIPCameraOutputType16x9;

        [self changeCameraFrame];
        self.v_speeds.layer.cornerRadius = 4.0;
        self.v_videoView.backgroundColor = [UIColor clearColor];
        self.focus_fight_image = [[UIImageView alloc] init];
        self.focus_fight_image.image = [clipPubthings imageNamed:@"focus_fight"];
        self.focus_fight_image.frame = CGRectMake(0, 0, 121, 121);
        self.focus_fight_image.hidden = YES;
        [self.v_videoView addSubview:self.focus_fight_image];
        self.focus_fight_transfor = self.focus_fight_image.transform;
        [self insertSubview:self.v_videoView atIndex:0];
        self.IsForntCamera = false;
        static NSInteger countFile = 0;
        countFile = 0;
        WS(weakSelf);
        
        //获取录制完成的视频
        [IPLocalCameraSDK getFileEndRecord:^(NSString *filename, NSInteger filetime, NSString *type) {
            NSString *address = [NSString stringWithFormat:@"%@/%@",localRecordType,filename];
            
            if(clipPubthings.recordUrl != nil){
                clipPubthings.recordUrl(address);
            }
            //添加到本地数据库
            
            
            CmsRecordData *data = [CmsRecordData getVideoByAddress:address];
            weakSelf.oldRecord = data;
            
            if(weakSelf.arrayRecords == nil){
                weakSelf.arrayRecords = [NSMutableArray new];
            }
            if(self.saveLocalRecord){
                data.deleteEndEdict = NO;
            }else{
                data.deleteEndEdict = YES;
            }
            [weakSelf.arrayRecords addObject:data];
            if(weakSelf.saveToPhoto){
                NSString *addr = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,data.address];

                [weakSelf exportVideo:addr];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *setImg = weakSelf.img1;
                if(weakSelf.img1.image != nil){
                    setImg = weakSelf.img2;
                    if(weakSelf.img2.image != nil){
                        setImg = weakSelf.img3;
                        if(weakSelf.img3.image != nil){
                            weakSelf.img1.image = weakSelf.img2.image;
                            weakSelf.img2.image = weakSelf.img3.image;
                            setImg = weakSelf.img3;
                        }else{
                            weakSelf.img3.hidden = NO;
                        }
                    }else{
                        weakSelf.img2.hidden = NO;
                    }
                }else{
                    weakSelf.img1.hidden = NO;
                }
                [data setImageView:setImg];
            });

        }];
        UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(fingureScale:)];
        gesture.delegate = self;
        [self addGestureRecognizer:gesture];
        [self initCamera];
       
    }
    return self;
}

-(void)removeAllRecords{
    NSFileManager *file = [[NSFileManager alloc] init];

    for(CmsRecordData *data in self.arrayRecords){
        NSString *addr = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,data.address];
        [file removeItemAtPath:addr error:nil];
//        if(delete){
//            NSLog(@"removeFile:%@",addr);
//        }
    }
}

-(void)exportVideo:(NSString *)filePath{
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{

        
        MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:HUD];
        
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
            }
            
        }completionBlock:^{
            
            //操作执行完后取消对话框
            [HUD removeFromSuperview];
            if(weakSelf.flag1 == -1){
                [QukanAlert alertMsg:@"文件导出失败，请检查相册权限是否开启"];
            }
        }];
        
    });

}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error != nil){
        self.flag1 = -1;
    }else{
        self.flag1 = 1;
    }
    
}

- (void)audioSessionWasInterrupted:(NSNotification *)notification
{
    NSLog(@"the notification is %@",notification);
    if (AVAudioSessionInterruptionTypeBegan == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue])
    {
        NSLog(@"begin");
        if ([IPLocalCameraSDK cameraIsRecord]) {
            [self stopRecord];
        }
        [self stopCamera];
    }
    else if (AVAudioSessionInterruptionTypeEnded == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue])
    {
        NSLog(@"end");
        [self comeFront];
    }
}

-(void)comeFront{
    @synchronized(self) {
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
        
        printf("按理说是重新进来后响应\n");
        // 页面从home重新启动后，是关闭闪光灯的，
        [IPLocalCameraSDK switchLocalFlash:kIPLocalCameraCloseFlash];
        self.btn_flash.tag = kIPLocalCameraCloseFlash;
        [self.btn_flash setImage:[clipPubthings imageNamed:@"qktool_record_flashclose.png"] forState:UIControlStateNormal];
        [self initCamera];
    }
}
//初始化摄像头
- (void)initCamera {
    @try{
        if(self.cameraIsStart){
            return;
        }
        self.nowScale = 1;
        [IPLocalCameraSDK setAppOrientation:[UIApplication sharedApplication].statusBarOrientation];
        [IPLocalCameraSDK switchLocalAudio:kIPLocalCameraOpenAudio];
        NSString *pressfixPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",pressfixPath,localRecordType];
        pressfixPath = filePath;
        
        NSFileManager *file = [NSFileManager defaultManager];
        //录像文件目录
        if (![file fileExistsAtPath:filePath])
        {
            [file createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [IPLocalCameraSDK clearLocalUserImage];
        
        
        
        int start;
        
        NSInteger scream = kLocalIPCameraEncodeType1920x1080;
        
        if(self.use4K){
            scream = kLocalIPCameraEncodeType3840x2160;
            [IPLocalCameraSDK setLocalCameraVideoBitRate:120];

        }else{
            [IPLocalCameraSDK setLocalCameraVideoBitRate:30];

        }
        [IPLocalCameraSDK setLocalCameraEncodeType:scream];
        
        
  
  
        start = [IPLocalCameraSDK startLocalCamera:self.v_videoView Orientation:AVCaptureVideoOrientationLandscapeRight Camera:1 recordPath:localRecordType];

        self.cameraIsStart = YES;
        if(start == -1 && self.use4K){
            if(self.IsForntCamera){
                [QukanAlert alertMsg:@"前置摄像头不支持4k拍摄，已自动切换到最佳分辨率"];
            }else{
                [QukanAlert alertMsg:@"当前设备不支持4k拍摄，已自动切换到最佳分辨率"];
            }
        }
    }
    @catch(NSException *exception) {
        
    }
    @finally {
        
    }
}

//4k录制
-(IBAction)start4k:(id)sender{
    if([IPLocalCameraSDK cameraIsRecord]){
        return;
    }
    BOOL restarCamera = true;
    if(self.use4K){
        self.use4K = false;
    }else{
        if([IPLocalCameraSDK checkEncodeType:kLocalIPCameraEncodeType3840x2160 font:self.IsForntCamera]){
            self.use4K = true;
        }else{
            restarCamera = false;
            if(self.IsForntCamera){
                [QukanAlert alertMsg:@"前置摄像头不支持4k拍摄"];
            }else{
                [QukanAlert alertMsg:@"当前设备不支持4k拍摄"];
            }
        }
    }
    if(restarCamera){
        [self stopCamera];
        [self initCamera];
    }
    
    if(self.use4K){
        [self.btn_4k setImage:[clipPubthings imageNamed:@"qktool_record_4Ksel"] forState:UIControlStateNormal];
        self.outputType = kLocalIPCameraOutputType16x9;
        self.v_videoView.frame = [self getOutPutRect:self.outputType];
        [IPLocalCameraSDK changeRenderOutPut:self.outputType];
        self.stabilization = NO;
     
        [self.btn_fangdou setImage:[clipPubthings imageNamed:@"qktool_record_fangdou"] forState:UIControlStateNormal];
        self.btn_flash.tag = kIPLocalCameraCloseFlash;
        [self.btn_flash setImage:[clipPubthings imageNamed:@"qktool_record_flashclose.png"] forState:UIControlStateNormal];
        
        [IPLocalCameraSDK setStabilization:self.stabilization];
        
    }
    else{
        [self.btn_4k setImage:[clipPubthings imageNamed:@"qktool_record_4K"] forState:UIControlStateNormal];
    }
}



//开始或者停止录制
-(IBAction)startOrStop:(id)sender
{
    if(![IPLocalCameraSDK cameraIsRecord]){
        [self startRecord];
    }else{
        if(self.start_stopcontrol>0){
            return;
        }
        [self stopRecord];
    }
}

//拍照
-(void)localTakePhoto{
    self.img_count++;
    WS(weakSelf);
    [IPLocalCameraSDK takeLocalPhoto:^(NSString *img_address, NSString *img_name, NSData *data) {
        
        CGRect rect = CGRectMake((weakSelf.v_main.frame.size.width-100)/2, (weakSelf.v_main.frame.size.height-100)/2, 100, 100);
        UIImage * image = [UIImage imageWithData:data];
        
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:rect];
        img.contentMode = UIViewContentModeScaleAspectFit;
        img.image = image;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.v_main addSubview:img];
            [UIView animateWithDuration:1 animations:^{
                CGRect rect = weakSelf.btn_start.frame;
                img.frame = CGRectMake(rect.origin.x +(rect.size.width - 10 )/2, rect.origin.y + (rect.size.height - 10 )/2, 10, 10);
            } completion:^(BOOL finished) {
                [img removeFromSuperview];
            }];

        });
        
        
        NSString * uploadfileName = img_name;
        NSArray *arr = [img_name componentsSeparatedByString:@"."];
        if(arr.count>1){
            uploadfileName = [NSString stringWithFormat:@"%@_upload1.%@",arr[0],arr[arr.count-1]];
        }

    } address:@"image"];
}
//开始录制
-(void)startRecord{
    [self reset];
    self.v_speeds.hidden = YES;
    self.v_imgs.hidden = YES;

    [self.btn_speedChoose setImage:[clipPubthings imageNamed:@"qktool_record_speed"] forState:UIControlStateNormal];
    self.btn_fangdou.enabled = NO;
    self.btn_outputType.enabled = NO;
    self.btn_4k.enabled = NO;
    self.btn_speedChoose.enabled = NO;

    [self startTimeRecord];
    [IPLocalCameraSDK startLocalRecord];
    [self.btn_start setTitle:@"" forState:UIControlStateNormal];
    if(self.changeState){
        self.changeState(changeLocalStateHidden);
    }
}
//停止录制
-(void)stopRecord{

    self.btn_fangdou.enabled = YES;
    self.btn_outputType.enabled = YES;
    self.btn_4k.enabled = YES;
    self.btn_speedChoose.enabled = YES;

    self.v_imgs.hidden = NO;
    self.v_imgs.hidden = NO;

    count_second = 0;
    count_minute = 0;
    count_hour = 0;
    [IPLocalCameraSDK stopLocalRecord];
    [self stopTimeRecord];
    [self.btn_start setTitle:@"" forState:UIControlStateNormal];
    [self reset];
    if(self.changeState){
        self.changeState(changeLocalStateShow);
    }
}
-(void)reset{
    self.liveTime = -1;
    self.start_stopcontrol = 4;
    count_second = 0;
    count_minute = 0;
    count_hour = 0;
    self.img_count = 0;
}
//关闭摄像头
-(void)stopCamera{
    if(self.cameraIsStart){
        [IPLocalCameraSDK stopLocalCamera];
        self.cameraIsStart = NO;
    }
}

//开始定时器
-(void)startTimeRecord
{
    if (self.timer!=nil&&[self.timer isValid])
    {
        [self.timer invalidate];
    }
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(dealTime) userInfo:Nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}
-(void)stopTimeRecord{
    if (self.timer!=nil&&[self.timer isValid])
    {
        [self.timer invalidate];
    }
}




//时间轴
-(void)dealTime
{
    if(self.start_stopcontrol>0){
        self.start_stopcontrol --;
    }
    if(self.liveTime < 3600*1.5 && self.liveTime > -1){
        [QukanAlert alertMsg:[NSString stringWithFormat:@"当前剩余手机内存空间预计还能存储%.1lf小时的录制录像，请注意剩余可用空间！",self.liveTime / 3600.0]];
        self.liveTime = -1;
    }
    self.liveTime --;
    if(self.liveTime < -30){
        self.liveTime = -1;
        [self checkFree];
    }
    
    //时间显示
    ++count_second;
    

    int i = 0;
    int j = 0;
    
    if (count_second == 60)
    {
        count_second = 0;
        ++count_minute;
        i = 1;
    }
    
    if (count_minute == 60)
    {
        count_minute = 0;
        ++count_hour;
        j = 1;
    }
    NSString *nowTime = @"";
    if (count_second < 10)
    {
        nowTime = [NSString stringWithFormat:@"0%ld",count_second];
        
    }else
    {
        nowTime = [NSString stringWithFormat:@"%ld",count_second];
    }
    
    if (count_minute > 0)
    {
        if (count_minute < 10)
        {
            nowTime = [NSString stringWithFormat:@"0%ld:%@",count_minute,nowTime];
            
        }else
        {
            nowTime = [NSString stringWithFormat:@"%ld:%@",count_minute,nowTime];
        }
    }
    if (count_hour > 0)
    {
        if (count_hour < 10)
        {
            nowTime = [NSString stringWithFormat:@"0%ld:%@",count_hour,nowTime];
            
        }else
        {
            nowTime = [NSString stringWithFormat:@"%ld:%@",count_hour,nowTime];
        }
        
    }
    [self.btn_start setTitle:nowTime forState:UIControlStateNormal];
    
}
#pragma mark - 快慢镜头
-(IBAction)showSpeedChoose:(id)sender{
    if([IPLocalCameraSDK cameraIsRecord]){
        return;
    }
    if(self.v_speeds.hidden == YES){
        self.v_speeds.hidden = NO;
        [self.btn_speedChoose setImage:[clipPubthings imageNamed:@"qktool_record_speedsel"] forState:UIControlStateNormal];
    }else{
        self.v_speeds.hidden = YES;
        [self.btn_speedChoose setImage:[clipPubthings imageNamed:@"qktool_record_speed"] forState:UIControlStateNormal];

    }
}
//修改录制速度
-(IBAction)chooseSpeed:(id)sender{
    UIColor *colorUnUse = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    [self.btn_speed1 setTitleColor:colorUnUse forState:UIControlStateNormal];
    [self.btn_speed2 setTitleColor:colorUnUse forState:UIControlStateNormal];
    [self.btn_speed3 setTitleColor:colorUnUse forState:UIControlStateNormal];
    [self.btn_speed4 setTitleColor:colorUnUse forState:UIControlStateNormal];
    [self.btn_speed5 setTitleColor:colorUnUse forState:UIControlStateNormal];
    
    
    UIButton *btn = (UIButton*)sender;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    double nowSpeed = 1.0;
    switch (btn.tag) {
        case 0:
            nowSpeed = 0.5;
            break;
        case 1:
            nowSpeed = 2.0/3.0;
            break;
        case 2:
            nowSpeed = 1.0;
            break;
        case 3:
            nowSpeed = 1.5;
            break;
        case 4:
            nowSpeed = 2.0;
            break;
        default:
            break;
    }
    [IPLocalCameraSDK changeSpeed:nowSpeed];
}

#pragma mark - 界面摄像头闪光灯的操作

- (IBAction)chageCamera:(id)sender {
    int start = 0;
    if(self.use4K){
        if(![IPLocalCameraSDK checkEncodeType:kLocalIPCameraEncodeType3840x2160 font:!self.IsForntCamera]){
            NSString *str = @"前置摄像头不支持4k拍摄";
            if(self.IsForntCamera){
                str =  @"后置摄像头不支持4k拍摄";
            }
            [QukanAlert alertMsg:str];
            return;
        }
    }
    
    if(![IPLocalCameraSDK cameraIsRecord]){
        if (!self.IsForntCamera) {
            start = [IPLocalCameraSDK switchLocalChangeCamera:kIPLocalCameraFrontCamera];
            [IPLocalCameraSDK switchLocalFocusMode:kIPLocalCameraAutoFoucs];
            [IPLocalCameraSDK switchLocalFlash:kIPLocalCameraCloseFlash];
            [self.btn_flash setImage:[clipPubthings imageNamed:@"qktool_record_flash"] forState:UIControlStateNormal];
            self.btn_flash.tag = kIPLocalCameraCloseFlash;
            
            self.IsForntCamera = YES;
        } else {
            start = [IPLocalCameraSDK switchLocalChangeCamera:kIPLocalCameraBackCamera];
            self.IsForntCamera = NO;
        }
        if(start == -1 && self.use4K){
            if(self.IsForntCamera){
                [QukanAlert alertMsg:@"前置摄像头不支持4k拍摄，已自动切换到最佳分辨率"];
            }else{
                [QukanAlert alertMsg:@"当前设备不支持4k拍摄，已自动切换到最佳分辨率"];
            }
        }
        if(start != -1){
            self.nowScale = 1;
        }
        return;
    }
    
    if(self.start_stopcontrol>4){
        [QukanAlert alertMsg:@"请勿频繁切换摄像头"];
        return;
    }else if(self.start_stopcontrol>0){
        return;
    }
    self.start_stopcontrol = 3;
    if ([IPLocalCameraSDK cameraIsRecord])
    {
        if (!self.IsForntCamera) {
            start = [IPLocalCameraSDK switchLocalChangeCamera:kIPLocalCameraFrontCamera];
            [IPLocalCameraSDK switchLocalFocusMode:kIPLocalCameraAutoFoucs];
            [IPLocalCameraSDK switchLocalFlash:kIPLocalCameraCloseFlash];
            self.btn_flash.tag = kIPLocalCameraCloseFlash;
            [self.btn_flash setImage:[clipPubthings imageNamed:@"qktool_record_flashclose"] forState:UIControlStateNormal];
            self.IsForntCamera = YES;
        
        } else {
            start = [IPLocalCameraSDK switchLocalChangeCamera:kIPLocalCameraBackCamera];
            self.IsForntCamera = NO;
        }
        if(start == -1 && self.use4K){
            if(self.IsForntCamera){
                [QukanAlert alertMsg:@"前置摄像头不支持4k拍摄，已自动切换到最佳分辨率"];
            }else{
                [QukanAlert alertMsg:@"当前设备不支持4k拍摄，已自动切换到最佳分辨率"];
            }
        }
        if(start != -1){
            self.nowScale = 1;
        }
    }
    
}

- (IBAction)changeflash:(id)sender {
    if (self.btn_flash.tag == kIPLocalCameraOpenFlash) {
        self.btn_flash.tag = kIPLocalCameraCloseFlash;
        [IPLocalCameraSDK switchLocalFlash:kIPLocalCameraCloseFlash];
        [self.btn_flash setImage:[clipPubthings imageNamed:@"qktool_record_flashclose.png"] forState:UIControlStateNormal];
    } else {
        
        if(![IPLocalCameraSDK switchLocalFlash:kIPLocalCameraOpenFlash]){
            QukanAlert *alert = [[QukanAlert alloc] initWithCotent:@"当前摄像头无闪光灯" Delegate:nil];
            [alert show];
            return;
        }
        self.btn_flash.tag = kIPLocalCameraOpenFlash;
        
        [self.btn_flash setImage:[clipPubthings imageNamed:@"qktool_record_flash.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)changeAudio:(id)sender {
    if (self.btn_audio.tag == kIPLocalCameraOpenAudio) {
        [IPLocalCameraSDK switchLocalAudio:kIPLocalCameraCloseAudio];
        self.btn_audio.tag = kIPLocalCameraCloseAudio;
        [self.btn_audio setImage:[clipPubthings imageNamed:@"qktool_record_audioclose.png"] forState:UIControlStateNormal];
    } else {
        [IPLocalCameraSDK switchLocalAudio:kIPLocalCameraOpenAudio];
        self.btn_audio.tag = kIPLocalCameraOpenAudio;
        [self.btn_audio setImage:[clipPubthings imageNamed:@"qktool_record_audio.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)chageStabilization:(id)sender {
    if(self.use4K){
        [QukanAlert alertMsg:@"4K模式不支持防抖"];
        return;
    }
    self.stabilization = !self.stabilization;
    if(self.stabilization){
        [self.btn_fangdou setImage:[clipPubthings imageNamed:@"qktool_record_fangdousel"] forState:UIControlStateNormal];

    }else{
        [self.btn_fangdou setImage:[clipPubthings imageNamed:@"qktool_record_fangdou"] forState:UIControlStateNormal];
    }
    self.btn_flash.tag = kIPLocalCameraCloseFlash;
    [self.btn_flash setImage:[clipPubthings imageNamed:@"qktool_record_flashclose.png"] forState:UIControlStateNormal];

    [IPLocalCameraSDK setStabilization:self.stabilization];
}

-(IBAction)selectNewVideos:(id)sender{
    if(self.arrayRecords == nil|| self.arrayRecords.count == 0 || [IPLocalCameraSDK cameraIsRecord]){
        return;
    }
    if(self.changeState){
        self.changeState(changeLocalStateClose);
    }

    [clipPubthings showClipController:self.arrayRecords];
}

-(void)fingureScale:(UIPinchGestureRecognizer*)gesture
{
    float change_scale = self.nowScale;
    if (gesture.scale >1 )
    {
        change_scale += 0.1;
        if(change_scale > 6){
            change_scale = 6;
        }
        [IPLocalCameraSDK zoomLocalOut:change_scale];
        
    }else
    {
        if (change_scale - 0.1 < 1.0)
        {
            change_scale = 1.0;
            [IPLocalCameraSDK zoomLocalOut:1];
            
        }else
        {
            change_scale -= 0.1;
            [IPLocalCameraSDK zoomLocalOut:change_scale - 0.1];
        }
    }
    self.nowScale = change_scale;
  
}

#pragma mark - 聚焦
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.v_videoView];
    if(touchPoint.x < 0 || touchPoint.y > self.v_videoView.bounds.size.height){
        return;
    }
    [IPLocalCameraSDK manualLocalFocus:touchPoint TouchView:self.v_videoView];
 
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
    {
        if (0 <= touchPoint.x && touchPoint.x <= 0 + 0 && 0 <= touchPoint.y && touchPoint.y <= 0 )
        {
            return;
        }
    }
    
    
    self.focus_fight_image.center = touchPoint;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.focus_fight_image.hidden = NO;
        [self.focus_fight_image setTransform:CGAffineTransformScale(self.focus_fight_image.transform, 0.5, 0.5)];
        
    } completion:^(BOOL finished)
     {
         self.focus_fight_image.hidden = YES;
         [self.focus_fight_image setTransform:self.focus_fight_transfor];
     }];
        
    
}



-(void)changeCameraFrame{
    int marginx = 0;
    if(clipPubthings.deleteTop > 0){
        marginx = 44;
    }
    
    if([self deviceIsPortrait]){
        self.v_main.frame = CGRectMake(0, marginx, clipPubthings.screen_width, clipPubthings.allHeight - 2*marginx);
    }else{
        self.v_main.frame = CGRectMake(marginx, 0, clipPubthings.allHeight - 2*marginx,clipPubthings.screen_width);
    }
    self.v_videoView.frame = [self getOutPutRect:self.outputType];
    int viewWidth = self.v_main.bounds.size.width;
    int viewHeight = self.v_main.bounds.size.height;

    if([self deviceIsPortrait]){
        int between = (self.frame.size.width - 8*2 - 5*40)/4;
        self.btn_fangdou.frame =  CGRectMake(8 +(40 + between),  8, 40, 40);
        self.btn_speedChoose.frame =  CGRectMake(8 +(40 + between)*2,  8, 40, 40);
        self.btn_4k.frame = CGRectMake(8 +(40 + between)*3,  8, 40, 40);
        self.btn_camera.frame = CGRectMake(8 +(40 + between)*4,  8, 40, 40);
        
        int height1x1 = viewWidth + 56;
        self.btn_flash.frame = CGRectMake(viewWidth - 48,height1x1 - 160 - 25, 40, 40);
        self.btn_audio.frame = CGRectMake(viewWidth - 48,height1x1 - 120, 40, 40);

        self.btn_outputType.frame = CGRectMake(8, viewHeight - 81, 56, 56);
        self.btn_start.frame = CGRectMake(viewWidth/2 - 33, viewHeight - 86, 66, 66);
        self.v_imgs.frame = CGRectMake(viewWidth - 68, viewHeight - 70, 55, 35);
        
        self.v_speeds.frame = CGRectMake(self.btn_speedChoose.frame.origin.x + self.btn_speedChoose.frame.size.width/2 - 300/2, 64, 300, 50);
        self.btn_speed1.frame = CGRectMake(60*0, 0, 60, 50);
        self.btn_speed2.frame = CGRectMake(60*1, 0, 60, 50);
        self.btn_speed3.frame = CGRectMake(60*2, 0, 60, 50);
        self.btn_speed4.frame = CGRectMake(60*3, 0, 60, 50);
        self.btn_speed5.frame = CGRectMake(60*4, 0, 60, 50);
        self.img_speed.frame = CGRectMake(144, -8, 12, 8);
        self.img_speed.image = [clipPubthings imageNamed:@"qktool_record_topSpeed"];
    }else{
        int between = (viewHeight - 8*2 - 5*40)/4;
        self.btn_camera.frame =  CGRectMake(8, 8 +(40 + between)*1, 40, 40);
        self.btn_4k.frame =  CGRectMake(8, 8 +(40 + between)*2, 40, 40);
        self.btn_speedChoose.frame = CGRectMake(8,8 +(40 + between)*3,   40, 40);
        self.btn_fangdou.frame = CGRectMake(8,8 +(40 + between)*4,   40, 40);
        
        int height1x1 = viewHeight + 56;
        self.btn_flash.frame = CGRectMake(height1x1 - 160 - 25,8, 40, 40);
        self.btn_audio.frame = CGRectMake(height1x1 - 120,8, 40, 40);

        
        
        
        
        self.btn_outputType.frame =  CGRectMake(viewWidth - 93, viewHeight - 64, 56, 56);
        self.btn_start.frame = CGRectMake(viewWidth - 98, viewHeight/2 - 33, 66, 66);
        self.v_imgs.frame =  CGRectMake(viewWidth - 92, 16, 55, 35);
        self.v_speeds.frame = CGRectMake(64, self.btn_speedChoose.frame.origin.y + self.btn_speedChoose.frame.size.height/2 - 300/2, 50, 300);
        self.btn_speed1.frame = CGRectMake(0, 60*0, 50, 60);
        self.btn_speed2.frame = CGRectMake(0, 60*1, 50, 60);
        self.btn_speed3.frame = CGRectMake(0, 60*2, 50, 60);
        self.btn_speed4.frame = CGRectMake(0, 60*3, 50, 60);
        self.btn_speed5.frame = CGRectMake(0, 60*4, 50, 60);
        self.img_speed.frame = CGRectMake(-8, 144, 8, 12);
        self.img_speed.image = [clipPubthings imageNamed:@"qktool_record_leftSpeed"];

    }
    self.btn_flash.tag = kIPLocalCameraCloseFlash;
    [self.btn_flash setImage:[clipPubthings imageNamed:@"qktool_record_flashclose.png"] forState:UIControlStateNormal];

}
-(IBAction)changeOutPutType:(id)sender{
    if([IPLocalCameraSDK cameraIsRecord]){
        return;
    }
    if(self.use4K){
        [QukanAlert alertMsg:@"4K模式不支持画幅比切换"];
        return;
    }
    self.outputType++;
    self.outputType = self.outputType%3;
    self.v_videoView.frame = [self getOutPutRect:self.outputType];
    [IPLocalCameraSDK changeRenderOutPut:self.outputType];
    
}

-(CGRect)getOutPutRect:(int)type{
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;

    double scale = 0;
    switch (type) {
        case kLocalIPCameraOutputType1x1:
            scale = 1;
            [self.btn_outputType setImage:[clipPubthings imageNamed:@"qktool_record_output1x1"] forState:UIControlStateNormal];
            if([self deviceIsPortrait]){
                if(clipPubthings.deleteTop > 0){
                    return CGRectMake(0, 56 + 44, width, width);

                }else{
                    return CGRectMake(0, 56, width, width);
                }
            }else{
                if(clipPubthings.deleteTop > 0){
                    return CGRectMake(56 + 44, 0, height, height);
                }else{
                    return CGRectMake(56, 0, height, height);
                }
            }
            break;
        case kLocalIPCameraOutputType4x3:
            if([self deviceIsPortrait]){
                scale = 3.0/4;
                [self.btn_outputType setImage:[clipPubthings imageNamed:@"qktool_record_output3x4"] forState:UIControlStateNormal];

            }else{
                scale = 4.0/3;
                [self.btn_outputType setImage:[clipPubthings imageNamed:@"qktool_record_output4x3"] forState:UIControlStateNormal];

            }

            break;
            
        case kLocalIPCameraOutputType16x9:
            if([self deviceIsPortrait]){
                scale = 9.0/16;
                [self.btn_outputType setImage:[clipPubthings imageNamed:@"qktool_record_output9x16"] forState:UIControlStateNormal];

            }else{
                scale = 16.0/9;
                [self.btn_outputType setImage:[clipPubthings imageNamed:@"qktool_record_output16x9"] forState:UIControlStateNormal];

            }
            return self.bounds;
            break;
        default:
            scale = 16.0/9;
            break;
    }
    
    float fitheight = width / scale;
    
    float fitWidth = height * scale;
    if(fitheight < height){
        return CGRectMake(0, 0, width, fitheight);
        //        return CGSizeMake(width, fitheight);
    }
    //    return CGSizeMake(fitWidth, height);
    return CGRectMake(0, 0,fitWidth , height);
}



-(NSString *)stringDateToDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"MM-dd hh:mm"];
    
    return [formatter stringFromDate:date];
    
}


-(BOOL)deviceIsPortrait{
    UIInterfaceOrientation appOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (appOrientation == UIInterfaceOrientationUnknown || appOrientation == UIInterfaceOrientationPortrait|| appOrientation == UIInterfaceOrientationPortraitUpsideDown){
        return YES;
    }
    return NO;
}


-(NSString *) freeDiskSpaceInBytes{
    struct statfs buf;
    long long freespaces = -1;
    NSString *str = nil;
    
    if(statfs("/var", &buf) >= 0)
    {
        freespaces = (long long)(buf.f_bsize * buf.f_bfree);
    }
    
    long long freespace = freespaces - 200000000;
    
    if (freespace/1024*1024*1024<1)
    {
        if (freespace<=0)
        {
            str = [NSString stringWithFormat:@"0 MB"];
            
        }else
        {
            str = [NSString stringWithFormat:@"%qi MB",freespace/1024/1024];
        }
        
        QukanAlert *alert = [[QukanAlert alloc] initWithCotent:@"存储空间不足1G,请注意清理" Delegate:nil] ;
        [alert show];
        
    }else
    {
        int i = freespace/(1024*1024*1024);
        int j = freespace%(1024*1024*1024);
        int k = 0;
        
        float x = j/(1024*1024*1024.0);
        
        if ( x > 0.1 )
        {
            k = x*10;
            int w = x*100;
            
            if ((w%10)>=5)
            {
                if (k != 9)
                {
                    k= k+1;
                    
                }else
                {
                    k = 0;
                    i = i+1;
                }
            }
        }
        
        if (k>=1)
        {
            str = [NSString stringWithFormat:@"%d.%d G",i,k];
            
        }else
        {
            str = [NSString stringWithFormat:@"%d G",i];
        }
    }
    
    return str;
}


-(void)usedSpaceAndfreeSpace{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
        NSFileManager* fileManager = [[NSFileManager alloc ]init];
        NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
        NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
        NSInteger nowBitrate = (120 + 12)*100*1024/8;
        if(!_use4K){
            nowBitrate = (30 + 12)*100*1024/8;
        }
        weakSelf.liveTime = ([freeSpace longLongValue] - 400*1024*1024)/nowBitrate;
        if(weakSelf.liveTime <0){
            weakSelf.liveTime = 0;
        }
    });
}


-(void)checkFree{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
        NSFileManager* fileManager = [[NSFileManager alloc ]init];
        NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
        NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
        NSInteger M_freeSpace = [freeSpace longLongValue]/1024/1024;
        if(M_freeSpace <= 400){
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf stopRecord];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"存储空间不足，已停止录制！" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
                [alert show];
            });
            
        }
    });
}
@end
