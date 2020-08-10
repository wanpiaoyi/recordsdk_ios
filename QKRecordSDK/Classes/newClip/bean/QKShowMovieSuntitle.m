//
//  QKShowMovieSuntitle.m
//  QukanTool
//
//  Created by yang on 17/6/17.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "QKShowMovieSuntitle.h"
#import "QKTextChangeBean.h"
#import "QKImageChangeBean.h"
@interface QKShowMovieSuntitle ()

@end

@implementation QKShowMovieSuntitle
-(id)init{
    if(self = [super init]){
        static long subTitleId = 0;
        subTitleId++;
        self.subTitleId = subTitleId;
        self.speed = 1;
    }
    return self;
}

+(QKShowMovieSuntitle*)getShowMovieSuntitle:(NSDictionary*)dict{
    QKShowMovieSuntitle *qk = [[QKShowMovieSuntitle alloc] init];
    //显示界面
    {

        qk.subControl = [SubShowViewControl getSubShowViewControl:dict];

    }
    //预览界面
    {
        NSMutableArray *arr_previews = [[NSMutableArray alloc] init];
        NSArray *array = dict[@"previews"];
        for(NSDictionary *dic_preview  in array){
            SubtitlePreview *subpreview = [SubtitlePreview getSubTitlePreview:dic_preview];
            [arr_previews addObject:subpreview];
        }
        qk.array_previews = arr_previews;
    }
    
    return qk;
}


+(QKShowMovieSuntitle*)copySubtitle:(QKShowMovieSuntitle*)qk{
    QKShowMovieSuntitle *qk_copy = [[QKShowMovieSuntitle alloc] init];
    qk_copy.moviePartId = qk.moviePartId;
    qk_copy.subControl = [SubShowViewControl copySubControl:qk.subControl];

    qk_copy.startTime = qk.startTime;
    qk_copy.endTime = qk.endTime;
    qk_copy.softStartTime = qk.softStartTime;
    qk_copy.isTitle = qk.isTitle;

    return qk_copy;
}

-(void)checkShowTime:(double)nowTime isPause:(BOOL)isPause{
    if(nowTime >= self.startTime-0.001 && nowTime < self.startTime + self.endTime){
        [self.subControl showOrHidShowView:NO isPause:isPause animationTime:nowTime -self.startTime];
        
    }else{
        [self.subControl showOrHidShowView:YES isPause:isPause animationTime:nowTime -self.startTime];
    }
}

//获取截图
-(UIImage*)getViewToImage:(float)scale nowTime:(double)nowTime{
    if(nowTime>=self.startTime && nowTime<self.startTime + self.endTime){
        return [self.subControl getViewToImage:scale animationTime:nowTime -self.startTime];
    }
    return nil;
}

-(UIView*)getShowView:(CGSize)superSize{
    return [self.subControl getShowView:superSize];
}

-(UIView*)getPreView{
    if(_v_AllPreview != nil){
        return _v_AllPreview;
    }
    UIView *v_allPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, previewWidth, previewheight)];
    for(SubtitlePreview *subPre in self.array_previews){
        if(subPre.type == 1){
            UIImageView *img = [[UIImageView alloc] initWithFrame:subPre.rect];
            img.image = [UIImage imageNamed:subPre.img_name inBundle:[clipPubthings clipBundle] compatibleWithTraitCollection:nil];
            [v_allPreview addSubview:img];
        }else{
            if(subPre.addBackground){
                UILabel *lbl = [[UILabel alloc] initWithFrame:subPre.rect_backGround];
                lbl.backgroundColor = subPre.backgroundColor;
                [v_allPreview addSubview:lbl];
            }
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:subPre.rect];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.text = subPre.text;
            lbl.textColor = subPre.text_color;
            lbl.font = subPre.font;
            [v_allPreview addSubview:lbl];
        }
    }
    _v_AllPreview = v_allPreview;
    return _v_AllPreview;
}


