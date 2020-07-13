//
//  FlyFromRight.m
//  QukanTool
//
//  Created by yang on 17/6/23.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "FlyFromRight.h"

@implementation FlyFromRight
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
    if(useAnimation <= 0.4){
        if(useAnimation > 0.3){
            useAnimation = 0.3;
        }
        self.mainView.frame = CGRectMake(self.rect_mainView.origin.x + (self.screenWidth - self.rect_mainView.origin.x) *(1 -useAnimation / 0.3), self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
//        NSLog(@"self.mainView.frame:%@",NSStringFromCGRect(self.mainView.frame));
        return;
    }
    self.mainView.frame = CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);

}

-(NSString*)getAnimationTime:(double)animationTime{
    float useAnimation = animationTime;

    if(useAnimation <= 0.4 && useAnimation > 0){
        return [NSString stringWithFormat:@"flyright%.2lf",useAnimation];
    }
    return @"flyright100";
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
    self.imgStartTime = 0;
    self.imgDuring = 200;
    return self.img;
}

-(CGRect)checkDrawRect:(double)animationTime{
    float useAnimation = animationTime;
    
    if(useAnimation <= 0.4){
        if(useAnimation > 0.3){
            useAnimation = 0.3;
        }
        return CGRectMake(self.rect_mainView.origin.x + (self.screenWidth - self.rect_mainView.origin.x) *(1 -useAnimation / 0.3), self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
    }
    
    return CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);;
}

-(NSString*)aniMationName{
    
    return @"FlyFromRight";
}

@end
