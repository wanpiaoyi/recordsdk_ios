//
//  LocalCameraView.h
//  QukanTool
//
//  Created by yang on 2018/7/3.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "LiveLocalController.h"

@interface LocalCameraView : UIView{
    NSInteger count_hour ;
    NSInteger count_minute ;
    NSInteger count_second ;

}

@property(strong,nonatomic) IBOutlet UIButton *btn_speedChoose;
@property(strong,nonatomic) IBOutlet UIButton *btn_speed1; //较慢
@property(strong,nonatomic) IBOutlet UIButton *btn_speed2; //慢
@property(strong,nonatomic) IBOutlet UIButton *btn_speed3; //正常
@property(strong,nonatomic) IBOutlet UIButton *btn_speed4; //快
@property(strong,nonatomic) IBOutlet UIButton *btn_speed5; //较快
@property(strong,nonatomic) IBOutlet UIView *v_speeds; //速度列表
@property(strong,nonatomic) IBOutlet UIImageView *img_speed; 


@property(strong,nonatomic) IBOutlet UIButton *btn_camera; //相机
@property(strong,nonatomic) IBOutlet UIButton *btn_outputType; //画幅比
@property(strong,nonatomic) IBOutlet UIButton *btn_start; //开始按钮

@property(strong,nonatomic) IBOutlet UIButton *btn_flash; //闪光灯
@property(strong,nonatomic) IBOutlet UIButton *btn_fangdou; //防抖
@property(strong,nonatomic) IBOutlet UIButton *btn_audio; //声音
@property(strong,nonatomic) IBOutlet UIButton *btn_4k; //声音


@property(strong,nonatomic) IBOutlet UIView *v_imgs; //图片列表
@property(strong,nonatomic) IBOutlet UIImageView *img1; //图片列表
@property(strong,nonatomic) IBOutlet UIImageView *img2; //图片列表
@property(strong,nonatomic) IBOutlet UIImageView *img3; //图片列表

@property (strong, nonatomic) UIImageView *focus_fight_image;
@property CGAffineTransform focus_fight_transfor;

@property NSInteger liveTime;
@property BOOL stabilization;
@property NSInteger img_count;
@property BOOL saveLocalRecord;
@property BOOL saveToPhoto;

-(void)changeCameraFrame;
-(void)stopRecord;
- (void)initCamera;
-(void)stopCamera;
@property(copy,nonatomic) changeLocalState changeState;
//按下home键时候触发
- (void)applicationDidEnterBackground:(NSNotification *)notification;

- (void)applicationDidBecomeActive:(NSNotification *)notification;

-(void)removeAllRecords;
@end
