//
//  RawMovieSelect.h
//  QukanTool
//
//  Created by yang on 17/6/14.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordData.h"
#import "QKMoviePart.h"
#import "LXReorderableCollectionViewFlowLayout.h"
typedef void (^chooseRawMovie)(QKMoviePart *data,NSInteger state);
typedef void (^addNewMoviePart)(QKMoviePart *data,NSInteger state);

@interface RawMovieSelect : UIView<LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout> {
}


- (id)initWithFrame:(CGRect)frame array:(NSMutableArray*)nowArray;
@property(strong,nonatomic) UICollectionView *collect;
@property (strong, nonatomic) NSMutableArray *array;
@property (copy, nonatomic) chooseRawMovie choose;
@property (copy, nonatomic) addNewMoviePart addMoviePart;

@property NSInteger selectIndex;
@property BOOL canMove;

-(void)addNewMoviePart:(QKMoviePart *)data;
-(QKMoviePart *)deleteSelect;


@property NSInteger showSelectIndex;

-(void)showSelectTile:(double)time;
-(void)hidSelectTile;

@end
