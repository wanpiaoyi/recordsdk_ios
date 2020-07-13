//
//  MoviesPartImgs.m
//  QukanTool
//
//  Created by yang on 2017/12/18.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "MoviesPartImgs.h"
#import <QKLiveAndRecord/QKMovieClipController.h>
#import "QKMoviePart.h"
#import "ClipPubThings.h"

#import "AudioRecordedView.h"

#define imgWidth  [self getImgWidth]
#define vMarginLeft [self getMarginLeft]
#define vAllWidth [self getAllImageWidth]

@interface MoviesPartImgs()

@property(strong,nonatomic) UIView *v_imgs; //存放视频图片的view
@property(strong,nonatomic) UIView *v_audioRecord; //已经录音的audio的View
@property double nowtime;
@property NSInteger nowArrayType; //用于标示，因为获取视频中的缩略图有延迟，用状态标识，只有当前视频组的视频才能添加进页面
@property (nonatomic, strong) UIPanGestureRecognizer        *moveGesture;
@property (nonatomic, strong) UIImageView *img_line;
@property float img_org_x;
@property double allTime; //总时长


@property (nonatomic, strong) AudioRecordedView *recordView;

@end

@implementation MoviesPartImgs

-(instancetype)initWithFrame:(CGRect)frame backGroundImage:(UIImage*)img{
    self = [super initWithFrame:frame];
    if(self){
        self.nowtime = 0;
        self.nowArrayType = 0;
        self.v_imgs = [[UIView alloc] initWithFrame:CGRectMake(vMarginLeft, (frame.size.height - audioRecorderView_imgHeight)/2, vAllWidth, audioRecorderView_imgHeight)];
        self.v_imgs.clipsToBounds = YES;
        [self addSubview:self.v_imgs];
        self.v_imgs.backgroundColor = [UIColor clearColor];
        
        
        self.v_audioRecord= [[UIView alloc] initWithFrame:CGRectMake(vMarginLeft, (frame.size.height - audioRecorderView_imgHeight)/2, vAllWidth, audioRecorderView_imgHeight)];
        self.v_audioRecord.clipsToBounds = YES;
        [self addSubview:self.v_audioRecord];
        self.v_audioRecord.backgroundColor = [UIColor clearColor];

        
        self.moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(moveGesture:)];
        self.moveGesture.delegate = self;
        [self addGestureRecognizer:self.moveGesture];
        
        if(img != nil){
            UIImageView *image = [[UIImageView alloc] initWithFrame:self.v_imgs.bounds] ;
            [self.v_imgs addSubview:image];
            image.image = img;
        }
        float x_true =  vMarginLeft - 4/2;

        
        self.img_line = [[UIImageView alloc] initWithFrame:CGRectMake(x_true, 0, 2, audioRecorderView_frameHeight)] ;
        self.img_line.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.img_line];
    }
    return self;

}
-(void)changeMovies:(NSArray*)arrayMovies{
    
    //清空当前视频图片的view
    for(UIView *v in self.v_imgs.subviews){
        [v removeFromSuperview];
    }
    for(UIView *v in self.v_audioRecord.subviews){
        [v removeFromSuperview];
    }
    if(arrayMovies == nil || arrayMovies.count == 0){
        [pgToast setText:@"没有选择的视频"];
        return;
    }
    double allTime = 0;
    for(QKMoviePart *part in arrayMovies){
        part.beginTime = allTime;
        allTime += part.movieDuringTime;
    }
    self.allTime = allTime;
    self.nowArrayType++;
    [self getImages:arrayMovies];

    WS(weakSelf);
    //添加视频间隔的
    for(QKMoviePart *part in arrayMovies){
        NSArray *array = part.audioArray;
        if(array != nil){
            for(PartAudioRecord *audioRecord in array){
                int orgX = audioRecord.audioStartTime*vAllWidth/allTime;
                int width = (audioRecord.audioEndTime - audioRecord.audioStartTime)*vAllWidth/allTime+1;
                AudioRecordedView *audioview = [[AudioRecordedView alloc] initWithFrame:CGRectMake(orgX, 0, width, self.frame.size.height)];
                audioview.startTime = audioRecord.audioStartTime;
                audioview.endTime = audioRecord.audioEndTime;
                [audioview setSelectRecord:^(AudioRecordedView *recordView) {
                    if(weakSelf.selectRecordViewCall){
                        weakSelf.selectRecordViewCall(recordView);
                    }
                }];
                [self.v_audioRecord addSubview:audioview];
            }
        }
    }
}

