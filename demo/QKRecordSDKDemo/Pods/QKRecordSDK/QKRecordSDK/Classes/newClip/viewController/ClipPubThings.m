//
//  ClipPubThings.m
//  QukanTool
//
//  Created by yang on 2019/2/1.
//  Copyright © 2019 yang. All rights reserved.
//

#import "ClipPubThings.h"
#import "QKClipController.h"
#import "ShortMovieFinish.h"
#import "LiveLocalController.h"
#import "HeaderFile.h"
#import "QukanAlert.h"
#import "OSSSqlite.h"

#import "QKMoviePart.h"

#import <QKLiveAndRecord/IPLocalCameraSDK.h>
#define logoPath @"logo/logo.png"
@implementation ClipPubThings


+(ClipPubThings *)sharePubThings{
    static dispatch_once_t once;
    static ClipPubThings *sharedView;
    dispatch_once(&once, ^ {
        
        sharedView = [[ClipPubThings alloc] init];
        
    });
    return sharedView;
}


-(id)init{
    self = [super init];
    if(self){
        self.allWidth = [[UIScreen mainScreen] bounds].size.width;
        self.allHeight = [[UIScreen mainScreen] bounds].size.height;
        self.screen_width = [[UIScreen mainScreen] bounds].size.width;
        self.screen_height = [[UIScreen mainScreen] bounds].size.height;
        self.color = [UIColor colorWithRed:71/255.0 green:134/255.0 blue:255/255.0 alpha:1.0];
        // 开始启动的时候，默认不然私有云还是公有云，都使用公有云的地址（在用户选择了私有云并填写appkey成功之后，在将所有的地址换成私有云）
        if(self.screen_height < self.screen_width){
            self.screen_height = [[UIScreen mainScreen] bounds].size.width;
            self.screen_width = [[UIScreen mainScreen] bounds].size.height;
            
            self.allHeight = [[UIScreen mainScreen] bounds].size.width;
            self.allWidth = [[UIScreen mainScreen] bounds].size.height;
            
        }
        self.deleteTop = 0;
        // iPhone X以上设备iOS版本一定是11.0以上。
        if(self.screen_height == 812){
            self.screen_height = self.screen_height - 58;
            self.deleteTop = 24;
            self.deleteBottom = 34;
        }
        else if (@available(iOS 11.0, *)) {
            // 利用safeAreaInsets.bottom > 0.0来判断是否是iPhone X以上设备。
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (window.safeAreaInsets.bottom > 0.0) {
                NSLog(@"=================是");
                self.screen_height = self.screen_height - window.safeAreaInsets.bottom - (window.safeAreaInsets.top - 20);
                self.deleteTop = window.safeAreaInsets.top - 20;
                self.deleteBottom = window.safeAreaInsets.bottom;
            } else {
                NSLog(@"=================不是");
            }
        } else {
            NSLog(@"=================不是");
        }
        

        
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        self.pressfixPath = path;

          
        NSFileManager *file = [NSFileManager defaultManager];
        
        {
            NSString *tempPath = [NSString stringWithFormat:@"%@/%@",path,localRecordType];
            //创建录像文件目录
            if (![file fileExistsAtPath:tempPath])
            {
                [file createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
        {
            NSString *tempPath = [NSString stringWithFormat:@"%@/musicPcm",path];
            //创建录像文件目录
            if (![file fileExistsAtPath:tempPath])
            {
                [file createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
        {
            NSString *tempPath = [NSString stringWithFormat:@"%@/logo",path];
            //创建录像文件目录
            if (![file fileExistsAtPath:tempPath])
            {
                [file createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
        
          
          {
              NSString *tempPath = [NSString stringWithFormat:@"%@/%@",path,@"Temp"];
              //创建录像文件目录
              if (![file fileExistsAtPath:tempPath])
              {
                  [file createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
              }
          }
          {
              NSString *tempPath = [NSString stringWithFormat:@"%@/%@",path,@"compressvideo"];
              //创建录像文件目录
              if (![file fileExistsAtPath:tempPath])
              {
                  [file createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
              }
          }
          {
              NSString *filePath = [NSString stringWithFormat:@"%@/%@",path,recordpath];
              //创建录像文件目录
              if (![file fileExistsAtPath:filePath])
              {
                  [file createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
              }
          }
        
            {
                NSString *filePath = [NSString stringWithFormat:@"%@/LocalAudio",path];
                //创建录像文件目录
                if (![file fileExistsAtPath:filePath])
                {
                    [file createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
                }
            }
        [self initRecordListen];

    }
    return self;
}
-(UIWindow*)window{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    return window;
}

-(void)setLogo:(UIImage *)logo{
    if(logo == nil || logo.size.width == 0 || logo.size.height == 0){
        _logo = nil;
        return;
    }
    _logo = logo;
    NSString *pressfixPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",pressfixPath,logoPath];
    NSData *imgData = UIImagePNGRepresentation(logo);
    BOOL write = [imgData writeToFile:filePath atomically:YES];
    if(write){
        NSLog(@"writed");
    }
}

-(NSString*)getLogoPath{
    return logoPath;
}

-(void)initAppkey:(NSString *)appkey nav:(UINavigationController*)nav{
    [IPLocalCameraSDK initSdkSaveLog:0];
    [IPLocalCameraSDK initAppkey:appkey];
    self.nav = nav;
}

-(void)showHUD{
    if (self.hud == nil)
    {
        self.hud = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication].delegate window]] ;
    }
    
    self.hud.labelText = nil;
    
    
    [[[UIApplication sharedApplication].delegate window]  addSubview:self.hud];
    [self.hud show:YES];
}
-(void)showHUD_Login:(NSString *)str
{
    if (self.hud == nil)
    {
        self.hud = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication].delegate window]] ;
    }
    
    self.hud.labelText = str;
    
    
    [[[UIApplication sharedApplication].delegate window]  addSubview:self.hud];
    [self.hud show:YES];
}

-(void)hideHUD
{
    if (self.hud == nil)
    {
        return;
    }
    [self.hud removeFromSuperview];
    
    self.hud = nil;
    NSLog(@"hideHUD");
}




-(void)startLocalRecord{
    if(![self getcamera]){
        return;
    }
    [self goDirCamera];
}






-(BOOL)getcamera{
    BOOL incamera = YES;
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            // 用户同意获取数据
        } else {
            // 可以显示一个提示框告诉用户这个app没有得到允许？
        }
    }];
    
    NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    // This status is normally not visible—the AVCaptureDevice class methods for discovering devices do not return devices the user is restricted from accessing.
    
    if(authStatus ==AVAuthorizationStatusRestricted||authStatus == AVAuthorizationStatusDenied){
        
        // The user has explicitly denied permission for media capture.
        
        NSLog(@"Denied");     //应该是这个，如果不允许的话
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                              
                                                        message:@"请在设备的设置-隐私-相机中允许访问相机。"
                              
                                                       delegate:self
                              
                                              cancelButtonTitle:@"确定"
                              
                                              otherButtonTitles:nil];
        
        [alert show];
        
        incamera = NO;
        return incamera;
        
    }
    
    else if(authStatus == AVAuthorizationStatusAuthorized){//允许访问
        
        // The user has explicitly granted permission for media capture, or explicit user permission is not necessary for the media type in question.
        incamera = YES;
        
        NSLog(@"Authorized");
        
        
        
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        
        // Explicit user permission is required for media capture, but the user has not yet granted or denied such permission.
        incamera = NO;
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            
            if(granted){//点击允许访问时调用
                
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                //                [self goDirCamera];
                NSLog(@"Granted access to %@", mediaType);
                
            }
            
            else {
                
                NSLog(@"Not granted access to %@", mediaType);
                
            }
            
            
            
        }];
        
    }else {
        incamera = NO;
        
        NSLog(@"Unknown authorization status");
        
    }
    
    
    return incamera;
}



-(void)goDirCamera{
    
    NSArray *arr = self.nav.viewControllers;
    
    UIViewController *tempVC = [self.nav.viewControllers objectAtIndex:[arr count]-1];
    if([tempVC isKindOfClass:[LiveLocalController class]]){
        return;
    }
    LiveLocalController *live = [[LiveLocalController alloc] init];
    live.saveToPhoto = NO;
    live.saveLocalRecord = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.nav pushViewController:live animated:YES];
//        [appDelegate.nav presentViewController:live animated:YES completion:nil];

    });
    
}




