//
//  FlyToTop.m
//  QukanTool
//
//  Created by yang on 2017/7/14.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "FlyToTop.h"

@implementation FlyToTop
-(id)init{
    if(self = [super init]){
        self.duringTime = 4;
    }
    return self;
}

-(void)setMainView:(UIView*)mainView contentView:(UIView*)contentView screenWidth:(double)screenWidth viewNeedHid:(UIView *)needHidView duringTime:(double)duringTime{
    [super setMainView:mainView contentView:contentView screenWidth:screenWidth viewNeedHid:needHidView duringTime:duringTime];
    self.scale = 0;
}

-(void)changeAnimation:(double)animationtime{
    float useAnimation = animationtime;

    
    //飞进
    if(useAnimation > 0.6){
        useAnimation = 0.6;
    }
    float logoAnimation = useAnimation/0.6;

    
    
    self.mainView.frame = CGRectMake(self.rect_mainView.origin.x, self.rect_mainView.origin.y +self.rect_mainView.size.height * (1 - logoAnimation ), self.mainView.frame.size.width, self.mainView.frame.size.height);
    self.mainView.alpha = logoAnimation;
    //        NSLog(@"self.mainView.frame:%@",NSStringFromCGRect(self.mainView.frame));

    
}

-(NSString*)getAnimationTime:(double)animationTime{
    float useAnimation = animationTime;
    
    if(useAnimation <= 0.7 && useAnimation > 0){
        return [NSString stringWithFormat:@"FlyToTop%.2lf",useAnimation];
    }
    return @"FlyToTop100";
}

-(UIImage*)getViewToImage:(float)scale time:(double)animationTime{
    self.mainView.hidden = NO;
    self.needHiddenView.hidden = YES;
    if(animationTime < self.imgStartTime + self.imgDuring && animationTime > self.imgStartTime &&self.scale == scale){
        if(self.img != nil){
            return self.img;
        }
    }
    self.mainView.hidden = NO;
    self.scale = scale;
    [self changeAnimation:animationTime];
    
    CGSize s = self.mainView.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, scale);
    [self.mainView.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(animationTime >= 0.7){
        self.imgStartTime = 0.7;
        self.imgDuring = 50;
    }else{
        self.imgStartTime = -1;
        self.duringTime = -1;
    }
    
    return self.img;
}

-(CGRect)checkDrawRect:(double)animationTime{
    float useAnimation = animationTime;
    
    //飞进
    if(useAnimation > 0.6){
        useAnimation = 0.6;
    }
    float logoAnimation = useAnimation/0.6;
    
    return CGRectMake(self.rect_mainView.origin.x, self.rect_mainView.origin.y +self.rect_mainView.size.height * (1 - logoAnimation ), self.mainView.frame.size.width, self.mainView.frame.size.height);
}

-(NSString*)aniMationName{
    
    return @"FlyToTop";
}

@end