-(void)changeRecordedView:(NSArray*)arrayMovies{
    for(UIView *v in self.v_audioRecord.subviews){
        [v removeFromSuperview];
    }
    double allTime = 0;
    for(QKMoviePart *part in arrayMovies){
        part.beginTime = allTime;
        allTime += part.movieDuringTime;
    }

    WS(weakSelf);
    //添加视频间隔的
    for(QKMoviePart *part in arrayMovies){
        NSArray *array = part.audioArray;
        if(array != nil){
            for(PartAudioRecord *audioRecord in array){
                int orgX = audioRecord.audioStartTime*vAllWidth/allTime;
                int width = (audioRecord.audioEndTime - audioRecord.audioStartTime)*vAllWidth/allTime + 1;
                AudioRecordedView *audioview = [[AudioRecordedView alloc] initWithFrame:CGRectMake(orgX, 0, width, self.frame.size.height)];
                audioview.startTime = audioRecord.audioStartTime;
                audioview.endTime = audioRecord.audioEndTime;
                [audioview setSelectRecord:^(AudioRecordedView *recordView) {
                    if(weakSelf.selectRecordViewCall){
                        weakSelf.selectRecordViewCall(recordView);
                    }
                }];
                [self.v_audioRecord addSubview:audioview];
            }
        }
    }
}

-(void)setRecordStartTime:(double)startTime{
    int orgX = startTime*vAllWidth/self.allTime;
    int width = 2;
    AudioRecordedView *audioview = [[AudioRecordedView alloc] initWithFrame:CGRectMake(orgX, 0, width, self.frame.size.height)];
    
    audioview.startTime = startTime;
    audioview.endTime = 0;
    [self.v_audioRecord addSubview:audioview];
    self.recordView = audioview;
}

-(void)endRecord{
    self.recordView = nil;
}


-(double)getNowTime{
    if(self.nowtime > self.allTime){
        return self.allTime;
    }
    return self.nowtime;
}
-(void)getImages:(NSArray*)arrayMovies{
    NSInteger arrayType = self.nowArrayType;
    NSArray *array_partCounts = [self getMoviesArray:arrayMovies];
    WS(weakSelf);
    CGSize size = CGSizeMake(imgWidth, audioRecorderView_imgHeight);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block QKMovieClipController *qkMovieClip = nil;
        NSInteger movieCount = arrayMovies.count;

        __block NSInteger nowReadPart = 0;
        //当前视频添加了几次图片了
        __block int imgAddCount = 0;
        __block int nowAddCount = 0; //当前已经添加了几个图片了
        while (true) {
            if(arrayType != weakSelf.nowArrayType){
                if(qkMovieClip != nil){
                    [qkMovieClip cancelGetImage];
                }
                break;
            }
            if(nowReadPart > movieCount - 1){
                break;
            }
            if(qkMovieClip == nil){
                imgAddCount = 0;
                QKMoviePart *moviePart = arrayMovies[nowReadPart];
                NSNumber *count = array_partCounts[nowReadPart];
                NSLog(@"count:%@",count);
                if(moviePart.isImage){
                    NSInteger countNum = [count integerValue];
                    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfFile:[moviePart getOrgPath]]];
                    for(int i = 0;i < countNum;i++){
                        [weakSelf addImages:nowAddCount img:img arrayType:arrayType size:size];
                        nowAddCount++;
                    }
                    nowReadPart++;
                }else{
                    qkMovieClip = [[QKMovieClipController alloc] init];
                    if([count integerValue] > 0){
                        [qkMovieClip setMovieUrl:moviePart.filePath];
                        [qkMovieClip getImagesFromMovie:[count integerValue] startTime:moviePart.movieStartTime endTime:moviePart.movieEndTime getImageCallback:^(UIImage *img, double time) {
                            
                            [weakSelf addImages:nowAddCount img:img arrayType:arrayType size:size];
                            nowAddCount++;
                            imgAddCount++;
                            if(imgAddCount == [count integerValue]){
                                nowReadPart++;
                                qkMovieClip = nil;
                            }
                        }];
                    }else{
                        nowReadPart++;
                        qkMovieClip = nil;
                    }
                }
                
            }else{
                [NSThread sleepForTimeInterval:0.1];
            }
            
        }
    });
}

