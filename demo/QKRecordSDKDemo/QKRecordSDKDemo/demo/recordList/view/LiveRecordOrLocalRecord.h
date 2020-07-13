//
//  LiveRecordOrLocalRecord.h
//  QukanTool
//
//  Created by yang on 15/11/25.
//  Copyright © 2015年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RecordData.h" 
typedef void (^useEdict)(RecordData *data);
typedef void (^selectAll)(NSInteger seltype); //0 标示不是全选状态，1标示是全选状态

@interface LiveRecordOrLocalRecord : UIView<UITableViewDataSource,UITableViewDelegate>

@property(strong,nonatomic) UITableView *act_tab;
@property(strong,nonatomic) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *deleteArray; //在全选状态开启下选中的array
@property(strong,nonatomic) NSString *type;
@property(copy,nonatomic) useEdict useedict;
@property(copy,nonatomic) selectAll select;

@property BOOL Edit;
@property BOOL isSearch;


-(void)setRecordSearch:(NSString*) type;

-(void)removeDateThings:(RecordData*)data;

-(void)selectAllCell:(BOOL)isselAll;

-(void)startEdict;

-(void)edictEnded;

-(void)deleteSelectDatas; //删除选中的array


@end
