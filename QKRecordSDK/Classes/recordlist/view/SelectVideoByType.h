//
//  SelectVideoByType.h
//  QukanTool
//
//  Created by yang on 17/1/9.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^BlcselectOne)(BOOL select);

@interface SelectVideoByType : UIView<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic) UITableView *act_tab;
@property(strong,nonatomic) NSMutableArray *dataArray;

@property(strong,nonatomic) NSMutableArray *array_choose;

@property(copy,nonatomic) NSString *fileInserName;

@property(strong,nonatomic) NSString *type;
@property(copy,nonatomic) BlcselectOne selectOne;
@property BOOL justOne;
@property BOOL isSelect;
@property BOOL getVideos;
@property NSTimeInterval startTime;
-(void)setRecordSearch:(NSString*) type;
@end