//添加图片，不是当前type的直接return
-(void)addImages:(NSInteger)count img:(UIImage*)img arrayType:(NSInteger)type size:(CGSize)size{
    if(type != self.nowArrayType){
        return;
    }
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        int width = size.width;
        if(count < [weakSelf getImageCounts] - 1){
            width = width -1;
        }
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(count*size.width, 0, width, size.height)];
        image.image = img;
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.backgroundColor = [UIColor blackColor];
        image.clipsToBounds = YES;
        [weakSelf.v_imgs insertSubview:image atIndex:0];
    });
    
    
}

//获取每个片段需要占用几个图片位置
-(NSArray*)getMoviesArray:(NSArray*)arrayMovies{

    
    //新建数组，记录每个片段，根据比例应该存在多少张图片
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int allImgsCount =  [self getImageCounts];
    int nowCount = 0;
    for(int i = 0;i < arrayMovies.count ;i++){
        QKMoviePart *part = arrayMovies[i];
        int addCount = 0;
        double during = part.movieDuringTime;
        /*
         通过算法，计算每个片段应该显示几张图片，这里主要是根据片段的结束时间，计算出片段结束时间点，应该显示多少张图片，减去前面已经记录下来的图片，就是这个片段应该显示几张图片
         */
        int nowAll = (int)ceil((during + part.beginTime)*allImgsCount/ self.allTime);
        //最后一个片段要把所有的图片分配完
        if(i == arrayMovies.count - 1){
            nowAll = allImgsCount;
        }
        //起始的片段一定要分配一个图片位置
        if(nowAll == 0 && nowCount == 0){
            nowAll = 1;
        }
        addCount = nowAll - nowCount;
        nowCount = nowAll;
        [array addObject:@(addCount)];
    }
    return array;
}


#pragma mark - 移动中间的时间帧的代码
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
 
    CGPoint pointBegin = [moveGesture translationInView:self];
    if(moveGesture.state == UIGestureRecognizerStateBegan){
        
 
        self.img_org_x = self.img_line.frame.origin.x;
    }
    if (moveGesture.state == UIGestureRecognizerStateBegan ||
        moveGesture.state == UIGestureRecognizerStateChanged ||
        moveGesture.state == UIGestureRecognizerStateRecognized ||
        moveGesture.state == UIGestureRecognizerStateEnded ||
        moveGesture.state == UIGestureRecognizerStatePossible) {
        [self move:pointBegin];
    }
}


- (void)move:(CGPoint)point {
    //计算偏移量必须在河里范围内
    float x = self.img_org_x + point.x;
    if(x < vMarginLeft - self.img_line.frame.size.width/2){
        x = vMarginLeft- self.img_line.frame.size.width/2;
    }
    
    if(x + self.img_line.frame.size.width > vMarginLeft + vAllWidth + self.img_line.frame.size.width/2){
        x = vMarginLeft + vAllWidth + self.img_line.frame.size.width/2 - self.img_line.frame.size.width;
    }
    float x_true = x - vMarginLeft + self.img_line.frame.size.width/2;
    
    //根据偏移量计算时间
    double time = x_true/vAllWidth * self.allTime;

    self.img_line.frame = CGRectMake(x, self.img_line.frame.origin.y, self.img_line.frame.size.width, self.img_line.frame.size.height);
    ChangeNowTime changeTime = self.changeTime;
    if(changeTime){
        changeTime(time);
    }
    self.nowtime = time;
}


-(void)setNowPlayTime:(double)playtime{
    float x_true =  vMarginLeft - 4/2 + playtime/self.allTime * vAllWidth;;
    self.img_line.frame = CGRectMake(x_true, 0, 2, audioRecorderView_frameHeight);
    self.nowtime = playtime;
    if(self.recordView != nil){
        int width = (playtime - self.recordView.startTime)*vAllWidth/self.allTime;
        
        self.recordView.frame = CGRectMake(self.recordView.frame.origin.x, 0, width, self.recordView.frame.size.height);
        
        self.recordView.endTime = playtime;
    }
    
    
}

#pragma mark - 基础数据的计算
//计算图片总长度
-(int)getAllImageWidth{
    int allwidth = 0;
    if(allwidth == 0){
        allwidth = [self getImageCounts] * imgWidth;
    }
    return allwidth;
}

-(int)getImgWidth{
    return (self.frame.size.width - 16)/8;
}

//计算个数
-(int)getImageCounts{

    return 8;
}

-(int)getMarginLeft{
    int margin = 0;
    if(margin == 0){
        margin = (self.frame.size.width - [self getAllImageWidth])/2;
    }
    return margin;
}
-(int)getOrgLeft:(double)startTime{
    int orgX = startTime*vAllWidth/self.allTime;
    return vMarginLeft + orgX;
}


@end

