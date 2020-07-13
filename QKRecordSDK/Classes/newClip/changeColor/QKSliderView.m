//
//  QKSilderView.m
//  QukanTool
//
//  Created by yang on 2018/6/20.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "QKSliderView.h"
#import "ClipPubThings.h"
#define imgHeight 14
@interface QKSliderView()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer        *moveGesture;

@property(strong,nonatomic) IBOutlet UILabel *lbl_slider;
@property(strong,nonatomic) IBOutlet UIImageView *img_slider;

@property(nonatomic) int img_org_y;
@end

@implementation QKSliderView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"QKSliderView1" owner:self options:nil];
        UIView *v_addName = [array firstObject];
        v_addName.frame = self.bounds;
        [self addSubview:v_addName];
        self.backgroundColor = [UIColor clearColor];
        self.maxValue = 1;
        self.minValue = 0;
        self.sliderValue = 0.5;
        //平移手势
        self.moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(moveGesture:)];
        self.moveGesture.delegate = self;
        [self addGestureRecognizer:self.moveGesture];
        self.lbl_slider.backgroundColor = clipPubthings.color;
    }
    return self;
}

-(void)setSliderValue:(double)sliderValue{
    _sliderValue = sliderValue;
    [self changeFrame];
}

-(void)setMaxValue:(double)maxValue{
    _maxValue = maxValue;
    [self changeFrame];
}
-(void)setMinValue:(double)minValue{
    _minValue = minValue;
    [self changeFrame];
}

-(void)changeFrame{
    if(_maxValue <= _minValue){
        return;
    }
    int orgY = (_sliderValue - _minValue)/(_maxValue - _minValue)*(self.frame.size.height - imgHeight) + imgHeight/2;
    int mid = [self getMidOrgY];
    self.lbl_slider.frame = CGRectMake(15,orgY, 2, mid - orgY);
    self.img_slider.frame = CGRectMake(16 - imgHeight/2, orgY - imgHeight/2, self.img_slider.frame.size.width, self.img_slider.frame.size.height);
}

-(int)getMidOrgY{
    return self.frame.size.height/2;
}



- (void)moveGesture:(UIPanGestureRecognizer*)moveGesture {

    CGPoint pointBegin = [moveGesture translationInView:self];
    if(moveGesture.state == UIGestureRecognizerStateBegan){
        CGPoint point = [moveGesture locationInView:self.img_slider];
        
        int x = point.x;
        int y = point.y;
        CGSize size = self.img_slider.frame.size;
        if(x > -15 && y > -15 && x < size.width+15 && y< size.height+15){
            self.img_org_y = self.img_slider.frame.origin.y;
        }else{
            self.img_org_y = -200;
        }
    }
  
    if (moveGesture.state == UIGestureRecognizerStateBegan ||
        moveGesture.state == UIGestureRecognizerStateChanged ||
        moveGesture.state == UIGestureRecognizerStateRecognized ||
        moveGesture.state == UIGestureRecognizerStateEnded ||
        moveGesture.state == UIGestureRecognizerStatePossible) {
        if(self.img_org_y == -200){
            return;
        }
        BOOL isEnd = (moveGesture.state == UIGestureRecognizerStateEnded);
        [self move:pointBegin isEnd:isEnd];
    }
}


- (void)move:(CGPoint)point isEnd:(BOOL)isEnd{
    
    //计算偏移量必须在河里范围内
    float y = self.img_org_y + point.y;
    double size = (self.frame.size.height - imgHeight - y)*1.0;
    NSLog(@"size:%.2lf",size);
    _sliderValue = size/(self.frame.size.height - imgHeight)*(_maxValue - _minValue) + _minValue;
    if(y <= 0){
        y = 0;
        _sliderValue = _maxValue;
    }
    if(y >= self.frame.size.height - imgHeight){
        y = self.frame.size.height - imgHeight;
        _sliderValue = _minValue;
    }
    int mid = [self getMidOrgY];
    double xifu = imgHeight/2*0.5;
    if(y + imgHeight - xifu > mid && y + xifu < mid){
        y = mid - imgHeight/2;
        _sliderValue = (_maxValue + _minValue)/ 2;
    }
    int orgY = y + imgHeight/2;
    self.lbl_slider.frame = CGRectMake(15, orgY, 2, mid - orgY);
    self.img_slider.frame = CGRectMake(16 - imgHeight/2, orgY - imgHeight/2, self.img_slider.frame.size.width, self.img_slider.frame.size.height);
    if(self.getValue){
        self.getValue(_sliderValue);
    }
}

@end
