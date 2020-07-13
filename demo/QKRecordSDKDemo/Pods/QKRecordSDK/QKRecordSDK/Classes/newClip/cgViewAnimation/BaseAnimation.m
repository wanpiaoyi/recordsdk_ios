//
//  BaseAnimation.m
//  QukanTool
//
//  Created by yang on 17/6/23.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "BaseAnimation.h"
#import "FlyFromRight.h"
#import "AddTitleAnimation.h"
#import "AddTitleAnimationKuang.h"
#import "FlyToTop.h"
#import "FlyFromLeftAndEndRight.h"
#import "FlyFromLeft.h"
#import "AutoInAndAutoOut.h"
#import "JustAutoOut.h"
#import "FlyDownAndEndUp.h"
#import "FlyRightTopAndBottom.h"
@interface BaseAnimation ()




@end

@implementation BaseAnimation

-(void)setMainView:(UIView*)mainView contentView:(UIView*)contentView screenWidth:(double)screenWidth viewNeedHid:(UIView*)needHidView duringTime:(double)duringTime{
    self.mainView = mainView;
    self.contentView = contentView;
    self.rect_mainView = mainView.frame;
    self.rect_contentView = contentView.frame;
    self.screenWidth = screenWidth;
    self.needHiddenView = needHidView;
    self.scale = 0;
    self.duringTime = duringTime;
}

-(void)resetPauseFrame{
    self.mainView.frame = self.rect_mainView;
    self.contentView.frame = self.rect_contentView;
    self.contentView.alpha = 1;
    self.mainView.alpha = 1;
}

-(UIImage*)getViewToImage:(float)scale time:(double)animationTime
{
    self.mainView.hidden = NO;
    self.needHiddenView.hidden = YES;
    
    if(animationTime < self.imgStartTime + self.imgDuring && animationTime > self.imgStartTime &&self.scale == scale){
        if(self.img != nil){
            return self.img;
        }
    }
    
    
    
    self.scale = scale;
    [self changeAnimation:animationTime];
    
    CGSize s = self.mainView.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, scale);
    [self.mainView.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imgStartTime = 0;
    self.imgDuring = 50;

    
    return self.img;
}





-(void)changeAnimation:(double)animationtime{

}


-(NSString*)getAnimationTime:(double)animationTime{
    return @"BaseAnimation100";
}




-(CGRect)checkDrawRect:(double)animationTime{
    return CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);;
}



-(NSString*)aniMationName{
    
    return @"BaseAnimation";
}


+(BaseAnimation*)getAnimationByName:(NSString *)aniMationName{
    if([aniMationName isEqualToString:@"BaseAnimation"]){
        return [[BaseAnimation alloc] init];
    }
    if([aniMationName isEqualToString:@"FlyFromRight"]){
        return [[FlyFromRight alloc] init];
    }
    if([aniMationName isEqualToString:@"FlyToTop"]){
        return [[FlyToTop alloc] init];
    }
    
    if([aniMationName isEqualToString:@"AddTitleAnimation"]){
        return [[AddTitleAnimation alloc] init];
    }
    if([aniMationName isEqualToString:@"AddTitleAnimationKuang"]){
        return [[AddTitleAnimationKuang alloc] init];
    }
    
    if([aniMationName isEqualToString:@"FlyFromLeftAndEndRight"]){
        return [[FlyFromLeftAndEndRight alloc] init];
    }
    if([aniMationName isEqualToString:@"FlyFromLeft"]){
        return [[FlyFromLeft alloc] init];
    }
    if([aniMationName isEqualToString:@"AutoInAndAutoOut"]){
        return [[AutoInAndAutoOut alloc] init];
    }
    if([aniMationName isEqualToString:@"JustAutoOut"]){
        return [[JustAutoOut alloc] init];
    }
    if([aniMationName isEqualToString:@"FlyDownAndEndUp"]){
        return [[FlyDownAndEndUp alloc] init];
    }
    if([aniMationName isEqualToString:@"FlyRightTopAndBottom"]){
        return [[FlyRightTopAndBottom alloc] init];
    }
    
    NSLog(@"匹配动画名称的时候未找到:%@",aniMationName);
    return [[FlyFromRight alloc] init];
}

@end
