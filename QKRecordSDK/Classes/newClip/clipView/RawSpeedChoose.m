//
//  RawSpeedChoose.m
//  QukanTool
//
//  Created by yang on 2018/6/19.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "RawSpeedChoose.h"
#import "QKMoviePart.h"
#import "ClipPubThings.h"

@interface RawSpeedChoose()
@property(strong,nonatomic) IBOutlet UIView *v_lines;
@property(strong,nonatomic) IBOutlet UILabel *lbl_speed;
@property(strong,nonatomic) IBOutlet UIButton *btn_speed;
@property int btn_org_x;

@property (nonatomic, strong) UIPanGestureRecognizer        *moveGesture;

@property int selectSpeed;

@end
@implementation RawSpeedChoose

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        UIView *v_main = [[[clipPubthings clipBundle] loadNibNamed:@"RawSpeedChoose1" owner:self options:nil] lastObject];
        v_main.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:v_main];
        
        [self initLines];
        self.selectSpeed = 9;
        
        
        [self changeBtnSpeed:self.selectSpeed];
        self.canChangeSpeed = YES;
        //平移手势
        self.moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(moveGesture:)];
        self.moveGesture.delegate = self;
        [self addGestureRecognizer:self.moveGesture];
    }
    return self;
}

-(void)initLines{
    int margin = [self marginWidth];
    for(int i = 0; i < lineCounts;i++){
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(13 + margin*i, 9, 2, 8)];
        lbl.backgroundColor = [UIColor colorWithRed:46/255.0 green:46/255.0 blue:46/255.0 alpha:1.0];
        [self.v_lines insertSubview:lbl atIndex:0];
    }
}

-(int)marginWidth{
    int margin = (self.v_lines.frame.size.width - self.btn_speed.frame.size.width)/(lineCounts - 1);
    return margin;
}


- (void)moveGesture:(UIPanGestureRecognizer*)moveGesture {
    NSLog(@"moveGesture");

    CGPoint pointBegin = [moveGesture translationInView:self];
    if(moveGesture.state == UIGestureRecognizerStateBegan){

        CGPoint point = [moveGesture locationInView:self.btn_speed];
        
        int x = point.x;
        int y = point.y;
        CGSize size = self.btn_speed.frame.size;
//        if(x > -30 && y > -30 && x < size.width+30 && y< size.height+30){
            self.btn_org_x = self.btn_speed.frame.origin.x;
//            [self.btn_speed setBackgroundImage:[clipPubthings imageNamed:@""] forState:UIControlStateNormal];
//        }else{
//            self.btn_org_x = -100;
//        }
    }
    if (moveGesture.state == UIGestureRecognizerStateBegan ||
        moveGesture.state == UIGestureRecognizerStateChanged ||
        moveGesture.state == UIGestureRecognizerStateRecognized ||
        moveGesture.state == UIGestureRecognizerStateEnded ||
        moveGesture.state == UIGestureRecognizerStatePossible) {
        if(self.btn_org_x == -100){
            return;
        }
        BOOL isEnd = (moveGesture.state == UIGestureRecognizerStateEnded);
        [self move:pointBegin isEnd:isEnd];
    }
}


- (void)move:(CGPoint)point isEnd:(BOOL)isEnd{
    if(!self.canChangeSpeed){
        return;
    }
    //计算偏移量必须在河里范围内
    float pointx = point.x;
    int margin = [self marginWidth];

    int selectSpeed = self.selectSpeed + pointx / margin;
    if(selectSpeed < 1){
        selectSpeed = 1;
    }else{
        if(selectSpeed > lineCounts){
            selectSpeed = lineCounts;
        }
    }
    NSLog(@"self.selectSpeed：%d pointx:%.2lf margin:%d",selectSpeed,pointx,margin);
    [self changeBtnSpeed:selectSpeed];
    if(isEnd){
        self.selectSpeed = selectSpeed;
        if(self.changeSpeed){
            self.changeSpeed(selectSpeed);
        }
    }
 
}

-(void)showNowSpeed:(int)speedType{
    self.selectSpeed = speedType;
    [self changeBtnSpeed:speedType];
}

-(void)changeBtnSpeed:(int)speedType{
    int margin = [self marginWidth];
    int x = self.v_lines.frame.origin.x + (speedType - 1) * margin + 1;
    self.btn_speed.frame = CGRectMake(x, self.btn_speed.frame.origin.y, self.btn_speed.frame.size.width, self.btn_speed.frame.size.height);
    self.lbl_speed.frame = CGRectMake(x + self.btn_speed.frame.size.width/2 - self.lbl_speed.frame.size.width/2, self.lbl_speed.frame.origin.y, self.lbl_speed.frame.size.width, self.lbl_speed.frame.size.height);
    NSString *str = @"原速";
    int speedMid = (lineCounts + 1)/2;
    if(speedType == speedMid){
        str = @"原速";
    }else if(speedType < speedMid){
        str = [NSString stringWithFormat:@"慢放%.1lf倍",(speedMid - speedType)*0.5];
    }else{
        str = [NSString stringWithFormat:@"快放%.1lf倍",(speedType - speedMid)*0.5];
    }
    self.lbl_speed.text = str;
    
}

@end
