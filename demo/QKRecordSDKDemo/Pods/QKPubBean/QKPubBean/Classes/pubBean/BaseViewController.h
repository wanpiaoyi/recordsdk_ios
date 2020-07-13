//
//  BaseViewController.h
//  BeijingNews
//
//  Created by yang on 2017/8/1.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property(strong,nonatomic) IBOutlet UIView *v_maincontroller;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *top;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottom;

@property NSInteger marginBottom;

-(IBAction)back:(id)sender;

-(void)hidKeyBoard;
-(void)headRefresh;
-(void)footRefresh;
@end
