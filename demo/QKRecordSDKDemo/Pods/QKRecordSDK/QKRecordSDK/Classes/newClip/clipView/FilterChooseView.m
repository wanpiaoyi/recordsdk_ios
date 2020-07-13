//
//  FilterChooseView.m
//  QukanTool
//
//  Created by yang on 2018/6/15.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "FilterChooseView.h"
#import "FilterBean.h"
#import "FilterChooseCell.h"
#import "MovieClipDataBase.h"
#import "ClipPubThings.h"

#define lineWidth 60

@interface FilterChooseView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(strong,nonatomic) NSMutableArray *array_filters;
@property(nonatomic) NSInteger selectIndex;
@property(strong,nonatomic) UICollectionView *collect;

@end

@implementation FilterChooseView

+(NSMutableArray*)createFilters{
    ////0 原始  1怀旧 2、素描 3清新 4恋橙 5稚颜 6青柠 7film 8微风 9萤火虫
    NSMutableArray *array = [[NSMutableArray alloc] init];
    {
        FilterBean *filter = [[FilterBean alloc] init];
        filter.name = @"原始";
        filter.type = 0;
        [array addObject:filter];
    }
    {
        FilterBean *filter = [[FilterBean alloc] init];
        filter.name = @"怀旧";
        filter.type = 1;
        [array addObject:filter];
    }
    {
        FilterBean *filter = [[FilterBean alloc] init];
        filter.name = @"素描";
        filter.type = 2;
        [array addObject:filter];
    }
    
    {
        FilterBean *filter = [[FilterBean alloc] init];
        filter.name = @"清新";
        filter.type = 3;
        [array addObject:filter];
    }
    {

        FilterBean *filter = [[FilterBean alloc] init];
        filter.name = @"恋橙";
        filter.type = 4;
        [array addObject:filter];
    }
    {
        FilterBean *filter = [[FilterBean alloc] init];
        filter.name = @"稚颜";
        filter.type = 5;
        [array addObject:filter];
    }
    {
        FilterBean *filter = [[FilterBean alloc] init];
        filter.name = @"青柠";
        filter.type = 6;
        [array addObject:filter];
    }
    {
        FilterBean *filter = [[FilterBean alloc] init];
        filter.name = @"film";
        filter.type = 7;
        [array addObject:filter];
    }
    {
        FilterBean *filter = [[FilterBean alloc] init];
        filter.name = @"微风";
        filter.type = 8;
        [array addObject:filter];
    }
    {
        FilterBean *filter = [[FilterBean alloc] init];
        filter.name = @"萤火虫";
        filter.type = 9;
        [array addObject:filter];
    }
    return array;
}

- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        self.array_filters = [FilterChooseView createFilters];
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        //    float padding = 7;
        [flowLayout setItemSize:CGSizeMake(lineWidth,frame.size.height)]; //设置cell的尺寸
        
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10); //设置其边界

        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal]; //设置其布局方向
     
    
        self.collect = [[UICollectionView alloc]
                        initWithFrame:self.bounds
                        collectionViewLayout:flowLayout];
        
        
        self.collect.dataSource = self;
        self.collect.delegate = self;
        self.collect.backgroundColor = [UIColor clearColor];
        self.collect.scrollEnabled = YES;
        UINib *nib = [UINib nibWithNibName:@"FilterChooseCell"
                                    bundle:[clipPubthings clipBundle]];
        [self.collect registerNib:nib forCellWithReuseIdentifier:@"cell"];
        [self addSubview:self.collect];
        self.selectIndex = 0;
    }
    
    return self;
    
}

-(void)showFilterType:(int)fileType{
    int selectPath = 0;

    for(int i = 0;i < self.array_filters.count;i++){
        FilterBean *bean = self.array_filters[i];
        if(bean.type == fileType){
            selectPath = i;
            break;
        }
    }
    
    [self changeSelect:selectPath];
}

-(int)selectNextFilter{
    if(self.selectIndex == self.array_filters.count - 1){
        return -1;
    }
    NSInteger selectPath = self.selectIndex + 1;
    return [self changeSelect:selectPath];
}

-(int)selectBeforeFilter{
    if(self.selectIndex == 0){
        return 0;
    }
    NSInteger selectPath = self.selectIndex - 1;
    return [self changeSelect:selectPath];
}
-(int)changeSelect:(NSInteger)selectIndex{
    if(selectIndex < 0 || selectIndex >= self.array_filters.count)
    {
        return 0;
    }
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:self.selectIndex inSection:0];
        FilterChooseCell *cell = (FilterChooseCell*)[self.collect cellForItemAtIndexPath:index];
        cell.lbl_name.alpha = 0.5;
    }
    
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:selectIndex inSection:0];
        FilterChooseCell *cell = (FilterChooseCell*)[self.collect cellForItemAtIndexPath:index];
        cell.lbl_name.alpha = 1;
    }
    self.selectIndex = selectIndex;
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectIndex inSection:0];
    
//    [self.collect scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
    FilterBean *bean = self.array_filters[self.selectIndex];
    return bean.type;
    
}

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    if (self.array_filters == nil) {
        return 0;
    }
    return self.array_filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str = @"cell";
    
    
    FilterChooseCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:str
                                              forIndexPath:indexPath];
  
    cell.backgroundColor = [UIColor clearColor];
    cell.lbl_name.textColor = [UIColor whiteColor];

//    if(indexPath.row == 0 || indexPath.row == self.array_filters.count + 1){
//        cell.lbl_name.alpha = 0;
//    }else{
        NSInteger selectIndex = indexPath.row;
        if(selectIndex == self.selectIndex){
            cell.lbl_name.alpha = 1;
        }else{
            cell.lbl_name.alpha = 0.5;
        }
        FilterBean *bean = self.array_filters[selectIndex];
        cell.lbl_name.text = bean.name;
//    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int type = [self changeSelect:indexPath.row];
    [clipData changeFilter:type];
}

- (CGSize) collectionView:(UICollectionView *)collectionView
　　layout:(UICollectionViewLayout *)collectionViewLayout
　　sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if(indexPath.row == 0){
//        return CGSizeMake(self.frame.size.width/2, self.frame.size.height);
//    }
//
//    if(indexPath.row == self.array_filters.count + 1){
//        return CGSizeMake(self.frame.size.width/2, self.frame.size.height);
//    }

    return CGSizeMake(lineWidth , self.frame.size.height);
    
}


@end
