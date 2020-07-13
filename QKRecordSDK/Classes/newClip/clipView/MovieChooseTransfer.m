//
//  MovieChooseTransfer.m
//  QukanTool
//
//  Created by yang on 2017/12/23.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "MovieChooseTransfer.h"
#import "MovieChooseTransferCell.h"
#import "ClipPubThings.h"
#define screenWidth [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height

@interface MovieChooseTransfer()<UICollectionViewDelegate,UICollectionViewDataSource>

//转场动画
@property (strong, nonatomic) NSArray *array;
@property(strong,nonatomic) UICollectionView *collect;


@property(strong,nonatomic) IBOutlet UIView *v_collect;
@property(strong,nonatomic) IBOutlet UIButton *btn_useAllTransfer;
@property(strong,nonatomic) IBOutlet UIButton *btn_close;

@property(strong,nonatomic) QKMoviePart *selectPart;
@property NSInteger frame_height;
@end


@implementation MovieChooseTransfer


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:CGRectMake(0, 0, clipPubthings.screen_width, clipPubthings.screen_height)];
    if(self){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = self.bounds;
        [btn addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"MovieChooseTransfer1" owner:self options:nil];
        UIView *v_addName = [array firstObject];
        v_addName.frame = CGRectMake(0, clipPubthings.screen_height - frame.size.height, frame.size.width, frame.size.height);
        [self addSubview:v_addName];
        self.frame_height = frame.size.height;
        [self initCollection];
//        self.btn_useAllTransfer.layer.cornerRadius = self.btn_useAllTransfer.frame.size.height/2;
//        self.btn_close.layer.cornerRadius = self.btn_useAllTransfer.frame.size.height/2;
        
        self.btn_useAllTransfer.layer.borderWidth = 1;
        self.btn_useAllTransfer.layer.borderColor = [UIColor whiteColor].CGColor;
        
        [self.btn_close setTitleColor:clipPubthings.color forState:UIControlStateNormal];
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}


-(void)initCollection{
    self.array = [self getTransfer];
    int width = (clipPubthings.allWidth - 50)/ 3;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(width, 68)]; //设置cell的尺寸
    //    CGSize size = CGSizeMake(previewWidth, previewheight);
    flowLayout.sectionInset = UIEdgeInsetsMake(11, 11, 11,11); //设置其边界
    flowLayout.minimumInteritemSpacing = 11;
    flowLayout.minimumLineSpacing = 11;
    self.collect = [[UICollectionView alloc]
                    initWithFrame:self.v_collect.bounds
                    collectionViewLayout:flowLayout];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical]; //设置其布局方向
    
    self.collect.dataSource = self;
    self.collect.delegate = self;
    self.collect.backgroundColor = [UIColor clearColor];
    self.collect.scrollEnabled = YES;
    UINib *nib = [UINib nibWithNibName:@"MovieChooseTransferCell"
                                bundle:[clipPubthings clipBundle]];
    [self.collect registerNib:nib forCellWithReuseIdentifier:@"cell"];
    [self.v_collect insertSubview:self.collect atIndex:0];
}


-(NSArray*)getTransfer{
    NSArray *array = [MovieTransfer getTransfer];
    return array;
}

-(void)setMoviePart:(QKMoviePart *)moviePart{
    self.selectPart = moviePart;
    [self.collect reloadData];
}

//应用到全部
-(IBAction)applyAll:(id)sender{
    if(self.choose){
        self.choose(1, self.selectPart.transfer,self.selectPart.beginTime - 1);
    }
}

-(IBAction)closeView:(id)sender{
    self.hidden = YES;
    if(self.close){
        self.close(CloseViewTypeNormal);
    }
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    if (self.array == nil || self.array.count == 0) {
        return 0;
    }
    return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str = @"cell";
    MovieTransfer *transfer = self.array[indexPath.row];
    MovieChooseTransferCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:str forIndexPath:indexPath];
    cell.img_transfer.image = [UIImage imageNamed:transfer.img_name];
    cell.lbl_name.text = transfer.name;
    if(self.selectPart != nil){
        if(transfer.type == self.selectPart.transfer.type){
            cell.v_main.layer.borderColor = clipPubthings.color.CGColor;
        }else{
            cell.v_main.layer.borderColor = [UIColor whiteColor].CGColor;
        }
    }else{
        cell.v_main.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    cell.v_main.layer.borderWidth = 1.0;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.selectPart == nil){
        return;
    }
    MovieTransfer *transfer = self.array[indexPath.row];
    self.selectPart.transfer = transfer;
    if(self.choose){
        self.choose(0, transfer,self.selectPart.beginTime - 1);
    }
    [self.collect reloadData];
}

@end
