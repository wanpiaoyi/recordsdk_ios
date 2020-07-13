//
//  AddTitleAnimation.m
//  QukanTool
//
//  Created by yang on 17/6/23.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "AddTitleAnimation.h"
@interface AddTitleAnimation ()

@property(strong,nonatomic) UILabel *lbl_top;
@property(strong,nonatomic) UILabel *lbl_bottom;


@end
@implementation AddTitleAnimation

-(id)init{
    if(self = [super init]){
        self.lbl_top = [[UILabel alloc] init];
        self.lbl_top.backgroundColor = [UIColor whiteColor];
        self.lbl_top.hidden = NO;
        self.lbl_bottom = [[UILabel alloc] init];
        self.lbl_bottom.backgroundColor = [UIColor whiteColor];
        self.lbl_bottom.hidden = NO;
        self.duringTime = 4;
    }
    return self;
}

-(void)setMainView:(UIView*)mainView contentView:(UIView*)contentView screenWidth:(double)screenWidth viewNeedHid:(UIView *)needHidView duringTime:(double)duringTime{
    [super setMainView:mainView contentView:contentView screenWidth:screenWidth viewNeedHid:needHidView duringTime:duringTime];
    
    mainView.frame = CGRectMake(mainView.frame.origin.x - 30, mainView.frame.origin.y, mainView.frame.size.width + 60, mainView.frame.size.height);
    self.rect_mainView = mainView.frame;
    
    contentView.frame = CGRectMake(contentView.frame.origin.x + 30, contentView.frame.origin.y, contentView.frame.size.width, contentView.frame.size.height);
    self.rect_contentView = contentView.frame;

    self.lbl_top.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y + self.rect_contentView.size.height/2-1, self.rect_contentView.size.width + 60, 2);
    self.lbl_bottom.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y + self.rect_contentView.size.height/2-1, self.rect_contentView.size.width + 60, 2);
    [mainView addSubview:self.lbl_top];
    [mainView addSubview:self.lbl_bottom];
    self.scale = 0;
}

-(void)changeAnimation:(double)animationtime{
    float useAnimation = animationtime;
    float deleteTime = 0;
    //飞进
    if(useAnimation <= 0.4){
        if(useAnimation > 0.3){
            useAnimation = 0.3;
        }
        deleteTime = 0;
        self.mainView.frame = CGRectMake(self.rect_mainView.origin.x + (self.screenWidth - self.rect_mainView.origin.x) *(1 -(useAnimation - deleteTime) / 0.3), self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
        self.lbl_top.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y + self.rect_contentView.size.height/2-1, self.rect_contentView.size.width + 60, 2);
        self.lbl_bottom.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y + self.rect_contentView.size.height/2-1, self.rect_contentView.size.width + 60, 2);
        self.contentView.alpha = 0;
        self.mainView.alpha = 1;
        return;
    }

    //展开
    if(useAnimation > 0.4 && useAnimation <= 0.8){
        if(useAnimation > 0.7){
            useAnimation = 0.7;
        }
        deleteTime = 0.4;
        self.mainView.frame = CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
        self.lbl_top.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y + self.rect_contentView.size.height/2-1 - (self.rect_contentView.size.height/2 -1)*(useAnimation - deleteTime) / 0.3, self.rect_contentView.size.width + 60, 2);
        self.lbl_bottom.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y + self.rect_contentView.size.height/2 -1 +(self.rect_contentView.size.height/2 -1)*(useAnimation - deleteTime) / 0.3, self.rect_contentView.size.width + 60, 2);
        self.contentView.alpha = 0;
        self.mainView.alpha = 1;
        return;
    }
    

    //淡入
    if(useAnimation > 0.8 && useAnimation <= 1.2){
        if(useAnimation > 1.1){
            useAnimation = 1.1;
        }
        deleteTime = 0.8;
        self.mainView.frame = CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
        self.lbl_top.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y , self.rect_contentView.size.width + 60, 2);
        self.lbl_bottom.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y + self.rect_contentView.size.height -2, self.rect_contentView.size.width + 60, 2);
        
        self.contentView.alpha = 1 * (useAnimation - deleteTime) / 0.3;
        self.mainView.alpha = 1;
        return;
    }
    //持续
    if(useAnimation > 1.2 && useAnimation <= 1.6){
        if(useAnimation > 1.6){
            useAnimation = 1.5;
        }
        deleteTime = 1.2;

        self.mainView.frame = CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
        self.lbl_top.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y , self.rect_contentView.size.width + 60, 2);
        self.lbl_bottom.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y + self.rect_contentView.size.height -2, self.rect_contentView.size.width + 60, 2);
        self.contentView.alpha = 1;
        self.mainView.alpha = 1;
        return;
    }
    //淡出
    if(useAnimation > 1.6 && useAnimation <= 2.0){
        if(useAnimation > 1.9){
            useAnimation = 1.9;
        }
        deleteTime = 1.6;

        self.mainView.frame = CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
        self.lbl_top.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y , self.rect_contentView.size.width + 60, 2);
        self.lbl_bottom.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y + self.rect_contentView.size.height -2, self.rect_contentView.size.width + 60, 2);
        self.contentView.alpha = 1;
        self.mainView.alpha = 1 - (useAnimation - deleteTime) / 0.3;
        return;
    }
    
    self.mainView.alpha = 0;
}

-(NSString*)getAnimationTime:(double)animationTime{
    float useAnimation = animationTime;
    
    if((animationTime > 1.2 && animationTime <= 1.6)||animationTime<0){
        return @"flyright100";
    }
    if(animationTime > 2.0){
        return @"flyright101";
    }
    return [NSString stringWithFormat:@"addtitle%.2lf",useAnimation];

}


-(UIImage*)getViewToImage:(float)scale time:(double)animationTime{
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
    
    if(animationTime <= 0.4){
        self.imgStartTime = 0;
        self.imgDuring = 0.4;
    }else  if(animationTime > 1.2 && animationTime <= 1.6){
        self.imgStartTime = 1.2;
        self.duringTime = 0.4;
    }else{
        self.imgStartTime = -1;
        self.duringTime = -1;
    }
    
    return self.img;
}

-(CGRect)checkDrawRect:(double)animationTime{
    float useAnimation = animationTime;
    
    if(useAnimation <= 0.4){
        if(useAnimation > 0.3){
            useAnimation = 0.3;
        }
        return CGRectMake(self.rect_mainView.origin.x + (self.screenWidth - self.rect_mainView.origin.x) *(1 -useAnimation/ 0.3), self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
    }
    
    return CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);;
}


-(NSString*)aniMationName{
    return @"AddTitleAnimation";
}
-(void)resetPauseFrame{
    self.mainView.frame = self.rect_mainView;
    self.contentView.frame = self.rect_contentView;
    self.contentView.alpha = 1;
    self.mainView.alpha = 1;
    self.lbl_top.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y , self.rect_contentView.size.width + 60, 2);
    self.lbl_bottom.frame = CGRectMake(self.rect_contentView.origin.x - 30, self.rect_contentView.origin.y + self.rect_contentView.size.height -2, self.rect_contentView.size.width + 60, 2);
}


@end
