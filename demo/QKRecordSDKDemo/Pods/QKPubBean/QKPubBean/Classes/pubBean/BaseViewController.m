//
//  BaseViewController.m
//  BeijingNews
//
//  Created by yang on 2017/8/1.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property(nonatomic) NSInteger screen_height;
@property(nonatomic) NSInteger screen_width;
@property(nonatomic) NSInteger allWidth;
@property(nonatomic) NSInteger allHeight;

@end

@implementation BaseViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hidKeyBoard];
    //状态栏占据位置
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    float allWidth = [[UIScreen mainScreen] bounds].size.width;
    float allHeight = [[UIScreen mainScreen] bounds].size.height;
    float safeTop = 20;
    float deleteTop = 0;
    float safeBottom = 0;
    // iPhone X以上设备iOS版本一定是11.0以上。
    if (@available(iOS 11.0, *)) {
        // 利用safeAreaInsets.bottom > 0.0来判断是否是iPhone X以上设备。
        UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
        if (window.safeAreaInsets.bottom > 0.0) {
            safeTop = window.safeAreaInsets.top;
            safeBottom = window.safeAreaInsets.bottom;
            deleteTop = safeTop;
        }
    }
    self.screen_width = allWidth;
    self.screen_height = allHeight - safeTop - safeBottom;
    self.allWidth = allWidth;
    self.allHeight = allHeight;

    
    self.v_maincontroller.frame = CGRectMake(0, deleteTop, self.screen_width, self.screen_height);
    if(self.top != nil){
        self.top.constant = deleteTop;
    }
    if(self.bottom != nil){
        self.bottom.constant = safeBottom;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)headRefresh{
    
}
-(void)footRefresh{
    
}



#pragma mark - 隐藏键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hidKeyBoard];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self hidKeyBoard];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}


-(void)hidKeyBoard{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    CGRect rect = [textField.superview convertRect:textField.frame toView:self.view];
    self.marginBottom = self.screen_height - 44 - rect.origin.y- rect.size.height;
    return YES;
}



- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    CGRect rect = [textView.superview convertRect:textView.frame toView:self.view];

    self.marginBottom = self.screen_height - 44 - rect.origin.y- rect.size.height;
    return YES;
}


@end
