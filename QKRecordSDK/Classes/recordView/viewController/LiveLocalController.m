//
//  LiveLocalController.m
//  QukanTool
//
//  Created by yang on 2018/7/4.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "LiveLocalController.h"
#import "LocalCameraView.h"
#import <QKLiveAndRecord/IPLocalCameraSDK.h>
#import "ClipPubThings.h"
#import "QukanAlert.h"

@interface LiveLocalController ()
@property(strong,nonatomic) LocalCameraView *cameraView;

@property(strong,nonatomic) IBOutlet UIButton *btn_back;

@end

@implementation LiveLocalController
-(void)loadView{
    // Initialization code
    [[[clipPubthings clipBundle]  loadNibNamed:@"LiveLocalController" owner:self options:nil] lastObject];

}

#pragma mark - home键
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//按下home键时候触发
- (void)applicationDidEnterBackground:(NSNotification *)notification

{
    [self.cameraView applicationDidEnterBackground:notification];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self.cameraView applicationDidBecomeActive:notification];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //状态栏占据位置
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated{

    [self.view insertSubview:self.cameraView atIndex:0];
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil]; //监听是否触发home键挂起程序.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序.
    
    WS(weakSelf);
    self.cameraView = [[LocalCameraView alloc] initWithFrame:CGRectMake(0, 0, clipPubthings.allWidth, clipPubthings.allHeight)];
    self.cameraView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    [self.cameraView setChangeState:^(enum changeState state) {
        switch (state) {
            case changeLocalStateHidden:
                weakSelf.btn_back.hidden = YES;
                break;
            case changeLocalStateShow:
                weakSelf.btn_back.hidden = NO;
                break;
            case changeLocalStateClose:
                [weakSelf back:nil];
                break;
            default:
                break;
        }
    }];
    self.cameraView.saveLocalRecord = self.saveLocalRecord;
    self.cameraView.saveToPhoto = self.saveToPhoto;
    if([self deviceIsPortrait]){
        if(clipPubthings.deleteTop > 0){
            self.btn_back.frame = CGRectMake(8, 8 + 44, 40, 40);
        }else{
            self.btn_back.frame = CGRectMake(8, 8, 40, 40);
        }
    }else{
        if(clipPubthings.deleteTop > 0){
            self.btn_back.frame = CGRectMake(8 + 44, clipPubthings.allWidth - 48 , 40, 40);
        }else{
            self.btn_back.frame = CGRectMake(8,  clipPubthings.allWidth - 48, 40, 40);
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back:(id)sender{
    @autoreleasepool {

        if([IPLocalCameraSDK cameraIsRecord]){
            [QukanAlert alertMsg:@"请先停止录制"];
            return;
        }
        if(sender != nil && !self.saveLocalRecord){
            [self.cameraView removeAllRecords];
        }
        [self.cameraView stopCamera];
        //重置视频的方向，用于控制屏幕旋转
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = 0;
            
            val = AVCaptureVideoOrientationPortrait;
            
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
        if(sender == nil){
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    };
}
//横竖屏切换时修改界面
-(void)changeCameraFrame{

    
    if([self deviceIsPortrait]){
        int marginx = 0;
        if(clipPubthings.deleteTop > 0){
            marginx = 44;
        }
        [self.btn_back setTransform:CGAffineTransformMakeRotation(0)];

        self.btn_back.frame = CGRectMake(8, 8 + marginx, 40, 40);
    }else{
        int height1x1 = clipPubthings.screen_width + 56;

        if(clipPubthings.deleteTop > 0){
            self.btn_back.frame = CGRectMake(8 + 44, clipPubthings.allWidth - 48 , 40, 40);
            height1x1 = height1x1 + 44;
        }else{
            self.btn_back.frame = CGRectMake(8,  clipPubthings.allWidth - 48, 40, 40);
        }

        
        [self.btn_back setTransform:CGAffineTransformMakeRotation(-M_PI/2)];

    }
    [self.cameraView changeCameraFrame];
}


-(BOOL)deviceIsPortrait{
    UIInterfaceOrientation appOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (appOrientation == UIInterfaceOrientationUnknown || appOrientation == UIInterfaceOrientationPortrait|| appOrientation == UIInterfaceOrientationPortraitUpsideDown){
        return YES;
    }
    return NO;
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.cameraView changeCameraFrame];
}


- (BOOL)shouldAutorotate

{
    if([IPLocalCameraSDK cameraIsRecord]){
        return NO;
    }
    return YES;

}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSLog(@"横竖屏发生变化通知SDK");
    [IPLocalCameraSDK setAppOrientation:[UIApplication sharedApplication].statusBarOrientation];
    return UIInterfaceOrientationMaskAllButUpsideDown;

}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation

{
    return UIInterfaceOrientationPortrait;
}


@end
