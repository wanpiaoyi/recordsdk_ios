//
//  RawPartImages.m
//  QukanTool
//
//  Created by yang on 2018/6/15.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "RawPartImages.h"
#import "ClipPubThings.h"
#define TimeStartOrEnd 0.5
#define ImageCounts (NSInteger)[RawPartImages getImageCounts]
#define ImageAllWidth (NSInteger)[RawPartImages getAllImageWidth]
#define ImageWidth (NSInteger)[RawPartImages getImageWidth]
#define ImageHeight 46
#define MarginLeft (NSInteger)[RawPartImages getMarginLeft]

//用于显示从视频中获取出来的视频截图
@interface RawPartImages ()<UIGestureRecognizerDelegate>

@property BOOL selectMovie;//当前是否正在选择movie片段
@property(strong,atomic) NSMutableArray *array_imgs;            //图片内部列表
@property(strong,nonatomic) QKMovieClipController *movieClip;     //视频裁剪类
@property (nonatomic, strong) UIPanGestureRecognizer        *moveGesture;
@property float btn_org_x;

@property double startTime;
@property double endTime;

@property double clip_startTime;
@property double clip_endTime;
@property double speed;

//图片
@property (nonatomic, strong) IBOutlet UILabel *lbl_slidTime;

@property (nonatomic, strong) IBOutlet UILabel *lbl_during;

@property (nonatomic, strong) UIView *v_main;
@property (nonatomic, strong) IBOutlet UIView *v_mid;
@property (nonatomic, strong) IBOutlet UIView *v_left;
@property (nonatomic, strong) IBOutlet UIView *v_right;
@property(strong,nonatomic) IBOutlet UIImageView *img_startTime;            //开始时间
@property(strong,nonatomic) IBOutlet UIImageView *img_endTime;              //结束时间
@property(strong,nonatomic) IBOutlet UILabel *lbl_nowtime;              //当前时间

@property(strong,nonatomic) UIImageView *imgSelect;
@property NSInteger clipNowCount;
@end


@implementation RawPartImages

-(void)dealloc{
    [self clearGetImages];
    for(UIView *v in self.array_imgs){
        if([v isKindOfClass:[UIImageView class]]){
            [v removeFromSuperview];
        }
    }
    [self.array_imgs removeAllObjects];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.v_main = [[[clipPubthings clipBundle] loadNibNamed:@"RawPartImages1" owner:self options:nil] lastObject];
        self.v_main.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:self.v_main];
        self.lbl_nowtime.frame = CGRectMake(self.lbl_nowtime.frame.origin.x, self.lbl_nowtime.frame.origin.y, self.lbl_nowtime.frame.size.width, ImageHeight-4);
        
        
        self.array_imgs = [[NSMutableArray alloc] init];
        
        self.v_mid.layer.borderColor = [UIColor whiteColor].CGColor;
        self.v_mid.layer.borderWidth = 2;
        self.v_mid.frame = CGRectMake(MarginLeft, self.v_mid.frame.origin.y, self.frame.size.width - MarginLeft *2 - 1, self.v_mid.frame.size.height);
        
        //平移手势
        self.moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(moveGesture:)];
        self.moveGesture.delegate = self;
        [self addGestureRecognizer:self.moveGesture];
        self.selectMovie = YES;
        self.imgSelect = self.img_startTime;
        
        
        float x = MarginLeft- self.imgSelect.frame.size.width/2;
        self.img_startTime.frame = CGRectMake(x, self.img_startTime.frame.origin.y, self.img_startTime.frame.size.width,  self.img_startTime.frame.size.height);
        
        x = MarginLeft + ImageAllWidth + self.img_endTime.frame.size.width/2 - self.img_endTime.frame.size.width;
        self.img_endTime.frame = CGRectMake(x, self.img_endTime.frame.origin.y, self.img_endTime.frame.size.width, self.img_endTime.frame.size.height);
        
        self.clipNowCount = 0;
        self.canChangeStartTime = YES;
        self.minTime = 3;
    }
    return self;
}

