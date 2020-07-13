//
//  MoviePartCollection.m
//  QukanTool
//
//  Created by yang on 2017/12/14.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "MoviePartCollection.h"
#import "MoviePartCell.h"
#import "LocalOrSystemVideos.h"
#import "MovieClipDataBase.h"
#import "ClipPubThings.h"

@interface MoviePartCollection()

@property(strong,nonatomic) UILabel *lbl_showSelect;
@property BOOL canMove;
@property NSInteger showSelectIndex; //当前视频预览的时候，观看到了哪个视频片段
@property NSInteger targetContentOffsetX;

@end

@implementation MoviePartCollection

- (id)initWithFrame:(CGRect)frame array:(NSMutableArray*)nowArray{
    if ((self = [super initWithFrame:frame])) {
        
        NSMutableArray *array= [[NSMutableArray alloc] init];
        if(nowArray.count > 0){
            for(id data in nowArray){
                if([data isKindOfClass:[RecordData class]]){
                    QKMoviePart *part = [QKMoviePart startWithRecord:data];
                    [array addObject:part];
                }else{
                    QKMoviePart *part = [QKMoviePart copyMoviePart:data];
                    part.audioArray = nil;
                    [array addObject:part];
                }
                
            }
        }
        self.canMove = YES;
        self.backgroundColor = [UIColor clearColor];
        NSInteger padding = 0;
        LXReorderableCollectionViewFlowLayout *flowLayout = [[LXReorderableCollectionViewFlowLayout alloc] init];
        //        CGFloat width = ([[UIScreen mainScreen] bounds].size.width - rowcount * padding * 2) / rowcount;
        
        [flowLayout setItemSize:CGSizeMake(46, 46)]; //设置cell的尺寸
        
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal]; //设置其布局方向
        
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0); //设置其边界
        
        //其布局很有意思，当你的cell设置大小后，一行多少个cell，由cell的宽度决定
        
        self.collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:flowLayout];
        
        self.collect.dataSource = self;
        self.collect.showsHorizontalScrollIndicator = NO;
        self.collect.delegate = self;
        
        self.collect.backgroundColor = [UIColor clearColor];
        self.collect.scrollEnabled = YES;
        self.collect.decelerationRate = 0;
        UINib *nib = [UINib nibWithNibName:@"MoviePartCell"
                                    bundle:[clipPubthings clipBundle]];
        [self.collect registerNib:nib forCellWithReuseIdentifier:@"cell"];
        
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.collect];
        self.showSelectIndex = -1;
    }
    
    return self;
    
}


-(void)showSelectTile:(double)time{
    NSInteger nowRow = clipData.getMovies.count;
    double beginTime = 0;
    int moveX = 0;
    int count = clipData.getMovies.count;
    for (int i = 0;i < count;i++) {
        QKMoviePart *part = clipData.getMovies[i];
        double partDuring = [part movieDuringTime];
        if((time >= beginTime && time <= beginTime  + partDuring) || (i == count -1 && time > beginTime  + partDuring)){
            nowRow = i;
            if( i == 0){
                double partMovex = (time - beginTime)/partDuring *46;
                moveX = moveX + partMovex;
            }else{
                double partMovex = (time - beginTime)/partDuring *46 + 25 + 46 + (i-1)*71;
                moveX = moveX + partMovex;
            }
            break;
        }
        beginTime += partDuring;
    }
    nowRow = nowRow + 1;
    [self.collect setContentOffset:CGPointMake(moveX,0) animated:YES];

    if(nowRow == self.showSelectIndex && self.lbl_showSelect.tag == nowRow){
        return;
    }
    
    if(nowRow == clipData.getMovies.count + 1){
        nowRow = nowRow - 1;
    }

    self.showSelectIndex = nowRow;
    self.lbl_showSelect.hidden = YES;;
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:self.showSelectIndex inSection:0];
    MoviePartCell *cell = (MoviePartCell*)[self.collect cellForItemAtIndexPath:index];
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
    [clipData.getMovies addObject:data];
    [self.collect reloadData];
}

-(QKMoviePart *)deleteSelect{
    if(self.selectPart != NULL){
        QKMoviePart *data = self.selectPart;
        [clipData.getMovies removeObject:self.selectPart];
        self.selectPart = nil;
        [self.collect reloadData];
        [pgToast setText:@"删除成功"];
        return data;
    }
    return nil;
}

-(void)changeAllTransfer:(MovieTransfer*)transfer{
    int count = 0;
    for(QKMoviePart *part in clipData.getMovies){
        NSLog(@"transfer.type:%d",transfer.type);
        if(count == 0){
            part.transfer = [MovieTransfer getDefaultTransfer];
        }else{
            part.transfer = transfer;
        }
        count++;
    }
    [self.collect reloadData];
}

