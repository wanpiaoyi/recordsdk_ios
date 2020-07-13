//
//  SubTitleCollectionView.m
//  QukanTool
//
//  Created by yang on 2017/12/21.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "SubTitleCollectionView.h"
#import "QKShowMovieSuntitle.h"
#import "QKMoviePart.h"
#import "GetNowSubtitles.h"
#import "SubTitleCell.h"
#import "MoviesPartImgs.h"
#import "ClipPubThings.h"
#import "MovieClipDataBase.h"
#import "LocalOrSystemVideos.h"
#import "AutoInAndAutoOut.h"


@interface SubTitleCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource>
//顶部的图片栏目
@property(strong,nonatomic) IBOutlet UIView *v_imgs;
@property(strong,nonatomic) IBOutlet UILabel *lbl_time;
@property(strong,nonatomic) IBOutlet UIView *v_collect;
@property(strong,nonatomic) IBOutlet UIView *v_addSubTitle;
@property(strong,nonatomic) IBOutlet UIButton *btn_sure;

@property(strong,nonatomic) NSArray *array_subtitles;
@property(strong,nonatomic) UICollectionView *collect;
@property(strong,nonatomic) MoviesPartImgs *moviesPart;

@end

@implementation SubTitleCollectionView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){

        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"SubTitleCollectionView1" owner:self options:nil];
        UIView *v_addName = [array firstObject];
        v_addName.frame = self.bounds;
        [self addSubview:v_addName];
        self.lbl_time.text = @"00:00:00";

        
        self.moviesPart = [[MoviesPartImgs alloc] initWithFrame:CGRectMake(0, 42, frame.size.width, audioRecorderView_frameHeight) backGroundImage:nil];
        [self.v_imgs addSubview:self.moviesPart];
        WS(weakSelf);
        [self.moviesPart setChangeTime:^(double time) {
            ChangePlayerControl playControl = weakSelf.playControl;
            if(playControl){
                playControl(PlayerControlSeek,time);
            }
            weakSelf.lbl_time.text = [weakSelf getTimeToString:time];
        }];
        [self initCollection];
        [self.btn_sure setTitleColor:clipPubthings.color forState:UIControlStateNormal];
    }
    return self;
}



-(void)setNowPlayTime:(double)nowTime{
    self.lbl_time.text = [self getTimeToString:nowTime];
    [self.moviesPart setNowPlayTime:nowTime];
}
#pragma mark - 字幕列表
-(void)initCollection{
    self.array_subtitles = [GetNowSubtitles getArrays];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(previewWidth, previewheight)]; //设置cell的尺寸
    //    CGSize size = CGSizeMake(previewWidth, previewheight);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 8, 12,8); //设置其边界
    self.collect = [[UICollectionView alloc]
                    initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height - 90)
                    collectionViewLayout:flowLayout];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical]; //设置其布局方向
    
    self.collect.dataSource = self;
    self.collect.delegate = self;
    self.collect.backgroundColor = [UIColor clearColor];
    self.collect.scrollEnabled = YES;
    UINib *nib = [UINib nibWithNibName:@"SubTitleCell"
                                bundle:[clipPubthings clipBundle]];
    [self.collect registerNib:nib forCellWithReuseIdentifier:@"cell"];
    [self.v_collect addSubview:self.collect];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    if (self.array_subtitles == nil || self.array_subtitles.count == 0) {
        if(clipPubthings.logo == nil){
            return 0;
        }
        return 1;
    }
    if(clipPubthings.logo == nil){
        return self.array_subtitles.count;
    }
    return self.array_subtitles.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str = @"cell";
    SubTitleCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:str
                                              forIndexPath:indexPath];
    for(UIView *v in cell.v_main.subviews){
        [v removeFromSuperview];
    }
    if(indexPath.row < self.array_subtitles.count){
        QKShowMovieSuntitle *qkshow = self.array_subtitles[indexPath.row];
        [cell.v_main addSubview:[qkshow getPreView]];
    }else{
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, previewWidth, previewheight)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.text = @"  Logo";
        [cell.v_main addSubview:lbl];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == self.array_subtitles.count){
        WS(weakSelf);
        if(clipPubthings.logo != nil){
            
        }
        NSString *pressfixPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

        NSString *address = [clipPubthings getLogoPath];
                
        
        UIImage *image = clipPubthings.logo;
        int height = 60/image.size.width*image.size.height;
        NSString *str_sub = [NSString stringWithFormat:@"{\"pointCreen\":\"12,20\",\"pointVer\":\"12,20\",\"showviews\":[{\"type\":3,\"margin\":\"0,0,0,0\",\"align\":1,\"padding\":0,\"imgName\":\"%@\",\"imgSize\":\"60,%d\",}],\"previews\":[]}",address,height];
        QKShowMovieSuntitle *qk = [GetNowSubtitles getMovieSub:str_sub];

        qk.subControl.animation = [[AutoInAndAutoOut alloc] init];
        
        QKShowMovieSuntitle *qkshow = [QKShowMovieSuntitle copySubtitle:qk];
        qkshow.startTime = [weakSelf.moviesPart getNowTime];
        if(qkshow.endTime == 0){
            qkshow.endTime = 3;
        }
        
        [weakSelf getMoviePartId:[weakSelf.moviesPart getNowTime] qkshow:qkshow];
        if(weakSelf.selectOne){
            weakSelf.selectOne(qkshow);
        }
        
        [weakSelf addOneSubTitle:qkshow];

        
    }else{
        selectOneSubTitle selectOne = self.selectOne;
        if(selectOne){
            QKShowMovieSuntitle *qk = self.array_subtitles[indexPath.row];
            
            QKShowMovieSuntitle *qkshow = [QKShowMovieSuntitle copySubtitle:qk];
            qkshow.startTime = [self.moviesPart getNowTime];
            if(qkshow.endTime == 0){
                qkshow.endTime = 3;
            }
            
            [self getMoviePartId:[self.moviesPart getNowTime] qkshow:qkshow];
            
            selectOne(qkshow);
            [self addOneSubTitle:qkshow];
        }
    }
  
}

