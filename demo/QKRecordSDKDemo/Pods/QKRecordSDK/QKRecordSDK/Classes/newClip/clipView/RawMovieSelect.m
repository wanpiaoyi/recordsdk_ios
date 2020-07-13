//
//  RawMovieSelect.m
//  QukanTool
//
//  Created by yang on 17/6/14.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "RawMovieSelect.h"
#import "RawMovieSelectCell.h"
#import "LocalOrSystemVideos.h"
#import "ClipPubThings.h"

@interface RawMovieSelect()

@property(strong,nonatomic) UILabel *lbl_showSelect;

@end
@implementation RawMovieSelect

- (id)initWithFrame:(CGRect)frame array:(NSMutableArray*)nowArray{
    if ((self = [super initWithFrame:frame])) {
        
        NSMutableArray *array= [[NSMutableArray alloc] init];
        if(nowArray.count > 0){
            for(id data in nowArray){
                if([data isKindOfClass:[RecordData class]]){
                    QKMoviePart *part = [QKMoviePart startWithRecord:data];
                    [array addObject:part];
                }else{
                    [array addObject:data];
                }
                
            }
        }
        
        self.array = array;
        self.backgroundColor = [UIColor clearColor];
        NSInteger padding = 8;
        LXReorderableCollectionViewFlowLayout *flowLayout = [[LXReorderableCollectionViewFlowLayout alloc] init];
        //        CGFloat width = ([[UIScreen mainScreen] bounds].size.width - rowcount * padding * 2) / rowcount;
        
        [flowLayout setItemSize:CGSizeMake(55, 55)]; //设置cell的尺寸
        
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal]; //设置其布局方向
        
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, padding); //设置其边界
        
        //其布局很有意思，当你的cell设置大小后，一行多少个cell，由cell的宽度决定
        
        self.collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:flowLayout];
        
        self.collect.dataSource = self;
        
        self.collect.delegate = self;
        
        self.collect.backgroundColor = [UIColor clearColor];
        self.collect.scrollEnabled = YES;
        
        UINib *nib = [UINib nibWithNibName:@"RawMovieSelectCell"
                                    bundle:[clipPubthings clipBundle]];
        [self.collect registerNib:nib forCellWithReuseIdentifier:@"cell"];
        
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.collect];
        self.selectIndex = -1;
        self.showSelectIndex = -1;
    }
    
    return self;
    
}


-(void)showSelectTile:(double)time{
    NSInteger nowRow = self.array.count;
    double beginTime = 0;
    for (int i = 0;i<self.array.count;i++) {
        QKMoviePart *part = self.array[i];
        if(time >= beginTime && time< beginTime  + part.movieDuringTime){
            nowRow = i;
            break;
        }
        beginTime += part.movieDuringTime;
    }
    if(nowRow == self.showSelectIndex && self.lbl_showSelect.tag == nowRow){
        return;
    }
    
    if(nowRow == self.array.count){
        nowRow = nowRow - 1;
    }
    self.showSelectIndex = nowRow;
    self.lbl_showSelect.hidden = YES;;
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:nowRow inSection:0];
    RawMovieSelectCell *cell = (RawMovieSelectCell*)[self.collect cellForItemAtIndexPath:index];
    cell.lbl_showSelect.hidden = NO;
    cell.lbl_showSelect.tag = nowRow;
    self.lbl_showSelect = cell.lbl_showSelect;
}

-(void)hidSelectTile{
    if(self.showSelectIndex == -1){
        return;
    }
    self.showSelectIndex = -1;
    self.lbl_showSelect.hidden = YES;;
    self.lbl_showSelect = nil;
}

-(void)addNewMoviePart:(QKMoviePart *)data{
    [self.array addObject:data];
    [self.collect reloadData];
}

-(QKMoviePart *)deleteSelect{
    if(self.selectIndex != -1){
        QKMoviePart *data = self.array[self.selectIndex];
        [self.array removeObjectAtIndex:self.selectIndex];
        self.selectIndex = -1;
        [self.collect reloadData];
        [pgToast setText:@"删除成功"];
        return data;
    }
    return nil;
}