-(void)clearGetImages{
    if(self.movieClip != nil){
        [self.movieClip cancelGetImage];
        self.movieClip = nil;
    }
}
-(void)getImageFromAvAsset:(QKMovieClipController *)movieClip startTime:(double)startTime endTime:(double)endTime{
    self.clipNowCount ++;
    NSInteger count = self.clipNowCount;
    if(self.movieClip != nil){
        [self.movieClip cancelGetImage];
    }
    
    for(UIView *v in self.array_imgs){
        if([v isKindOfClass:[UIImageView class]]){
            [v removeFromSuperview];
        }
    }
    
    float x = MarginLeft- self.imgSelect.frame.size.width/2;
    self.img_startTime.frame = CGRectMake(x, self.img_startTime.frame.origin.y, self.img_startTime.frame.size.width, self.img_startTime.frame.size.height);
    
    x = MarginLeft + ImageAllWidth + self.img_endTime.frame.size.width/2 - self.img_endTime.frame.size.width;
    self.img_endTime.frame = CGRectMake(x, self.img_endTime.frame.origin.y, self.img_endTime.frame.size.width, self.img_endTime.frame.size.height);
    
    [self.array_imgs removeAllObjects];
    self.movieClip = movieClip;
    float width = ImageWidth;
    float height = ImageHeight;
    __weak __typeof(&*self) weakSelf = self;
    NSLog(@"55555");
    [self.movieClip getImagesFromMovie:ImageCounts startTime:startTime endTime:endTime getImageCallback:^(UIImage *img1, double time) {
        
        @synchronized (weakSelf) {
            
            UIImage *img2 = nil;
            if(img1 != nil){
                img2 = [weakSelf scaleImage:img1 toScale:0.1];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(count == weakSelf.clipNowCount){
                    
                    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(width * weakSelf.array_imgs.count, 0, width, height)];
                    //                NSLog(@"count:%ld  frame:%@",weakSelf.array_imgs.count, NSStringFromCGRect(image.frame));
                    if(img2 == nil){
                        image.backgroundColor = [UIColor blackColor];
                    }else{
                        image.image = img2;
                        image.contentMode = UIViewContentModeScaleAspectFill;
                        image.clipsToBounds = YES;
                    }
                    
                    [weakSelf.array_imgs addObject:image];
                    [weakSelf.v_mid insertSubview:image atIndex:0];
                }
                
            });
        }
    }];
    NSLog(@"66666");
    self.startTime = 0;
    self.endTime = endTime - startTime;
    self.clip_startTime = 0;
    self.clip_endTime = endTime - startTime;
    [self changeStartTimeEndEndTime];
}



- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

#pragma mark - UIGestureRecognizerDelegate
// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


- (void)moveGesture:(UIPanGestureRecognizer*)moveGesture {
    if(!self.selectMovie){
        return;
    }
    CGPoint pointBegin = [moveGesture translationInView:self];
    if(moveGesture.state == UIGestureRecognizerStateBegan){
        
        {
            CGPoint point = [moveGesture locationInView:self.img_startTime];
            
            int x = point.x;
            int y = point.y;
            CGSize size = self.img_startTime.frame.size;
            if(x > -10 && y > -10 && x < size.width+10 && y< size.height+10){
                self.imgSelect = self.img_startTime;
                if(self.imgSelect != self.img_startTime){
                    [self.img_startTime setImage:[clipPubthings imageNamed:@"xcy_tuodongtiaoweixuan"]];
                    [self.img_endTime setImage:[clipPubthings imageNamed:@"xcy_tuodongtiaoyixuan"]];
                }else{
                    [self.img_startTime setImage:[clipPubthings imageNamed:@"xcy_tuodongtiaoxuanzhong"]];
                    
                    [self.img_endTime setImage:[clipPubthings imageNamed:@"xcy_tuodongtiaoyixuanbai"]];
                }
            }
        }
        
        {
            CGPoint point = [moveGesture locationInView:self.img_endTime];
            int x = point.x;
            int y = point.y;
            CGSize size = self.img_endTime.frame.size;
            if(x > -10 && y > -10 && x < size.width+10 && y< size.height+10){
                self.imgSelect = self.img_endTime;
                if(self.imgSelect != self.img_startTime){
                    [self.img_startTime setImage:[clipPubthings imageNamed:@"xcy_tuodongtiaoweixuan"]];
                    [self.img_endTime setImage:[clipPubthings imageNamed:@"xcy_tuodongtiaoyixuan"]];
                }else{
                    [self.img_startTime setImage:[clipPubthings imageNamed:@"xcy_tuodongtiaoxuanzhong"]];
                    
                    [self.img_endTime setImage:[clipPubthings imageNamed:@"xcy_tuodongtiaoyixuanbai"]];
                }
            }
        }
        
        self.btn_org_x = self.imgSelect.frame.origin.x;
    }
    if(!self.canChangeStartTime && self.imgSelect == self.img_startTime){
        [pgToast setText:@"不能修改开始时间"];
        return;
    }
    if (moveGesture.state == UIGestureRecognizerStateBegan ||
        moveGesture.state == UIGestureRecognizerStateChanged ||
        moveGesture.state == UIGestureRecognizerStateRecognized ||
        moveGesture.state == UIGestureRecognizerStateEnded ||
        moveGesture.state == UIGestureRecognizerStatePossible) {
        BOOL isEnd = (moveGesture.state == UIGestureRecognizerStateEnded);
        [self move:pointBegin isEnd:isEnd];
    }
}


