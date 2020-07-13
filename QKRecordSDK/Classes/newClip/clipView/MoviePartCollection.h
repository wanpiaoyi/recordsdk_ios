//
//  MoviePartCollection.h
//  QukanTool
//
//  Created by yang on 2017/12/14.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordData.h"
#import "QKMoviePart.h"
#import "PlayController.h"
#import "LXReorderableCollectionViewFlowLayout.h"
/*
 选中一个片段时候的回调
 state:0 选中并播放  1:选中这个片段的转场效果
 */
typedef void (^chooseRawMovie)(QKMoviePart *data,NSInteger state);
//添加一个片段或者改变片段位置时候的回调，state ：1 添加片段，state ：2 改变位置
typedef void (^changeNewMoviePart)(QKMoviePart *data,NSInteger state);

@interface MoviePartCollection : UIView<LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout> {
}

@property (copy, nonatomic) ChangePlayerControl playControl;

//当前的视频数据列表
@property (strong, nonatomic) NSMutableArray *array;
-(void)insertSubTitle:(QKMoviePart *)part;
-(void)addSubTitle:(QKMoviePart *)part;

@property(strong,nonatomic) UICollectionView *collect;
@property QKMoviePart *selectPart;//选中某个片段

@property (copy, nonatomic) chooseRawMovie choose;

-(QKMoviePart *)deleteSelect;

- (id)initWithFrame:(CGRect)frame array:(NSMutableArray*)nowArray;

//预览时候看到哪个片段给予提示
-(void)showSelectTile:(double)time;
-(void)hidSelectTile;
-(void)changeAllTransfer:(MovieTransfer*)transfer;
-(void)setSelectIndex:(NSInteger)index;

-(void)chooseCover;
@end
