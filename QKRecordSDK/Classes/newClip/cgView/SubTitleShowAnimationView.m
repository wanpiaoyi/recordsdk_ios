//
//  SubTitleShowAnimationView.m
//  QukanTool
//
//  Created by yang on 2017/12/21.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "SubTitleShowAnimationView.h"
#import "QKMoviePart.h"
#import "ClipPubThings.h"

@interface SubTitleShowAnimationView()
@property(strong,nonatomic) NSMutableArray *array_useSubtitles;

@end


@implementation SubTitleShowAnimationView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.array_useSubtitles = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)addSubTitle:(QKShowMovieSuntitle *)qk{
    WS(weakSelf);
    __weak QKShowMovieSuntitle *weakQkshow = qk;
    [qk.subControl setSubChange:^(NSInteger changeState){
        [weakSelf removeShowMovieSubtitle:weakQkshow];
    }];
    
    [self addSubview:[qk.subControl getShowView:self.bounds.size]];
    
    [self.array_useSubtitles addObject:qk];
    [qk checkShowTime:qk.startTime isPause:YES];
}

-(void) removeShowMovieSubtitle:(QKShowMovieSuntitle *)qkshow{
    UIImageView *img = [qkshow getImg];
    [img removeFromSuperview];
    [self.array_useSubtitles removeObject:qkshow];
}

-(void)changeTime:(double) time{
    [super changeTime:time];
    [self setNowPlayTime:time ispause:NO];
}

-(void)setNowPlayTime:(double)currentTimeSec ispause:(BOOL)isPause{
    for(QKShowMovieSuntitle *qk in self.array_useSubtitles){
        if(qk.isTitle > 0){
            [qk checkShowTime:currentTimeSec isPause:NO];
        }else{
            [qk checkShowTime:currentTimeSec isPause:isPause];
        }
    }
    
}
-(void)hidAllSubTitle{
    for(QKShowMovieSuntitle *qk in self.array_useSubtitles){
        [qk checkShowTime:-1 isPause:YES];
    }
}

-(void)changeMovieParts:(NSArray *)movies{
    NSMutableDictionary *nowMoviePart = [[NSMutableDictionary alloc] init];
    double allTime = 0;
    for(QKMoviePart *part in movies){
        if(part.moviePartId != nil){
            [nowMoviePart setObject:part forKey:part.moviePartId];
        }
        part.beginTime = allTime;
        allTime += part.movieDuringTime;
        NSLog(@"part.moviePartId:%@ part.beginTime:%.3lf",part.moviePartId,part.beginTime);
    }
    
    for(int i = 0;i<self.array_useSubtitles.count;i++){
        QKShowMovieSuntitle *qkshow = self.array_useSubtitles[i];
        if(qkshow.isTitle == 1){
            continue;
        }
        if(qkshow.isTitle == 2){
            qkshow.startTime = allTime - 4;
            continue;
        }
        QKMoviePart *moviePart = nowMoviePart[qkshow.moviePartId];
        if(moviePart == nil || qkshow.softStartTime < moviePart.movieStartTime || qkshow.softStartTime > moviePart.movieEndTime){
            [[qkshow.subControl getShowView:self.bounds.size] removeFromSuperview];
            [self.array_useSubtitles removeObject:qkshow];
            i--;
            continue;
        }
        double movieSpeed = [moviePart speed];
        qkshow.startTime = moviePart.beginTime + (qkshow.softStartTime - moviePart.movieStartTime)/movieSpeed;
        qkshow.endTime = qkshow.endTime*qkshow.speed /movieSpeed;
        qkshow.speed = movieSpeed;
        NSLog(@"qkshow.moviePartId:%@ qkshow.startTime:%.3lf",qkshow.moviePartId,qkshow.startTime);
        
    }
}


-(void)changeCutPart:(QKMoviePart *)oldPart newPart:(QKMoviePart *)newPart  movies:(NSArray *)movies{
    double allTime = 0;
    for(QKMoviePart *part in movies){
        part.beginTime = allTime;
        allTime += part.movieDuringTime;
        NSLog(@"part.moviePartId:%@ part.beginTime:%.3lf",part.moviePartId,part.beginTime);
    }
    
    for(int i = 0;i<self.array_useSubtitles.count;i++){
        QKShowMovieSuntitle *qkshow = self.array_useSubtitles[i];
        if(qkshow.isTitle == 1){
            continue;
        }
        if(qkshow.isTitle == 2){
            qkshow.startTime = allTime - 4;
            continue;
        }
        if([qkshow.moviePartId longLongValue] != [qkshow.moviePartId longLongValue]){
            continue;
        }
        if(qkshow.softStartTime > newPart.movieStartTime && qkshow.softStartTime < newPart.movieEndTime){
            qkshow.moviePartId = newPart.moviePartId;
            continue;
        }
    }
}


-(NSArray *)getAllSubTitles{
    return self.array_useSubtitles;
}

//外面更改了frame时候调用
-(void)changeFramed{
    for(QKShowMovieSuntitle *qk in self.array_useSubtitles){
        [qk.subControl getShowView:self.bounds.size];
    }
}
//清空以前的元素
-(void)clearAllSubTitles{
    for(QKShowMovieSuntitle *qk in self.array_useSubtitles){
        UIView *v = [qk.subControl getShowView:self.bounds.size];
        [v removeFromSuperview];
    }
    [self.array_useSubtitles removeAllObjects];
}

@end