- (void)move:(CGPoint)point isEnd:(BOOL)isEnd{
    //计算偏移量必须在河里范围内
    float x = self.btn_org_x + point.x;
    if(x < MarginLeft - self.imgSelect.frame.size.width/2){
        x = MarginLeft- self.imgSelect.frame.size.width/2;
    }
    
    if(x + self.imgSelect.frame.size.width > MarginLeft + ImageAllWidth + self.imgSelect.frame.size.width/2){
        x = MarginLeft + ImageAllWidth + self.imgSelect.frame.size.width/2 - self.imgSelect.frame.size.width;
    }
    float x_true = x - MarginLeft + self.imgSelect.frame.size.width/2;
    BOOL move = YES;
    //根据偏移量计算时间
    double time = self.startTime  + x_true/ImageAllWidth * (self.endTime - self.startTime);
    if(self.img_startTime == self.imgSelect){
        if(self.clip_endTime - time < self.minTime){
            [pgToast setText:[NSString stringWithFormat:@"裁剪的视频片段时长不能小于%.1lf秒",self.minTime]];
            time = self.clip_endTime - self.minTime;
            move = NO;
        }
        if(time == self.clip_startTime){
            return;
        }
        self.clip_startTime = time;
    }else{
        if(time - self.clip_startTime  < self.minTime){
            [pgToast setText:[NSString stringWithFormat:@"裁剪的视频片段时长不能小于%.1lf秒",self.minTime]];
            time = self.clip_startTime + self.minTime;
            move = NO;
        }
        if(time == self.clip_endTime){
            return;
        }
        self.clip_endTime = time;
        
    }
    if(self.selTime){
        self.selTime(time,isEnd);
    }
    
    if(move){
        self.imgSelect.frame = CGRectMake(x, self.imgSelect.frame.origin.y, self.imgSelect.frame.size.width, self.imgSelect.frame.size.height);
        if(self.img_startTime == self.imgSelect){
            self.v_left.frame = CGRectMake(0,0, self.imgSelect.frame.origin.x - MarginLeft+self.imgSelect.frame.size.width/2, ImageHeight);
        }else{
            
            self.v_right.frame = CGRectMake(self.imgSelect.frame.origin.x + self.imgSelect.frame.size.width/2 - MarginLeft, self.v_right.frame.origin.y, qk_screen_width - self.imgSelect.frame.origin.x - self.imgSelect.frame.size.width/2 - MarginLeft-1, ImageHeight);
        }
    }
    
    int slidX = self.imgSelect.frame.origin.x;
    if(slidX + self.lbl_slidTime.frame.size.width > self.frame.size.width){
        slidX = self.frame.size.width - self.lbl_slidTime.frame.size.width;
    }
//    NSLog(@"slidX:%d move:%d",slidX,move);
    CGRect rect = CGRectMake(slidX, self.lbl_slidTime.frame.origin.y, self.lbl_slidTime.frame.size.width, self.lbl_slidTime.frame.size.height);
    self.lbl_slidTime.frame = rect;
    NSLog(@"slidRect:%@",NSStringFromCGRect(rect));

    self.lbl_slidTime.text = [self getTimeToString:time];
    [self changeStartTimeEndEndTime];
    
}

-(void)setNowPlayTime:(double)playtime1{
    double playtime = playtime1*self.speed;
//    NSLog(@"playtime:%.2lf playtime1:%.2lf",playtime,playtime1);
    float between = playtime - self.startTime;
    float allbetween = self.endTime - self.startTime;
    if(between > allbetween ){
        between = allbetween;
        NSLog(@"between > allbetween");
    }
    if(between < 0 || playtime < self.clip_startTime || allbetween == 0){
        NSLog(@"between<0");
        return;
    }
    double x = between * ImageAllWidth /allbetween + MarginLeft;
//        NSLog(@"playtime:%.1lf x:%.1lf",playtime,x);
    self.lbl_nowtime.frame = CGRectMake(x, self.lbl_nowtime.frame.origin.y, self.lbl_nowtime.frame.size.width, self.lbl_nowtime.frame.size.height);
    self.lbl_nowtime.hidden = NO;
}

