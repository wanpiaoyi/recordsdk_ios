//
//  AddTitleAnimationKuang.m
//  QukanTool
//
//  Created by yang on 2017/7/11.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "AddTitleAnimationKuang.h"
#import "ClipPubThings.h"
#define oneImgWith 15
@interface AddTitleAnimationKuang ()

@property(strong,nonatomic) UIImageView *img_leftTop;
@property(strong,nonatomic) UIImageView *img_leftBottom;
@property(strong,nonatomic) UIImageView *img_rightTop;
@property(strong,nonatomic) UIImageView *img_rightBottom;
@property(strong,nonatomic) UIView *v_background;
@property(weak,nonatomic) UIView *superView;
@property CGRect rect_background;
@end
@implementation AddTitleAnimationKuang

-(id)init{
    if(self = [super init]){
        self.img_leftTop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        self.img_leftTop.image = [clipPubthings imageNamed:@"qktool_img_lefttop"];
        
        self.img_leftBottom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        self.img_leftBottom.image = [clipPubthings imageNamed:@"qktool_img_leftbottom"];

        self.img_rightTop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        self.img_rightTop.image = [clipPubthings imageNamed:@"qktool_img_righttop"];

        self.img_rightBottom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        self.img_rightBottom.image = [clipPubthings imageNamed:@"qktool_img_rightbottom"];

        self.v_background = [[UIView alloc] init];
        self.v_background.backgroundColor = [UIColor clearColor];
        self.duringTime = 2;
    }
    return self;
}


-(void)setMainView:(UIView*)mainView contentView:(UIView*)contentView screenWidth:(double)screenWidth viewNeedHid:(UIView *)needHidView duringTime:(double)duringTime{
    [super setMainView:mainView contentView:contentView screenWidth:screenWidth viewNeedHid:needHidView duringTime:duringTime];
    
    mainView.frame = CGRectMake(mainView.frame.origin.x - oneImgWith, mainView.frame.origin.y - oneImgWith, mainView.frame.size.width + oneImgWith * 2, mainView.frame.size.height + oneImgWith * 2);
    self.rect_mainView = mainView.frame;
    
    contentView.frame = CGRectMake(contentView.frame.origin.x + oneImgWith, contentView.frame.origin.y + oneImgWith, contentView.frame.size.width, contentView.frame.size.height);
    self.rect_contentView = contentView.frame;
    
    self.v_background.frame = CGRectMake(contentView.frame.origin.x - oneImgWith, contentView.frame.origin.y - oneImgWith, contentView.frame.size.width + oneImgWith * 2, contentView.frame.size.height + oneImgWith * 2);
    self.rect_background = self.v_background.frame;
    self.img_leftTop.frame = CGRectMake(0, 0, 14, 14);
    self.img_leftBottom.frame = CGRectMake(0, self.v_background.frame.size.height - 14, 14, 14);
    self.img_rightTop.frame = CGRectMake(self.v_background.frame.size.width - 14, 0, 14, 14);
    self.img_rightBottom.frame = CGRectMake(self.v_background.frame.size.width - 14, self.v_background.frame.size.height - 14, 14, 14);
    
    [self.v_background addSubview:self.img_leftTop];
    [self.v_background addSubview:self.img_leftBottom];
    [self.v_background addSubview:self.img_rightTop];
    [self.v_background addSubview:self.img_rightBottom];
    [self.mainView insertSubview:self.v_background atIndex:0];
    self.scale = 0;
}
-(void)changeAnimation:(double)animationTime{
    UIView *v = self.mainView.superview;
    if(v == nil){
        return ;
    }
    if(self.superView != v){
        self.superView = v;
        self.mainView.frame = CGRectMake(0, self.mainView.frame.origin.y, self.superView.frame.size.width, self.superView.frame.size.height);
        self.rect_mainView = CGRectMake(0, self.mainView.frame.origin.y, self.superView.frame.size.width, self.mainView.frame.size.height);
        
        self.contentView.frame = CGRectMake((self.rect_mainView.size.width - self.rect_contentView.size.width)/ 2, self.rect_contentView.origin.y, self.rect_contentView.size.width, self.rect_contentView.size.height);
        self.rect_contentView = self.contentView.frame;
        
        self.v_background.frame = CGRectMake(self.contentView.frame.origin.x - oneImgWith, self.contentView.frame.origin.y - oneImgWith, self.contentView.frame.size.width + oneImgWith * 2, self.contentView.frame.size.height + oneImgWith * 2);
        self.rect_background = self.v_background.frame;
    }
    
//    float useAnimation = animationTime;
    float kuangAnimation = animationTime / 1;
    if(kuangAnimation > 1){
        kuangAnimation = 1;
    }
    self.v_background.frame = CGRectMake(self.rect_contentView.origin.x - oneImgWith + (self.rect_mainView.size.width - (self.rect_contentView.origin.x - oneImgWith))*(1 - kuangAnimation), self.rect_contentView.origin.y - oneImgWith, self.rect_contentView.size.width + oneImgWith * 2, self.contentView.frame.size.height + oneImgWith * 2);
    self.v_background.alpha = kuangAnimation;
    
    float logoAnimation = animationTime / 2;
    if(logoAnimation > 1){
        logoAnimation = 1;
    }
    self.contentView.frame = CGRectMake((self.rect_mainView.size.width - self.rect_contentView.size.width)/ 2 * logoAnimation, self.rect_contentView.origin.y, self.rect_contentView.size.width, self.rect_contentView.size.height);
    self.contentView.alpha = logoAnimation;

}

-(NSString*)getAnimationTime:(double)animationTime{

    if(animationTime > 2.0){
        return @"AddTitleAnimationKuang100";
    }
    return [NSString stringWithFormat:@"AddTitleAnimationKuang%.2lf",animationTime];
    
}


-(UIImage*)getViewToImage:(float)scale time:(double)animationTime{
    self.mainView.hidden = NO;
    self.needHiddenView.hidden = YES;
    self.v_background.hidden = NO;
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
    
    if(animationTime >= 2){
        self.imgStartTime = 2;
        self.imgDuring = 2;
    }else{
        self.imgStartTime = -1;
        self.imgDuring = -1;
    }
//        else  if(animationTime > 1.2 && animationTime <= 1.6){
//        self.imgStartTime = 1.2;
//        self.duringTime = 0.4;
//    }else{
//        self.imgStartTime = -1;
//        self.duringTime = -1;
//    }
    
    return self.img;
}

-(CGRect)checkDrawRect:(double)animationTime{
//    float useAnimation = animationTime;
//    
//    if(useAnimation <= 0.4){
//        if(useAnimation > 0.3){
//            useAnimation = 0.3;
//        }
//        return CGRectMake(self.rect_mainView.origin.x + (self.screenWidth - self.rect_mainView.origin.x) *(1 -useAnimation/ 0.3), self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
//    }
    
    return CGRectMake(self.rect_mainView.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);;
}


-(NSString*)aniMationName{
    return @"AddTitleAnimationKuang";
}
-(void)resetPauseFrame{
    self.mainView.frame = self.rect_mainView;
    self.contentView.frame = self.rect_contentView;
    self.contentView.alpha = 1;
    self.mainView.alpha = 1;
    self.v_background.alpha = 1;
    self.v_background.hidden = NO;
    self.v_background.frame = self.rect_background;
}

@end
