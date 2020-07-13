//
//  QukanAlert.m
//  MobileIPC
//
//  Created by chenyu on 13-11-7.
//  Copyright (c) 2013年 ReNew. All rights reserved.
//

#import "QukanAlert.h"
@implementation QukanAlert

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

-(id)initWithCotent:(NSString *)content Delegate:(NSObject *)object
{
    if([content isEqualToString:@"网络连接超时，请稍后再试"]||[content isEqualToString:@"您的网络不给力哦"]){
        self.content=content;        
    }
    self = [super initWithTitle:@"提示" message:content delegate:object cancelButtonTitle:@"确定" otherButtonTitles:nil];
    if (self)
    {
        self.orientationFlay = 0;
        
    }
    return self;
}

/*
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}
*/

-(void)show
{
    
    if(self.content!=nil&&([self.content isEqualToString:@"网络连接超时，请稍后再试"]||[self.content isEqualToString:@"您的网络不给力哦"])){
        return;
        
    }
    
    [super show];
    //弹出对话框的方向控制
//    if (self.orientationFlay == 1)
//    {
//        if ([[UIDevice currentDevice] orientation] ==  UIDeviceOrientationLandscapeLeft)
//        {
//            self.transform = CGAffineTransformMakeRotation(M_PI_2);
//            
//        }else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
//        {
//            self.transform = CGAffineTransformMakeRotation(-M_PI_2);
//        }
//    }
    
}




+(void)alertMsg:(NSString*)msg{
    QukanAlert *alert = [[QukanAlert alloc] initWithCotent:msg Delegate:nil];
    [alert show];
}

@end
