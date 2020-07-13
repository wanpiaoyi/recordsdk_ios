//
//  Commav.m
//  QukanTool
//
//  Created by yang on 16/4/5.
//  Copyright © 2016年 yang. All rights reserved.
//

#import "Commav.h"
#import <QKLiveAndRecord/IPLocalCameraSDK.h>
#import "LiveLocalController.h"
@interface Commav ()

@end

@implementation Commav

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 是否允许旋转 IOS6
-(BOOL)shouldAutorotate
{
    if([IPLocalCameraSDK cameraIsRecord]){
        return NO;
    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIViewController *view = [self.viewControllers lastObject];
    
    NSLog(@"横竖屏发生变化通知SDK");
    [IPLocalCameraSDK setAppOrientation:[UIApplication sharedApplication].statusBarOrientation];
    if ([view isKindOfClass:[LiveLocalController class]]){
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{

    return UIInterfaceOrientationPortrait;
}
@end