//subViewRect 存放视频界面的的bounds，scale 视频的宽高比
+(CGRect)getCreenScreenRect:(CGRect)subViewRect scale:(double)scale{
    if(scale < 1){
        scale = 9/16.0;
    }else{
        scale = 16/9.0;
    }
    float width = subViewRect.size.width;
    float height = subViewRect.size.height;
    
    float fitheight = width / scale;

    float fitWidth = height * scale;
    if(fitheight < height){
        return CGRectMake(0, (height - fitheight) / 2, width, fitheight);
    }
    
    return CGRectMake((width - fitWidth)/ 2, 0,fitWidth , height);
}


-(void)setSubControl:(SubShowViewControl *)subControl{
    _subControl = subControl;
    WS(weakSelf);
    [_subControl setChangeEnd:^(id data) {
        if([data isKindOfClass:[QKTextChangeBean class]]){
            QKTextChangeBean *change = (QKTextChangeBean*)data;
            weakSelf.endTime = change.endTime;
            if(change.moviePartId != nil){
                weakSelf.moviePartId = change.moviePartId;
                weakSelf.startTime = change.startTime;
                weakSelf.softStartTime = change.softStartTime;
            }
        }else if([data isKindOfClass:[QKImageChangeBean class]]){
            QKImageChangeBean *change = (QKImageChangeBean*)data;
            weakSelf.endTime = change.endTime;
            if(change.moviePartId != nil){
                weakSelf.moviePartId = change.moviePartId;
                weakSelf.startTime = change.startTime;
                weakSelf.softStartTime = change.softStartTime;
            }
        }
    }];
}



-(void)setEndTime:(double)endTime{
    _endTime =endTime;
    self.subControl.endTime = endTime;
}

-(void)setStartTime:(double)startTime{
    _startTime = startTime;
    self.subControl.startTime = startTime;
}

+(CGRect)getNotCreenScreenRect:(CGRect)subViewRect{
    float width = subViewRect.size.width;
    float height = subViewRect.size.height;
    
    float fitheight = width * 16 / 9;
    
    float fitWidth = height * 9 / 16;
    if(fitheight < height){
        return CGRectMake(0, (height - fitheight) / 2, width,fitheight);
    }
    
    return CGRectMake((width - fitWidth)/ 2, 0,fitWidth , height);
}




-(NSDictionary*)getDictionaryByBean{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if(self.moviePartId != nil){
        [dict setObject:self.moviePartId forKey:@"moviePartId"];
    }
    [dict setObject:@(self.startTime) forKey:@"startTime"];
    [dict setObject:@(self.endTime) forKey:@"endTime"];
    [dict setObject:@(self.softStartTime) forKey:@"softStartTime"];
    [dict setObject:@(self.isTitle) forKey:@"isTitle"];
    [dict setObject:@(self.speed) forKey:@"speed"];

    NSDictionary *subControl = [self.subControl getDictionaryByBean];
    [dict setObject:subControl forKey:@"subControl"];

    return dict;
    
}

+(QKShowMovieSuntitle*)getShowMovieSub:(NSDictionary*)dict{
    QKShowMovieSuntitle *qk = [[QKShowMovieSuntitle alloc] init];
    NSNumber *moviePartId = dict[@"moviePartId"];
    NSNumber *startTime = dict[@"startTime"];
    NSNumber *endTime = dict[@"endTime"];
    NSNumber *softStartTime = dict[@"softStartTime"];
    NSNumber *isTitle = dict[@"isTitle"];
    NSNumber *speed = dict[@"speed"];
    NSDictionary *subControl = dict[@"subControl"];
    
    qk.moviePartId = moviePartId;
    qk.startTime = [startTime doubleValue];
    qk.subControl = [SubShowViewControl getSubControlByBean:subControl];
    qk.endTime = [endTime doubleValue];
    qk.softStartTime = [softStartTime doubleValue];
    qk.isTitle = [isTitle boolValue];
    qk.speed = [speed floatValue];
    return qk;
    
}

-(UIImageView *)getImg{
    if(self.img_insert == nil){
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 7, 7)];
        long type = self.subTitleId%10;
        img.image = [UIImage imageNamed:[NSString stringWithFormat:@"qktool_subtitle_add%ld",type] inBundle:[clipPubthings clipBundle] compatibleWithTraitCollection:nil];
        self.img_insert = img;
    }
    return self.img_insert;
}
@end