-(UILabel*)getTitleLable
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20];
    return label;
}


//统一导航栏右边按钮点击效果
-(UIButton*)getRightButton{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[self imageNamed:@"qukan4_nav_8811"] forState:UIControlStateNormal];
    
    btn.frame = CGRectMake(0, 0, 60, 40);
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btn setTitleColor:[UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    return btn;
}

//统一导航栏右边按钮点击效果
-(UIButton*)getLeftButton{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[self imageNamed:@"qukan4_nav_8811"] forState:UIControlStateNormal];
    
    btn.frame = CGRectMake(0, 0, 60, 40);
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setTitleColor:[UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    return btn;
}



-(void)showClipController:(NSArray*)array{
    NSInteger hasCantEdictView = 1;
    NSMutableArray *array_new = [[NSMutableArray alloc] init];
    for(id data in array){
        if([data isKindOfClass:[RecordData class]]){
            RecordData *record = data;
            NSInteger canEdict = [record canEdict];
            if(canEdict == 1){
                [array_new addObject:data];
            }else{
                hasCantEdictView = canEdict;
            }
        }else{
            QKMoviePart *part = data;
            NSInteger canEdict = [part.data canEdict];

            if(part.data != nil && canEdict){
                [array_new addObject:data];
            }else{
                hasCantEdictView = canEdict;
            }
        }
    }
    
    if(hasCantEdictView == -1){
        [QukanAlert alertMsg:@"视频有误无法编辑"];
    }else if(hasCantEdictView == 0){
        [QukanAlert alertMsg:@"设备暂不支持4k视频编辑"];
    }
    
    if(array_new.count > 0){
        QKClipController *clipVideos= [[QKClipController alloc] init:array_new];
        clipVideos.saveLocalVideo = YES;
        [self.nav pushViewController:clipVideos animated:YES];
    }
}