-(void)changeArrayMovies:(NSArray*)array{
    [self.moviesPart changeMovies:array];

}

-(void)getMoviePartId:(double)begintime qkshow:(QKShowMovieSuntitle *)qkshow{
    double startTime = 0;
    for(int i =0;i<clipData.getMovies.count;i++){
        QKMoviePart *moviePart = clipData.getMovies[i];
        if(startTime <= begintime && startTime + moviePart.movieEndTime - moviePart.movieStartTime > begintime){
            double movieSpeed = [moviePart speed];
            qkshow.moviePartId = moviePart.moviePartId;
            qkshow.softStartTime = (begintime - startTime)*movieSpeed + moviePart.movieStartTime;
            qkshow.endTime = qkshow.endTime * qkshow.speed / movieSpeed;
            qkshow.speed = movieSpeed;
            break;
        }
        startTime = startTime + moviePart.movieEndTime - moviePart.movieStartTime;
    }
}

//添加字幕的位置信息
-(void)addSubTitleSign:(NSArray*)array{
    for(UIView *v in self.v_addSubTitle.subviews){
        [v removeFromSuperview];
    }
    if(array != nil && array.count > 0){
        for(QKShowMovieSuntitle *sub in array){
            [self addOneSubTitle:sub];
        }
    }
}

-(void)addOneSubTitle:(QKShowMovieSuntitle*)sub{
    int orgX = [self.moviesPart getOrgLeft:sub.startTime];
    UIImageView *img = [sub getImg];
    img.frame = CGRectMake(orgX - 3, 0, 7, 7);
    [self.v_addSubTitle addSubview:img];
}

-(IBAction)close:(id)sender{
    if(self.closeView){
        self.closeView(CloseViewTypeNormal);
    }
    [self removeFromSuperview];
}

//时间转化
-(NSString*)getTimeToString:(double)time{
    NSString *returnTime = @"";
    
    NSInteger hour = time / 3600;
    if(hour>=10){
        returnTime = [NSString stringWithFormat:@"%ld",hour];
    }else{
        returnTime = [NSString stringWithFormat:@"0%ld",hour];
    }
    NSInteger min = time / 60;
    if(min>=10){
        returnTime = [NSString stringWithFormat:@"%@:%ld",returnTime,min];
    }else{
        returnTime = [NSString stringWithFormat:@"%@:0%ld",returnTime,min];
    }
    NSInteger sec = (int)time % 60;
    
    if(sec>=10){
        returnTime = [NSString stringWithFormat:@"%@:%ld",returnTime,sec];
    }else{
        returnTime = [NSString stringWithFormat:@"%@:0%ld",returnTime,sec];
    }
    NSInteger endTime = (int)(time*100)%100;
    if(endTime>=10){
        returnTime = [NSString stringWithFormat:@"%@.%ld",returnTime,endTime];
    }else{
        returnTime = [NSString stringWithFormat:@"%@.0%ld",returnTime,endTime];
    }
    return returnTime;
    
}
@end