-(void)setSelectIndex:(NSInteger)selectIndex{
    
    if(selectIndex == -1){
        self.selectPart = nil;
    }else if(selectIndex < clipData.getMovies.count){
        self.selectPart = [clipData.getMovies objectAtIndex:selectIndex];
    }
    [self.collect reloadData];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
	return clipData.getMovies.count + 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    static NSString *str = @"cell";
    
    MoviePartCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:str forIndexPath:indexPath];
    if(indexPath.row == 0 || indexPath.row == clipData.getMovies.count+2){
        cell.v_main.hidden = YES;
        return cell;
    }
    cell.v_main.hidden = NO;

    NSInteger indexRow = indexPath.row - 1;
    cell.tag = indexRow;
    if(indexPath.row == clipData.getMovies.count + 1){
        cell.btn_zc.hidden = YES;
    }else{
        cell.btn_zc.hidden = NO;
    }
    
  
    
    if(indexPath.row == clipData.getMovies.count + 1){
        cell.img_name.image = [clipPubthings imageNamed:@"qktool_movie_addPart"];
        cell.lbl_time.hidden = YES;
        cell.lbl_border.layer.borderWidth = 0;
        cell.lbl_showSelect.hidden = YES;
        return cell;
    }
    QKMoviePart *data = clipData.getMovies[indexRow];

    if(self.selectPart != nil && [self.selectPart.moviePartId isEqualToNumber:data.moviePartId]){
        cell.lbl_border.layer.borderWidth = 1.0;
        cell.lbl_showSelect.hidden = YES;
        
    }else{
        cell.lbl_border.layer.borderWidth = 0;
        
        if(self.showSelectIndex == indexPath.row){
            cell.lbl_showSelect.hidden = NO;
            cell.lbl_showSelect.tag = indexPath.row;
            self.lbl_showSelect = cell.lbl_showSelect;
        }else{
            cell.lbl_showSelect.hidden = YES;
        }
    }
    
    
    [data.data setImageView:cell.img_name];
    
    cell.lbl_time.text = [self timeToString:(data.movieEndTime - data.movieStartTime)/data.speed];
    cell.lbl_time.hidden = NO;
    WS(weakSelf);
    [cell setChoose:^(NSInteger index) {
        if(weakSelf.choose){
            weakSelf.choose(data,1);
        }
    }];
    [cell.btn_zc setImage:[UIImage imageNamed:data.transfer.img_transfer] forState:UIControlStateNormal];

    return cell;
}

- (CGSize) collectionView:(UICollectionView *)collectionView
　　layout:(UICollectionViewLayout *)collectionViewLayout
　　sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return CGSizeMake(clipPubthings.screen_width/2, 58);
    }
    if(indexPath.row == 1){
        return CGSizeMake(46 , 46);
    }
    if(indexPath.row == clipData.getMovies.count + 1){
        return CGSizeMake(58 , 46);
    }
    if(indexPath.row == clipData.getMovies.count + 2){
        return CGSizeMake(clipPubthings.screen_width/2+1 - 58, 46);
    }
    return CGSizeMake(71 , 46);

}
//定义每个Section的四边间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
}

//两个cell之间的间距（同一行的cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    id playingCard = clipData.getMovies[fromIndexPath.item - 1];

    [clipData.getMovies removeObjectAtIndex:fromIndexPath.item - 1];
    [clipData.getMovies insertObject:playingCard atIndex:toIndexPath.item - 1];
    if(toIndexPath.row == 0){
        QKMoviePart *part = playingCard;
        part.transfer = [MovieTransfer getDefaultTransfer];
    }
    self.lbl_showSelect.hidden = YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0 || indexPath.row == clipData.getMovies.count + 1 || indexPath.row == clipData.getMovies.count + 2){
        return NO;
    }
    if(self.playControl){
        self.playControl(PlayerControlPause, 0);
    }
    return _canMove;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    if(toIndexPath.row == 0 || toIndexPath.row == clipData.getMovies.count + 1 || toIndexPath.row == clipData.getMovies.count + 2){
        return NO;
    }
    return _canMove;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == clipData.getMovies.count + 1){
        WS(weakSelf);
        [LocalOrSystemVideos getVideos:^(NSArray *array) {
            if(array.count > 0){
                
                for(RecordData *data in array){
                    QKMoviePart *part = [QKMoviePart startWithRecord:data];
                    [clipData addOnePart:part];
                }

                [weakSelf.collect reloadData];
                weakSelf.selectPart = nil;
                if(weakSelf.choose){
                    weakSelf.choose(nil,2);
                }
            }
        } copyFile:2 showimg:YES justOne:NO showVideo:YES];
        return;
    }
    if(indexPath.row == 0 || indexPath.row - 1 > clipData.getMovies.count){
        return;
    }
    QKMoviePart *data = clipData.getMovies[indexPath.row-1];

    if(self.selectPart == data){
        return;
    }
    {
        if(self.selectPart != nil){
            for(int i = 0;i < clipData.getMovies.count;i++){
                QKMoviePart *part = clipData.getMovies[i];

                if(self.selectPart != nil && [self.selectPart.moviePartId isEqualToNumber: part.moviePartId]){
                    NSIndexPath *index = [NSIndexPath indexPathForRow:i+1 inSection:0];
                    MoviePartCell *cell = (MoviePartCell*)[self.collect cellForItemAtIndexPath:index];
                    cell.lbl_border.layer.borderWidth = 0;
                    break;
                }
            }
        }
        
    }
    
    
    self.choose(data,0);
    self.selectPart = data;
    MoviePartCell *cell = (MoviePartCell*)[self.collect cellForItemAtIndexPath:indexPath];
    cell.lbl_border.layer.borderWidth = 1.0;
    
}