-(void)showVideoOrAudio:(NSString*)str{
   ShortMovieFinish *finish = [[ShortMovieFinish alloc] init];
   finish.address = str;
   [self.nav pushViewController:finish animated:YES];
}

-(NSBundle*)clipBundle{
    if(self.bundle == nil){
        NSBundle *cbundle = [NSBundle bundleForClass:[self class]];
        NSString *path = [cbundle pathForResource:@"QKRecordSDK" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        self.bundle = bundle;

    }

    return self.bundle;
}

-(void)initRecordListen{
    [self setRecordUrl:^(NSString * _Nonnull path) {
          QKVideoBean *bean = [QKVideoBean getVideoByAddress:path];
          [ossSynch insertLiveLocal:bean.fileName address:path time:0 type:localRecordType activityId:@(0)];
      }];

      /*
       在QKClipController saveLocalVideo设置为YES的时候回调
       */
      [self setCompleteUrl:^(NSString *path) {
          QKVideoBean *bean = [QKVideoBean getVideoByAddress:path];
          [ossSynch insertLiveLocal:bean.fileName address:path time:0 type:clipType activityId:@(0)];

      }];
      
      [self setLogo:[self imageNamed:@"qukan31_logo1"]];

}
-(UIImage*)imageNamed:(NSString*)name{
    NSBundle *bundle = [self clipBundle];
    return [UIImage imageNamed:name  inBundle:bundle compatibleWithTraitCollection:nil];
}
@end
