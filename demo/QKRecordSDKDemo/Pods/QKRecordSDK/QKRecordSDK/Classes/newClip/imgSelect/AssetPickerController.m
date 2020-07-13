//
//  AssetPickerController.m
//  PingTu
//
//  Created by Yangfan on 15/2/4.
//  Copyright (c) 2015年 4gread. All rights reserved.
//

#import "AssetPickerController.h"

@interface AssetPickerController ()
@end

@implementation AssetPickerController

- (id)init {
    AssetGroupViewController *groupViewController =
        [[AssetGroupViewController alloc] init];
    if (self = [super initWithRootViewController:groupViewController]) {
        _assetsFilter = [ALAssetsFilter allAssets];
//        NSLog(@"[ALAssetsFilter allAssets]8");
        _showEmptyGroups = NO;
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UINavigationBar *bar = [UINavigationBar appearance];

    //设置显示的颜色

    bar.barTintColor = [UIColor whiteColor];

    //设置字体颜色

    bar.tintColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    [bar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0],NSFontAttributeName:font}];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (@available(iOS 13.0, *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];

    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    [self.navigationBar setBarStyle:UIBarStyleBlack];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