-(void)chooseCover{
    WS(weakSelf);
    [LocalOrSystemVideos getVideos:^(NSArray *array) {
        if(array.count > 0){
            
            for(RecordData *data in array){
                QKMoviePart *part = [QKMoviePart startWithRecord:data];
                part.movieEndTime = 0.5;
                [clipData addCover:part];
            }

            [weakSelf.collect reloadData];
            weakSelf.selectPart = nil;
            if(weakSelf.choose){
                weakSelf.choose(nil,2);
            }
        }
    } copyFile:2 showimg:YES justOne:YES showVideo:NO];
}

-(void)insertSubTitle:(QKMoviePart *)part{
    [clipData.getMovies insertObject:part atIndex:0];
    [self.collect reloadData];
}
-(void)addSubTitle:(QKMoviePart *)part{
    [clipData.getMovies addObject:part];
    [self.collect reloadData];
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
    //取消视频的选中状态
    {
        if(self.selectPart != nil){
            for(int i = 0;i < clipData.getMovies.count;i++){
                QKMoviePart *part = clipData.getMovies[i];
                if(self.selectPart != nil && [self.selectPart.moviePartId isEqualToNumber: part.moviePartId]){
                    NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                    MoviePartCell *cell = (MoviePartCell*)[self.collect cellForItemAtIndexPath:index];
                    cell.lbl_border.layer.borderWidth = 0;
                    break;
                }
            }
        }

    }
    self.selectPart = nil;
    if(self.choose){
        self.choose(nil,2);
    }
    
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

//开始拖动 UIscrollview 的时候被调用
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    NSLog(@"BeginDragging:%.1lf",scrollView.contentOffset.x);
    self.targetContentOffsetX = -100;
    if(self.playControl){
        self.playControl(PlayerControlPause, 0);
    }
}
//只要contentOffset 发生变化该（拖动、代码设置）方法就会被调用，反过来也可以用于监控 contentOffset 的变化。
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"scrollViewDidScroll:%.1lf scrollView.isDragging:%d",scrollView.contentOffset.x,scrollView.isDragging);
    if(scrollView.isDragging&&self.targetContentOffsetX == -100){
        double offset = scrollView.contentOffset.x;
        [self seekToTime:offset];
    }
}

////方法方法中 velocity 为 CGPointZero时（结束拖动时两个方向都没有速度），没有初速度，所以也没有减速过程，willBeginDecelerating 和该didEndDecelerating 也就不会被调用如果 velocity 不为 CGPointZero 时，scrollview 会以velocity 为初速度，减速直到 targetContentOffset，也就是说在你手指离开屏幕的那一刻，就计算好了停留在那个位置的坐标
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout nonnull CGPoint *)targetContentOffset{
//    NSLog(@"scrollViewWillEndDragging:%.1lf",targetContentOffset->x);
    self.targetContentOffsetX = targetContentOffset->x;
    double offset = targetContentOffset->x;

    [self seekToTime:offset];

}
//用户结束拖动后被调用，decelerate 为 YES 时，结束拖动后会有减速过程。
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    NSLog(@"scrollViewDidEndDragging:%.1lf",scrollView.contentOffset.x);
}

-(void)seekToTime:(double)offset{
    double time = 0;
    double width = 46.0;
    int i = 0;
    NSInteger count = clipData.getMovies.count;
    double beginTime = 0;
    
    while(offset > 0&& i < count){
        QKMoviePart *part = clipData.getMovies[i];
        double partDuring = [part movieDuringTime];
        if(offset <= width){
            time = beginTime + offset/width*partDuring;
            break;
        }else{
            offset = offset - width - 25;
        }
        beginTime += partDuring;
        time = beginTime - 0.1;

        if(i == count - 1){
            time = beginTime;
            break;
        }
        i++;
    }
    if(self.playControl){
        self.playControl(PlayerControlSeek, time);
    }
}

@end

