//
//  FlyRightTopAndBottom.m
//  QukanTool
//
//  Created by yang on 2017/11/5.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "FlyRightTopAndBottom.h"

@interface FlyRightTopAndBottom()
@property(weak,nonatomic) UILabel *lbl_top;
@property(weak,nonatomic) UILabel *lbl_bottom;
@property CGRect topRect;
@property CGRect bottomRect;
@end
@implementation FlyRightTopAndBottom
-(id)init{
    if(self = [super init]){
    }
    return self;
}

-(void)setMainView:(UIView*)mainView contentView:(UIView*)contentView screenWidth:(double)screenWidth viewNeedHid:(UIView *)needHidView duringTime:(double)duringTime{
    [super setMainView:mainView contentView:contentView screenWidth:screenWidth viewNeedHid:needHidView duringTime:duringTime];
    self.scale = 0;
    self.lbl_top = nil;
    self.lbl_bottom = nil;
    for(UIView *v in contentView.subviews){
        if([v isKindOfClass:[UILabel class]]){
            if(self.lbl_top == nil){
                self.lbl_top = (UILabel*)v;
                self.topRect = self.lbl_top.frame;
            }else{
                self.lbl_bottom = (UILabel*)v;
                self.bottomRect = self.lbl_bottom.frame;
            }
            NSLog(@"FlyRightTopAndBottomFlyRightTopAndBottom");
        }
    }
}

-(void)changeAnimation:(double)animationtime{
    float useAnimation = animationtime;
    //飞进
    if(useAnimation <= 0.4){
        if(useAnimation > 0.3){
            useAnimation = 0.3;
        }
        self.lbl_top.alpha = 0;
        self.lbl_bottom.alpha = 0;
        self.mainView.frame = CGRectMake( -self.mainView.frame.size.width+(self.rect_mainView.origin.x+self.mainView.frame.size.width)*useAnimation / 0.3, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
        //        NSLog(@"self.mainView.frame:%@",NSStringFromCGRect(self.mainView.frame));
        return;
    }
    if(useAnimation <= 0.8){
        if(useAnimation > 0.7){
            useAnimation = 0.7;
        }
        float time = useAnimation - 0.4;
        self.lbl_top.frame = CGRectMake(self.topRect.origin.x, self.topRect.origin.y + self.topRect.size.height*(time - 0.3)/0.3, self.topRect.size.width, self.topRect.size.height);
        self.lbl_top.alpha = time/0.3;
        
        self.lbl_bottom.frame = CGRectMake(self.bottomRect.origin.x, self.bottomRect.origin.y + self.bottomRect.size.height*(0.3 - time)/0.3, self.bottomRect.size.width, self.bottomRect.size.height);
        self.lbl_bottom.alpha = time/0.3;
  
        self.mainView.alpha = 1;
        self.mainView.frame = CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
        return;
    }
    
    if(useAnimation >self.duringTime-0.4){
        float time = useAnimation - self.duringTime + 0.4;
//        NSLog(@"time:%.3f",time);
        if(time > 0.3){
            time = 0.3;
        }
        self.lbl_top.alpha = 1;
        self.lbl_bottom.alpha = 1;
        self.mainView.alpha = (0.3 - time)/0.3;
        self.mainView.frame = CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
        
        return;
    }
    
    self.lbl_top.alpha = 1;
    self.lbl_bottom.alpha = 1;
    self.lbl_top.frame = self.topRect;
    self.lbl_bottom.frame = self.bottomRect;
    self.mainView.alpha = 1;
    self.mainView.frame = CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
    
}

-(NSString*)getAnimationTime:(double)animationTime{
    float useAnimation = animationTime;
    
    if(useAnimation <= 0.8 && useAnimation > 0){
        return [NSString stringWithFormat:@"FlyRightTopAndBottom%.2lf",useAnimation];
    }
    if(useAnimation <= self.duringTime && useAnimation > self.duringTime - 0.4){
        return [NSString stringWithFormat:@"FlyRightTopAndBottom%.2lf",useAnimation];
    }
    return @"FlyRightTopAndBottom100";
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
    if(animationTime >= 0.8){
        self.imgStartTime = 0.8;
        self.imgDuring = self.duringTime - 0.4-0.8;
    }else{
        self.imgStartTime = 0;
        self.imgDuring = 0;
    }
    return self.img;
}

-(CGRect)checkDrawRect:(double)animationTime{
    float useAnimation = animationTime;
    
    if(useAnimation <= 0.4){
        if(useAnimation > 0.3){
            useAnimation = 0.3;
        }
        return CGRectMake( -self.mainView.frame.size.width+(self.rect_mainView.origin.x+self.mainView.frame.size.width)*useAnimation / 0.3, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
        //        NSLog(@"self.mainView.frame:%@",NSStringFromCGRect(self.mainView.frame));
    }
    
    return CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);;
}

-(void)resetPauseFrame{
    self.mainView.frame = self.rect_mainView;
    self.contentView.frame = self.rect_contentView;
    self.contentView.alpha = 1;
    self.mainView.alpha = 1;
    self.lbl_top.frame = self.topRect;
    self.lbl_bottom.frame = self.bottomRect;
    self.lbl_top.alpha = 1;
    self.lbl_bottom.alpha = 1;

}


-(NSString*)aniMationName{
    
    return @"FlyRightTopAndBottom";
}
@end