-(void)setSelectIndex:(NSInteger)selectIndex{
    _selectIndex = selectIndex;
    [self.collect reloadData];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    if(!_canMove){
        return self.array.count + 1;
    }
    return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    

    
    static NSString *str = @"cell";
    
    RawMovieSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:str forIndexPath:indexPath];
    
    cell.lbl_border.layer.borderColor = [UIColor colorWithRed:1.0 green:56/255.0 blue:13/255.0 alpha:1.0].CGColor;

    if(_selectIndex == indexPath.row){
        cell.lbl_border.layer.borderWidth = 1.0;
    }else{
        cell.lbl_border.layer.borderWidth = 0;
    }

    if(indexPath.row == _array.count){
        cell.img_name.image = [clipPubthings imageNamed:@"qktool_movie_addPart"];
        cell.lbl_time.hidden = YES;
        return cell;
    }

    if(self.showSelectIndex == indexPath.row){
        cell.lbl_showSelect.hidden = NO;
        cell.lbl_showSelect.tag = indexPath.row;
        self.lbl_showSelect = cell.lbl_showSelect;
    }else{
        cell.lbl_showSelect.hidden = YES;
    }
    
    QKMoviePart *data = _array[indexPath.row];
    [data.data setImageView:cell.img_name];

    cell.lbl_time.text = [self timeToString:data.movieDuringTime];
    cell.lbl_time.hidden = NO;
    

    return cell;
}

#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    BOOL changed = NO;
    id playingCard = self.array[fromIndexPath.item];
    if(fromIndexPath.row == self.selectIndex){
        self.selectIndex = toIndexPath.row;
        changed = YES;
    }else if(fromIndexPath.row < self.selectIndex){
        if(toIndexPath.row >= self.selectIndex){
            self.selectIndex = self.selectIndex -1;
            changed = YES;
        }
    }else{
        if(toIndexPath.row <= self.selectIndex){
            self.selectIndex = self.selectIndex + 1;
            changed = YES;
        }
    }
    if(changed){
        NSLog(@"changedchangedchangedchanged");
    }
    [self.array removeObjectAtIndex:fromIndexPath.item];
    [self.array insertObject:playingCard atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == _array.count - 1) {
//        return NO;
//    }
    return _canMove;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
//    if (fromIndexPath.row == _array.count - 1 || toIndexPath.row == _array.count - 1) {
//        return NO;
//    }
    return _canMove;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == _array.count){
        WS(weakSelf);
        [LocalOrSystemVideos getVideos:^(NSArray *array) {
            if(array.count > 0){
                for(RecordData *data in array){
                    QKMoviePart *part = [QKMoviePart startWithRecord:data];
                    [weakSelf.array addObject:part];
                    weakSelf.addMoviePart(part,0);
                }
                [weakSelf.collect reloadData];
            }
        } copyFile:2 showimg:YES justOne:NO showVideo:YES];
        return;
    }
    if(_selectIndex == indexPath.row){
        return;
    }
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:_selectIndex inSection:0];
        RawMovieSelectCell *cell = (RawMovieSelectCell*)[self.collect cellForItemAtIndexPath:index];
        cell.lbl_border.layer.borderWidth = 0;

    }

    
    QKMoviePart *data = self.array[indexPath.row];
    self.choose(data,0);
    _selectIndex = indexPath.row;
    RawMovieSelectCell *cell = (RawMovieSelectCell*)[self.collect cellForItemAtIndexPath:indexPath];
    cell.lbl_border.layer.borderWidth = 1.0;
 
}

#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will begin drag**%ld", (long)indexPath.row);
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will end drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did end drag**%ld", (long)indexPath.row);
}

-(NSString*)timeToString:(NSInteger)time{
    NSInteger second = time % 60;
    NSInteger min = time/60%60;
    NSInteger hour = time/3600;
    
    NSString *str_second = [NSString stringWithFormat:@"%ld",second];
    if(second<10){
        str_second = [NSString stringWithFormat:@"0%ld",second];
    }
    NSString *str_min = [NSString stringWithFormat:@"%ld",min];
    if(min<10){
        str_min = [NSString stringWithFormat:@"0%ld",min];
    }
    NSString *str_hour = [NSString stringWithFormat:@"%ld",hour];
    if(hour<10){
        str_hour = [NSString stringWithFormat:@"0%ld",hour];
    }
    return [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_min,str_second];
}



@end
