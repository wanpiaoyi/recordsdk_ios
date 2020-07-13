//
//  QKRecordViewController.m
//  QKLiveSDK_Example
//
//  Created by yangpeng on 2020/7/7.
//  Copyright © 2020 quklive. All rights reserved.
//

#import "QKRecordViewController.h"
#import "LocalOrSystemVideos.h"
#import "ClipPubThings.h"
#import "QukanAlert.h"

#import "VideoManager.h"
#import "ChooseLocalLive.h"

@interface QKRecordViewController ()
@property(strong,nonatomic) IBOutlet UITextField *fld_appkey;
@property BOOL appkeySeted;
@end


@implementation QKRecordViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //状态栏占据位置
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
   [self.navigationController setNavigationBarHidden:NO animated:NO];

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
     
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad {
    [super viewDidLoad];
  
    videoManager.liveVideoShow = false;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(QkRecordAppKeyReturn:)
                                                 name:@"QkRecordAppKeyReturn"
                                               object:nil];
}

-(IBAction)hidKeyboard:(id)sender{
    [self.view endEditing:YES];
}

//设置appkey并且登录
-(IBAction)setRecordAppkey:(id)sender{
    [self.view endEditing:YES];
    NSString *appkey = self.fld_appkey.text;
    if(appkey==nil||[appkey isKindOfClass:[NSNull class]]||[appkey isEqualToString:@""]){
        QukanAlert *alert =[[QukanAlert alloc] initWithCotent:@"请输入appkey" Delegate:nil];
        [alert show];
        return;
    }
    [clipPubthings initAppkey:@"CxzjTbAmbVoKU6kv" nav:self.navigationController];
}

//验证appkey
- (void)QkRecordAppKeyReturn:(NSNotification *)notification {
    id not = [notification object];
    //判断获取到的数据是否正常
    if(not!=nil&&[not isKindOfClass:[NSDictionary class]]){
        NSDictionary *data = [notification object];
        NSString *code = [NSString stringWithFormat:@"%@",[data objectForKey:@"code"]];
        NSString *msg = [NSString stringWithFormat:@"%@",[data objectForKey:@"msg"]];
        if([code isEqualToString:@"0"])
        {
            self.appkeySeted = YES;
            //appkey验证通过后执行的方法
            [pgToast setText:@"Appkey 设置成功"];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] ;
            [alert show];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"Appkey验证有问题" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] ;
        [alert show];
    }
    
}

//录播
-(IBAction)startRecord:(id)sender{
    if(!self.appkeySeted){
        [QukanAlert alertMsg:@"请设置appkey"];
        return;
    }
    [clipPubthings startLocalRecord];
}


//录制列表
-(IBAction)showRecord:(id)sender{
    if(!self.appkeySeted){
        [QukanAlert alertMsg:@"请设置appkey"];
        return;
    }
    ChooseLocalLive *live = [[ChooseLocalLive alloc] init];
    [self.navigationController pushViewController:live animated:YES];
}

//选择本地视频或者其他视频
-(IBAction)movieEdict:(id)sender{
    if(!self.appkeySeted){
        [QukanAlert alertMsg:@"请设置appkey"];
        return;
    }
    [LocalOrSystemVideos getVideos:^(NSArray *array) {
        [clipPubthings showClipController:array];
    } copyFile:2 showimg:YES justOne:NO showVideo:YES];
}


@end
