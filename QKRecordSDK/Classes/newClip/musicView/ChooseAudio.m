//
//  ChooseAudio.m
//  QukanTool
//
//  Created by yang on 2018/1/11.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "ChooseAudio.h"
#import "ChooseAudioCell.h"
#import "NewAudios.h"
#import "ClipPubThings.h"

@interface ChooseAudio()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(strong,nonatomic) NewAudios *audios;

@property(strong,nonatomic) NSMutableArray *array_chooseArrays;
@property(strong,nonatomic) NSMutableDictionary *dic_choose;
@property(strong,nonatomic) UICollectionView *collect;

@end

@implementation ChooseAudio

-(instancetype)initWithFrame:(CGRect)frame music:(NSString *)path{
    self = [super initWithFrame:frame];
    if(self){
        self.dic_choose = [NSMutableDictionary new];
        self.array_chooseArrays = [[NSMutableArray alloc] init];
        self.audios = [[NewAudios alloc] init];
        WS(weakSelf);
        [self.audios setGetAudio:^(QKMusicBean *bean) {
            [weakSelf selectmusic:bean];
        }];
        [self initCollection];
        NSArray *array = [self.audios getLocalAudios];
        if(path != nil && path.length > 0){
            for(QKMusicBean *bean in array){
                if([bean.address isEqualToString:path]){
                    self.selectMusic = bean;
                    break;
                }
            }
        }
        [self addNewAudio:array];
    }
    return self;
}

-(void)addNewAudio:(NSArray*)array{
    if(array != nil && [array count] > 0){
        for(QKMusicBean *bean in array){
            NSString *value = [self.dic_choose objectForKey:bean.address];
            if(value == nil && bean.address != nil){
                [self.dic_choose setObject:@"set" forKey:bean.address];
                [self.array_chooseArrays addObject:bean];
            }else{
                NSLog(@"ERROR：请勿重复添加:%@",bean.address);
            }
        }
        WS(weakSelf);
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf.collect != nil){
                [weakSelf.collect reloadData];
            }
        });
        
    }
}

-(void)selectmusic:(QKMusicBean *)bean{
    NSString *value = [self.dic_choose objectForKey:bean.address];
    if(value == nil && bean.address != nil){
        [self.dic_choose setObject:@"set" forKey:bean.address];
        [self.array_chooseArrays addObject:bean];
    }
    self.selectMusic = bean;

    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        chooseOneMusic chooseMusic = weakSelf.chooseMusic;
          if(chooseMusic){
              chooseMusic(weakSelf.selectMusic);
          }
        if(weakSelf.collect != nil){
            [weakSelf.collect reloadData];
        }
    });
        
}


#pragma mark - 字幕列表
-(void)initCollection{
  
    int width = (self.frame.size.width - 50 )/ 3;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(width, 46)]; //设置cell的尺寸
    //    CGSize size = CGSizeMake(previewWidth, previewheight);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0,10); //设置其边界
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 0;
    
    self.collect = [[UICollectionView alloc]
                    initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height)
                    collectionViewLayout:flowLayout];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical]; //设置其布局方向
    
    self.collect.dataSource = self;
    self.collect.delegate = self;
    self.collect.backgroundColor = [UIColor clearColor];
    self.collect.scrollEnabled = YES;
    UINib *nib = [UINib nibWithNibName:@"ChooseAudioCell"
                                bundle:[clipPubthings clipBundle]];
    [self.collect registerNib:nib forCellWithReuseIdentifier:@"cell"];
    [self addSubview:self.collect];
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    if (self.array_chooseArrays == nil || self.array_chooseArrays.count == 0) {
        return 1;
    }
    return self.array_chooseArrays.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str = @"cell";
    ChooseAudioCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:str
                                              forIndexPath:indexPath];
    if(indexPath.row == 0){
        cell.lbl_name.text = @"";
        cell.img_add.hidden = NO;
    }else{
        cell.img_add.hidden = YES;
        QKMusicBean *music = self.array_chooseArrays[indexPath.row - 1];
        cell.lbl_name.text = music.name;
        if(self.selectMusic != nil && [self.selectMusic.address isEqualToString:music.address]){
            cell.lbl_name.textColor = clipPubthings.color;
        }else{
            cell.lbl_name.textColor = [UIColor whiteColor];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0){
        if (@available(iOS 11.0, *)){
           [self.audios getNewAudios:self.dic_choose];
        }else{
            [QukanAlert alertMsg:@"该功能需11以上系统使用"];
        }
        return;
    }
    QKMusicBean *music = self.array_chooseArrays[indexPath.row - 1];
    if(self.selectMusic != nil && [self.selectMusic.address isEqualToString:music.address]){
        self.selectMusic = nil;
    }else{
        self.selectMusic = music;
    }
    [self.collect reloadData];
    chooseOneMusic chooseMusic = self.chooseMusic;
    if(chooseMusic){
        chooseMusic(self.selectMusic);
    }
    
}
@end
