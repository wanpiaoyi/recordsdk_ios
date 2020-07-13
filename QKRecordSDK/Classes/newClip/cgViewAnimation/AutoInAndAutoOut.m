//
//  AutoInAndAutoOut.m
//  QukanTool
//
//  Created by yang on 2017/11/3.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "AutoInAndAutoOut.h"

@implementation AutoInAndAutoOut
-(id)init{
    if(self = [super init]){
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
        float time = useAnimation ;
//        NSLog(@"time:%.3f",time);
        if(time > 0.3){
            time = 0.3;
        }
        self.mainView.alpha = time/0.3;
        return;
    }
    if(useAnimation >self.duringTime-0.4){
        float time = useAnimation - self.duringTime + 0.4;
//        NSLog(@"time:%.3f",time);
        if(time > 0.3){
            time = 0.3;
        }
        self.mainView.alpha = (0.3 - time)/0.3;
        return;
    }
    self.mainView.alpha = 1;
    self.mainView.frame = CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
    
}

-(NSString*)getAnimationTime:(double)animationTime{
    float useAnimation = animationTime;
    
    if(useAnimation <= 0.4 && useAnimation > 0){
        return [NSString stringWithFormat:@"AutoInAndAutoOut%.2lf",useAnimation];
    }
    if(useAnimation <= self.duringTime && useAnimation > self.duringTime - 0.4){
        return [NSString stringWithFormat:@"AutoInAndAutoOut%.2lf",useAnimation];
    }
    return @"AutoInAndAutoOut100";
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
    if(animationTime >= 0.4){
        self.imgStartTime = 0.4;
        self.imgDuring = self.duringTime - 0.4-0.4;
    }else{
        self.imgStartTime = 0;
        self.imgDuring = 0;
    }
    return self.img;
}

-(CGRect)checkDrawRect:(double)animationTime{

    
    return CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);;
}

-(NSString*)aniMationName{
    
    return @"AutoInAndAutoOut";
}
@end
