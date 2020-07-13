//
//  PGToastView.m
//  qukan4
//
//  Created by chenyu on 14/12/22.
//  Copyright (c) 2014年 ReNew. All rights reserved.
//

#import "PGToastView.h"
#import "PubBundle.h"
#import "NSString+Size.h"

@interface PGToastView()

@property(nonatomic) NSInteger screen_height;
@property(nonatomic) NSInteger screen_width;
@property(nonatomic) NSInteger allWidth;
@property(nonatomic) NSInteger allHeight;

@end

@implementation PGToastView



+ (PGToastView*)getPgtoast {
    static dispatch_once_t once;
    static PGToastView *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

-(id)initWithFrame:(CGRect)frame {
    
     if ((self = [super initWithFrame:frame])) {
        self.lbl_toast = [[UILabel alloc] init];
        self.lbl_toast.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.lbl_toast.textColor = [UIColor whiteColor];
        self.lbl_toast.font = [UIFont systemFontOfSize:14.0];
        self.lbl_toast.layer.cornerRadius = 2.0;
        [self.lbl_toast setNumberOfLines:0];
        self.lbl_toast.clipsToBounds = YES;
        self.lbl_toast.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lbl_toast];
        self.hidtimer = 0;
        self.istrans = NO;
         self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
         
         self.v_finish = [[UIView alloc] initWithFrame:CGRectMake(0, 0,100, 85)];
         self.v_finish.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
         self.v_finish.layer.cornerRadius = 2.0;
         self.lbl_finishToast = [[UILabel alloc] initWithFrame:CGRectMake(0,33,100, 52)];
         self.lbl_finishToast.textAlignment = NSTextAlignmentCenter;
         self.lbl_finishToast.backgroundColor = [UIColor clearColor];
         self.lbl_finishToast.textColor = [UIColor whiteColor];
         self.lbl_finishToast.font = [UIFont systemFontOfSize:14.0];
         UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(36, 16, 28, 28)];
         img.image = [UIImage imageNamed:@"qk_export_success_icon"  inBundle:[PubBundle bundle] compatibleWithTraitCollection:nil];
         [self.v_finish addSubview:img];
         [self.v_finish addSubview:self.lbl_finishToast];
         [self addSubview:self.v_finish];
         self.v_finish.hidden = YES;
         
         float allWidth = [[UIScreen mainScreen] bounds].size.width;
         float allHeight = [[UIScreen mainScreen] bounds].size.height;
         float safeTop = 20;
         float safeBottom = 0;
         // iPhone X以上设备iOS版本一定是11.0以上。
         if (@available(iOS 11.0, *)) {
             // 利用safeAreaInsets.bottom > 0.0来判断是否是iPhone X以上设备。
             UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
             if (window.safeAreaInsets.bottom > 0.0) {
                 safeTop = window.safeAreaInsets.top;
                 safeBottom = window.safeAreaInsets.bottom;
             }
         }
         self.screen_width = allWidth;
         self.screen_height = allHeight - safeTop - safeBottom;
         self.allWidth = allWidth;
         self.allHeight = allHeight;
    }
    return self;
}

-(void)setText:(NSString *)str{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.v_finish.hidden = YES;
        self.lbl_toast.hidden = NO;

        if(self.istrans == YES){
            self.istrans = NO;
            CGAffineTransform at = CGAffineTransformMakeRotation(0);
            [self.lbl_toast setTransform:at];
        }
        
        CGSize size = [self getLblSize:[UIFont systemFontOfSize:14.0] width:(self.allWidth - 120) height:MAXFLOAT str:str];
        float height =size.height;
        if(height>300){
            height = 300;
        }
        self.lbl_toast.frame = CGRectMake((self.screen_width-size.width-30)/2, (self.allHeight-height-50)/2, size.width+30, height+30);
        self.lbl_toast.text = str;
        UIWindow *window = [[UIApplication sharedApplication].windows lastObject];

        [window addSubview:self];
        
        self.hidtimer = 1.5;
        if(self.logoTimer==nil||![self.logoTimer isValid]){
            self.logoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidToast:) userInfo:nil repeats:YES];
        }
        
    });
                   
}


-(void)setFinishText:(NSString *)str{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.v_finish.hidden = NO;
        self.lbl_toast.hidden = YES;
        
        self.lbl_finishToast.text = str;
        CGSize size = self.v_finish.frame.size;
        self.v_finish.frame = CGRectMake((self.screen_width-size.width)/2, (self.allHeight-size.height-20)/2, size.width, size.height);

        
        UIWindow *window = [[UIApplication sharedApplication].windows lastObject];

        [window addSubview:self];
        
        self.hidtimer = 1.5;
        if(self.logoTimer==nil||![self.logoTimer isValid]){
            self.logoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidToast:) userInfo:nil repeats:YES];
        }
        
    });
                   
}

-(void)setHenText:(NSString *)str{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.v_finish.hidden = YES;
        self.lbl_toast.hidden = NO;
        if(!self.istrans){
            self.istrans = YES;
            
            [self.lbl_toast setTransform:CGAffineTransformMakeRotation(M_PI/2)];
        }
        
        CGSize size = [self getLblSize:[UIFont systemFontOfSize:14.0] width:(self.screen_width - 120) height:MAXFLOAT str:str];
        float height =size.height;
        if(height>300){
            height = 300;
        }
        CGRect rec = CGRectMake(40, (self.screen_height-size.width-90)/2, height+30, size.width+30);
        self.lbl_toast.frame = rec;
        
        UIWindow *window = [[UIApplication sharedApplication].windows lastObject];

        self.lbl_toast.text = str;
        [window addSubview:self];
        self.hidtimer = 1.5;
        if(self.logoTimer==nil||![self.logoTimer isValid]){
            self.logoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidToast:) userInfo:nil repeats:YES];
        }

    });
    
}

-(void)hidToast:(id)sender{
    self.hidtimer --;
    if(self.hidtimer<=0){
        if(self.logoTimer!=nil&&[self.logoTimer isValid]){
            [self.logoTimer invalidate];
            self.logoTimer = nil;
        }
        [self removeFromSuperview];
    }
}

//计算label高宽
-(CGSize)getLblSize:(UIFont *)font width:(CGFloat)width height:(CGFloat)height str:(NSString*)str{
    CGSize size =[str textSizeWithFont:font constrainedToSize:CGSizeMake(width, height) lineBreakMode:NSLineBreakByWordWrapping];
    return size;
}
@end