//隐藏当前白色进度条
-(void)hidNowTime{
    self.lbl_nowtime.hidden = YES;
}


//外部来修改这里面裁剪的开始时间
-(BOOL)changeStartTime:(double)timeChange{
    return [self changeImgTime:self.img_startTime timeChange:timeChange];
}
//外部来修改这里面裁剪的结束时间
-(BOOL)changeEndTime:(double)timeChange{
    return [self changeImgTime:self.img_endTime timeChange:timeChange];
}
/*
 img:需要修改的时间轴的图片
 */
-(BOOL)changeImgTime:(UIImageView *)img timeChange:(double)timeChange{
    
    double time = 0;
    if(self.img_startTime == img){
        time =  timeChange;
    }else{
        time =  timeChange;
    }
    if(time <= self.startTime){
        time = self.startTime;
    }
    if(time > self.endTime){
        time = self.endTime;
    }
    
    //计算判断时间是否合理，合理的话修改时间
    {
        if(self.img_startTime == img){
            self.clip_startTime = time;
        }else{
            self.clip_endTime = time;
        }
        [self changeStartTimeEndEndTime];
    }
    
    //根据时间修改开始的条和结束的条
    float between = time - self.startTime;
    float allbetween = self.endTime - self.startTime;
    if(allbetween == 0){
        return NO;
    }
    double x = between * ImageAllWidth /allbetween + MarginLeft  - img.frame.size.width/2;
    
    img.frame = CGRectMake(x, img.frame.origin.y, img.frame.size.width, img.frame.size.height);
    
    if(self.img_startTime == img){
        self.v_left.frame = CGRectMake(0, self.v_left.frame.origin.y, img.frame.origin.x - MarginLeft+img.frame.size.width/2, ImageHeight);
    }else{
        self.v_right.frame = CGRectMake(img.frame.origin.x+img.frame.size.width/2 - MarginLeft, self.v_right.frame.origin.y, qk_screen_width - img.frame.origin.x - img.frame.size.width/2 - MarginLeft-1, ImageHeight);
    }
    
    return YES;
}

-(void)changeStartTimeEndEndTime{
    self.lbl_during.text = [self getTimeToString:(self.clip_endTime - self.clip_startTime)/self.speed];
}

-(NSString*)getTimeToString:(double)time{
    NSString *returnTime = @"";
    
//    NSInteger hour = time / 3600;
//    if(hour>=10){
//        returnTime = [NSString stringWithFormat:@"%ld",hour];
//    }else{
//        returnTime = [NSString stringWithFormat:@"0%ld",hour];
//    }
    NSInteger min = time / 60;
    if(min>=10){
        returnTime = [NSString stringWithFormat:@"%ld",min];
    }else{
        returnTime = [NSString stringWithFormat:@"0%ld",min];
    }
    NSInteger sec = (int)time % 60;
    
    if(sec>=10){
        returnTime = [NSString stringWithFormat:@"%@:%ld",returnTime,sec];
    }else{
        returnTime = [NSString stringWithFormat:@"%@:0%ld",returnTime,sec];
    }
    int endTime = (int)(time*10)%10;
    returnTime = [NSString stringWithFormat:@"%@.%d",returnTime,endTime];
    return returnTime;
    
}

-(double)getClipStartTime{
    return self.clip_startTime;
}
-(double)getClipEndTime{
    return self.clip_endTime;
}


-(double)getPlayStartTime{
    return self.clip_startTime/self.speed;
}
-(double)getPlayEndTime{
    return self.clip_endTime/self.speed;
}

-(void)changeSpeed:(double)speed{
    self.speed = speed;
    [self changeStartTimeEndEndTime];
}
#pragma mark - 基础数据的计算
+(NSInteger)getImageWidth{
    double width = (qk_screen_width - 16)/ImageCounts;
    return (NSInteger)width;
}
//计算图片总长度
+(NSInteger)getAllImageWidth{
    static NSInteger allwidth = 0;
    if(allwidth == 0){
        allwidth = ImageCounts * ImageWidth;
    }
    return allwidth;
}

//计算个数
+(NSInteger)getImageCounts{
    
    return 8;
}

+(NSInteger)getMarginLeft{
    static NSInteger margin = 0;
    if(margin == 0){
        margin = (clipPubthings.screen_width - ImageAllWidth)/2;
    }
    return margin;
    
}

@end
