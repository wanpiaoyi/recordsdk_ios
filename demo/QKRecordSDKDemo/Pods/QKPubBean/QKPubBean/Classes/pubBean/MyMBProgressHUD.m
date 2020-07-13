//
//  MyMBProgressHUD.m
//  qukan
//
//  Created by wang macmini on 13-7-5.
//  Copyright (c) 2013年 tan lidong. All rights reserved.
//

#import "MyMBProgressHUD.h"
#import "MBProgressHUD.h"

@implementation MyMBProgressHUD

+ (void) ProgressHUD : (NSString*) str Type : (CGFloat) Pm
{
#ifdef TestProject
    return;
#endif
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:HUD];

    HUD.labelText = str;
    HUD.mode = MBProgressHUDModeText;
    
    if (Pm != 0)
    {
        CGAffineTransform at = CGAffineTransformMakeRotation(Pm);
        [HUD setTransform:at];
    }
    
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
    }];
}

@end
