//
//  ChangeImageSize.m
//  QukanTool
//
//  Created by yang on 2019/1/26.
//  Copyright © 2019 yang. All rights reserved.
//

#import "ChangeImageSize.h"
#import "MovieClipDataBase.h"
#import "QKMoviePart.h"
#import "ClipPubThings.h"

@interface ChangeImageSize()

@property(strong,nonatomic) IBOutlet UISlider *sld_size;
@property(strong,nonatomic) IBOutlet UISlider *sld_during;
@property(strong,nonatomic) IBOutlet UISlider *sld_startTime;
@property(strong,nonatomic) IBOutlet UILabel *lbl_size;
@property(strong,nonatomic) IBOutlet UILabel *lbl_time;
@property(strong,nonatomic) IBOutlet UILabel *lbl_startTime;
@property(strong,nonatomic) IBOutlet UIButton *btn_close;
@property(strong,nonatomic) NSArray *array_parts;

@end

@implementation ChangeImageSize

-(id)init:(double)scale during:(double)during startTime:(double)startTime{
    if(self = [super initWithFrame:CGRectMake(0, 0, qk_screen_width, qk_screen_height)]){
        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"ChangeImageSize1" owner:self options:nil];
        UIView *v_addName = [array firstObject];
        v_addName.frame = self.bounds;
        [self addSubview:v_addName];
        
        
        self.sld_size.value = scale;
        self.sld_during.value = during;

        
        self.lbl_size.text = [NSString stringWithFormat:@"%.1lf",scale];
        self.lbl_time.text = [NSString stringWithFormat:@"%.2lfs",during];
        //这里需要客户根据自身需求进行修改，字幕裁剪需要获取到当前视频的所有片段进行计算
        NSArray *array_parts = [clipData getMovies];
        self.array_parts = array_parts;
        double allTime = 0;
        for(QKMoviePart *part in array_parts){
            part.beginTime = allTime;
            allTime += part.movieDuringTime;
        }
        self.sld_startTime.maximumValue = allTime;
        self.sld_startTime.value = startTime;
        self.lbl_startTime.text = [NSString stringWithFormat:@"%.1lfs",startTime];
        [self.btn_close setTitleColor:clipPubthings.color forState:UIControlStateNormal];
        
        
        [self.sld_size setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateHighlighted];
        [self.sld_size setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateNormal];

        
        [self.sld_during setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateHighlighted];
        [self.sld_during setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateNormal];

        
        [self.sld_startTime setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateHighlighted];
        [self.sld_startTime setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateNormal];


    }
    return self;
}

#pragma mark - 字幕的色值大小等调整
-(IBAction)changeSize:(id)sender{
    double value = self.sld_size.value;
    self.lbl_size.text = [NSString stringWithFormat:@"%.1lf",value];

    QKImageChangeBean *bean = [[QKImageChangeBean alloc] init];
    bean.scale = value;
    [self imageChangeValue:ImageChangeScale bean:bean];
    
}
-(IBAction)changeDuring:(id)sender{
    double value = self.sld_during.value;
    self.lbl_time.text = [NSString stringWithFormat:@"%.2lfs",value];
    QKImageChangeBean *bean = [[QKImageChangeBean alloc] init];
    bean.endTime = self.sld_during.value;
    [self imageChangeValue:ImageChangeDuring bean:bean];
}

-(IBAction)changeStartTime:(id)sender{
    double value = self.sld_startTime.value;
    self.lbl_startTime.text = [NSString stringWithFormat:@"%.2lfs",value];
    
    QKImageChangeBean *bean = [[QKImageChangeBean alloc] init];
    [self getMoviePartId:value qkshow:bean];
    bean.endTime = self.sld_during.value;
    [self imageChangeValue:ImageChangeStartTime bean:bean];
}

-(void)imageChangeValue:(ImageChange)state bean:(QKImageChangeBean *)bean{
    changeImageValue getImage = self.getImage;
    if(getImage){
        getImage(state,bean);
    }
}

-(IBAction)sureView:(id)sender{
    [self removeFromSuperview];
}

//获取视频片段
-(void)getMoviePartId:(double)begintime qkshow:(QKImageChangeBean *)bean{
    bean.startTime = begintime;
    double startTime = 0;
    for(int i =0;i<self.array_parts.count;i++){
        QKMoviePart *moviePart = self.array_parts[i];
        if(startTime <= begintime && startTime + moviePart.movieDuringTime > begintime){
            bean.moviePartId = moviePart.moviePartId;
            bean.softStartTime = (begintime - startTime)*moviePart.speed + moviePart.movieStartTime;
            break;
        }
        startTime = startTime + moviePart.movieDuringTime;
    }
}
@end
