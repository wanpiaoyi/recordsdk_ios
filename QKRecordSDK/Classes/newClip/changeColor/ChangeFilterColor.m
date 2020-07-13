//
//  ChangeFilterColor.m
//  QukanTool
//
//  Created by yang on 2018/6/20.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "ChangeFilterColor.h"
#import "QKSliderView.h"
#import "ClipPubThings.h"

@interface ChangeFilterColor()

@property(strong,nonatomic) IBOutlet UIView *v_brightness;//亮度
@property(strong,nonatomic) IBOutlet UIView *v_contrast;//对比度
@property(strong,nonatomic) IBOutlet UIView *v_saturation;//饱和度
@property(strong,nonatomic) IBOutlet UIView *v_sharpness;//锐度
@property(strong,nonatomic) IBOutlet UIView *v_hue;//色调设置色调 0 ~ 360
@property(strong,nonatomic) IBOutlet UIButton *btn_sure;//色调设置色调 0 ~ 360
@property(strong,nonatomic) QKColorFilterGroup *group;
@end

@implementation ChangeFilterColor

-(id)initWithFrame:(CGRect)frame group:(QKColorFilterGroup*)group
{
    self = [super initWithFrame:frame];
    if(self){
        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"ChangeFilterColor1" owner:self options:nil];
        UIView *v_addName = [array firstObject];
        v_addName.frame = self.bounds;
        [self addSubview:v_addName];
        if(group == nil){
            group = [QKColorFilterGroup getDefaultFilterGroup];
        }
        self.group = group;

        WS(weakSelf);
        //亮度
        {
            QKSliderView *brightness = [[QKSliderView alloc] initWithFrame:self.v_brightness.bounds];
            brightness.maxValue = 1.0;
            brightness.minValue = -1.0;
            brightness.sliderValue = self.group.brightness;
            [brightness setGetValue:^(double valueChanged) {
                if(weakSelf.group.brightness != valueChanged){
                    weakSelf.group.brightness = valueChanged;
                    if(weakSelf.change){
                        weakSelf.change(weakSelf.group);
                    }
                }
            }];
            [self.v_brightness addSubview:brightness];
        }
        
        //对比度 0.0 to 4.0
        {
            QKSliderView *contrast = [[QKSliderView alloc] initWithFrame:self.v_contrast.bounds];
            contrast.maxValue = 1.0;
            contrast.minValue = 0.0;
            
            float contrastValue = 0.5;
            if(self.group.contrast == 1){
                contrastValue = 0.5;
            }else if(self.group.contrast < 1){
                contrastValue = self.group.contrast/2;
            }else{
                contrastValue = (self.group.contrast - 1)/6 + 0.5;
            }
            contrast.sliderValue = contrastValue;

            
            
            [contrast setGetValue:^(double valueChanged) {
                if(valueChanged == 0.5){
                    valueChanged = 1;
                }else if(valueChanged < 0.5){
                    valueChanged = valueChanged*2;
                }else{
                    valueChanged = 1+(valueChanged - 0.5)/0.5*3;
                }
                if(weakSelf.group.contrast != valueChanged){
                    weakSelf.group.contrast = valueChanged;
                    if(weakSelf.change){
                        weakSelf.change(weakSelf.group);
                    }
                }
            }];
            [self.v_contrast addSubview:contrast];
        }
    
        //饱和度 0.0 (fully desaturated) to 2.0
        {
            QKSliderView *saturation = [[QKSliderView alloc] initWithFrame:self.v_saturation.bounds];
            saturation.maxValue = 2.0;
            saturation.minValue = 0.0;
            saturation.sliderValue = self.group.saturation;
            [saturation setGetValue:^(double valueChanged) {
                if(weakSelf.group.saturation != valueChanged){
                    weakSelf.group.saturation = valueChanged;
                    if(weakSelf.change){
                        weakSelf.change(weakSelf.group);
                    }
                }
            }];
            [self.v_saturation addSubview:saturation];
        }
        
        //锐度 -4.0 to 4.0
        {
            QKSliderView *sharpness = [[QKSliderView alloc] initWithFrame:self.v_sharpness.bounds];
            sharpness.maxValue = 4.0;
            sharpness.minValue = -4.0;
            sharpness.sliderValue = self.group.sharpness;
            [sharpness setGetValue:^(double valueChanged) {
                if(weakSelf.group.sharpness != valueChanged){
                    weakSelf.group.sharpness = valueChanged;
                    if(weakSelf.change){
                        weakSelf.change(weakSelf.group);
                    }
                }
            }];
            [self.v_sharpness addSubview:sharpness];
        }
        
        
        /**
         * 设置色调 0 ~ 360
         * @param hue
         */
        {
            QKSliderView *hue = [[QKSliderView alloc] initWithFrame:self.v_hue.bounds];
            hue.maxValue = 180.0;
            hue.minValue = -179.0;
            if(self.group.hue < 180){
                hue.sliderValue = -self.group.hue;

            }else if(self.group.hue > 180){
                hue.sliderValue = 360 - self.group.hue;

            }else{
                hue.sliderValue = self.group.hue;
            }
            [hue setGetValue:^(double valueChanged) {
                if(valueChanged < 0){
                    valueChanged = -valueChanged;
                }else if(valueChanged > 0){
                    valueChanged = 360 - valueChanged;
                }
                valueChanged = valueChanged;
                if(weakSelf.group.hue != valueChanged){
                    weakSelf.group.hue = valueChanged;
                    if(weakSelf.change){
                        weakSelf.change(weakSelf.group);
                    }
                }
            }];
            [self.v_hue addSubview:hue];
        }
        [self.btn_sure setTitleColor:clipPubthings.color forState:UIControlStateNormal];
    }
    return self;
}
-(IBAction)close:(id)sender{
    if(self.closeView){
        self.closeView(CloseViewTypeNormal);
    }
    [self removeFromSuperview];
}



@end
