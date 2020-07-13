//
//  BaseAnimation.h
//  QukanTool
//
//  Created by yang on 17/6/23.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BaseAnimation : NSObject

@property(strong,nonatomic) UIView *mainView;
@property(strong,nonatomic) UIView *contentView;
@property(strong,nonatomic) UIView *needHiddenView;
@property double screenWidth;
@property CGRect rect_mainView;
@property CGRect rect_contentView;

@property float duringTime;

@property(strong,nonatomic) UIImage *img;
@property float imgStartTime;
@property float imgDuring;

@property float scale;


-(void)setMainView:(UIView*)mainView contentView:(UIView*)contentView screenWidth:(double)screenWidth viewNeedHid:(UIView*)needHidView duringTime:(double)duringTime;

-(void)changeAnimation:(double)animationTime;
-(NSString*)getAnimationTime:(double)animationTime;
-(UIImage*)getViewToImage:(float)scale time:(double)animationTime;
-(CGRect)checkDrawRect:(double)animationTime;


-(void)resetPauseFrame;

-(NSString*)aniMationName;
+(BaseAnimation*)getAnimationByName:(NSString*)aniMationName;
@end
