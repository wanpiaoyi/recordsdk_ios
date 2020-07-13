//
//  MovieView.m
//  QukanTool
//
//  Created by yang on 2017/9/30.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "MovieView.h"

//static MovieView *moveView = nil;
@interface MovieView()<UIGestureRecognizerDelegate>{
    
    CGPoint prevPoint;
    CGRect prevRect;
}
@property (nonatomic, strong) UIPanGestureRecognizer        *moveGesture;
//@property BOOL choose;

@end


@implementation MovieView

-(id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //平移手势
        self.moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(moveGesture:)];
        self.moveGesture.delegate = self;
        [self addGestureRecognizer:self.moveGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        tapGesture.numberOfTapsRequired = 1; //点击次数
        tapGesture.numberOfTouchesRequired = 1; //点击手指数
        [self addGestureRecognizer:tapGesture];

    }
    return self;
}

//轻击手势触发方法
-(void)tapGesture:(UITapGestureRecognizer *)sender
{
    
//    if(moveView != nil && moveView != self){
//        moveView.choose = NO;
//    }
//    self.choose = YES;
//    moveView = self;
}

#pragma mark - UIGesture

- (void)moveGesture:(UIPanGestureRecognizer*)moveGesture {
    if(!self.canMove){
        return;
    }
    CGRect supreRect = [self superview].frame;
    if (moveGesture.state == UIGestureRecognizerStateBegan){
        prevPoint = [moveGesture locationInView:self];
        CGPoint point = prevPoint;
        prevRect = self.frame;
    }
    if (moveGesture.state == UIGestureRecognizerStateEnded){
    
    }
    CGPoint point = [moveGesture translationInView:self];
    if (moveGesture.state == UIGestureRecognizerStateBegan ||
        moveGesture.state == UIGestureRecognizerStateChanged ||
        moveGesture.state == UIGestureRecognizerStateRecognized ||
        moveGesture.state == UIGestureRecognizerStatePossible) {
        CGRect nowFrame = CGRectMake(prevRect.origin.x + point.x, prevRect.origin.y + point.y, prevRect.size.width, prevRect.size.height);
        self.frame = nowFrame;
        ViewFrameChanged frameChanged = self.frameChanged;
        if(frameChanged){
            frameChanged(nowFrame);
        }
    }

}

@end
