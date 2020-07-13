//
//  LiveRecordOrLocalRecord.m
//  QukanTool
//
//  Created by yang on 15/11/25.
//  Copyright © 2015年 yang. All rights reserved.
//

#import "LiveRecordOrLocalRecord.h"
#import "RecordListCell.h"
#import "RecordData.h"
#import "RecordNothingCell.h"
#import "ClipPubThings.h"
#import "OSSSqlite.h"
#import <AssetsLibrary/AssetsLibrary.h>
#define AutoSizingMask (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)

@implementation LiveRecordOrLocalRecord



- (id)initWithFrame:(CGRect)frame{
    
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
//        self.autoresizingMask = AutoSizingMask;
        self.act_tab = [[UITableView alloc] initWithFrame:self.bounds];
        self.act_tab.delegate = self;
        self.act_tab.dataSource = self;
        self.act_tab.autoresizingMask = AutoSizingMask;
        self.act_tab.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.act_tab.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        self.deleteArray = [[NSMutableArray alloc] init];
        [self addSubview:self.act_tab];
    }
    
    return self;
}

-(void)removeDateThings:(RecordData*)data{
    for(RecordData * recdata in self.dataArray){
        if(data.liveid != nil && recdata.liveid !=nil && [recdata.liveid isEqual:data.liveid]){
            [self.dataArray removeObject:recdata];
            break;
        }
    }
    [self.act_tab reloadData];
    
}

-(void)setRecordSearch:(NSString*) type{
    if(self.isSearch){
        return;
    }
    self.isSearch = YES;
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        weakSelf.Edit = NO;
        weakSelf.type = type;
        NSMutableArray *array = [ossSynch getAllRecord:type];
        [weakSelf.deleteArray removeAllObjects];

        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.dataArray = array;
            
            [weakSelf.act_tab reloadData];
            weakSelf.isSearch = NO;
        });
        
    });
}

-(void)startEdict{
    self.Edit = YES;
    [self.deleteArray removeAllObjects];
    
    [self.act_tab reloadData];
}

-(void)edictEnded{
    self.Edit = NO;
    [self.deleteArray removeAllObjects];
    for (int i = 0; i<[self.dataArray count]; i++) {
        RecordData *data = [self.dataArray objectAtIndex:i];
        data.Select = NO;
    }
    [self.act_tab reloadData];
}
-(void)selectAllCell:(BOOL)isselAll{
    self.Edit = YES;
    if (isselAll)
    {
        
        for (int i = 0; i<[self.dataArray count]; i++)
        {
            RecordData *data = [self.dataArray objectAtIndex:i];
            data.Select = YES;
        }
        self.deleteArray = [[NSMutableArray alloc] initWithArray:self.dataArray];
        [self.act_tab reloadData];
        
    }else
    {
        for (int i = 0; i<[self.dataArray count]; i++) {
            RecordData *data = [self.dataArray objectAtIndex:i];
            data.Select = NO;
        }
        [self.deleteArray removeAllObjects];

        [self.act_tab reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.dataArray == nil){
        return 0;
    }
    if(self.dataArray.count==0){
        return 1;
    }
    return self.dataArray.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataArray count] == 0) {
        static NSString *str = @"nothing";
        
        RecordNothingCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if (cell == nil) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RecordNothingCell" owner:nil options:nil];
            cell = [array objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if([self.type isEqualToString:liveType]){
            cell.lbl_title.text = @"没有直播录像";

        }else if([self.type isEqualToString:imageType]){
            
            cell.lbl_title.text = @"没有照片";
            
        }else if([self.type isEqualToString:clipType]){
            
            cell.lbl_title.text = @"没有剪辑文件";
            
        }else{
            cell.lbl_title.text = @"没有本地录像";
        }
        
        return cell;
    }

    
    static NSString *str = @"cell";

    RecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RecordListCell" owner:nil options:nil];
        cell = [array objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.lbl_upload.layer.cornerRadius = 2.0f;
        cell.lbl_upload.layer.borderWidth = 1;
        
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    RecordData *data = [self.dataArray objectAtIndex:indexPath.row];
    cell.startTime.text = data.start_time;
    cell.titleLabel.text = data.displayname;
    cell.time_label.text = data.time;
    cell.show_button.tag = indexPath.row;
    
    cell.size_label.text = data.size;
    
    //根据状态改变图片
    if (self.Edit == YES)
    {

        if (data.Select == YES)
        {
            cell.headerImage.image = [UIImage imageNamed:@"qktool_fileselected"];
            
        }else
        {
            cell.headerImage.image = [UIImage imageNamed:@"qktool_fileselect"];
        }
        
    }else{
        cell.headerImage.image = [UIImage imageNamed:@""];

    }
    [data setImageView:cell.img_pic];
    
//    BOOL isUpdate = [ossFile checkFileIsRecord:data.liveid];
    BOOL isUpdate = [ossSynch getUpdateState:data.liveid];
  
    if(isUpdate){
        cell.lbl_upload.text = @"已同步";
        cell.lbl_upload.textColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:32/255.0 alpha:1.0];
        cell.lbl_upload.layer.borderColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:32/255.0 alpha:1.0].CGColor;
    }else{
        cell.lbl_upload.text = @"未同步";
        cell.lbl_upload.textColor = [UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1.0];
        cell.lbl_upload.layer.borderColor = [UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1.0].CGColor;
    }
    
    cell.tag = indexPath.row;
    
    WS(weakSelf);
    cell.open = ^(NSInteger tag){
        RecordData *data = [weakSelf.dataArray objectAtIndex:indexPath.row];
        useEdict use = weakSelf.useedict;
        if(use){
            use(data);
        }
        
    };
    [cell changeProcess:data];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dataArray.count==0){
        return self.act_tab.frame.size.height;
    }
    return 66.0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dataArray.count==0){
        return;
    }
    RecordData *data = [self.dataArray objectAtIndex:indexPath.row];
    
    //根据状态，如果当前为编辑状态，判断是否为全选或者全部取消状态更改按钮图片
    if (self.Edit == YES)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        RecordListCell *cell1 = (RecordListCell*)cell;
        if (data.Select == NO)
        {
            data.Select = YES;
            cell1.headerImage.image = [UIImage imageNamed:@"qktool_fileselected"];
            [self.deleteArray addObject:data];
            
            if ([self.deleteArray count] == [self.dataArray count])
            {
                selectAll choosesel = self.select;
                if(choosesel){
                    choosesel(1);
                    //            button.tag = 0;
                    //            [self.image setImage:[UIImage imageNamed:@"top_right_no_select"]];
                }
            }
            
        }else
        {
            data.Select = NO;
            cell1.headerImage.image = [UIImage imageNamed:@"qktool_fileselect"];
            [self.deleteArray removeObject:data];
            
            if ([self.deleteArray count] != [self.dataArray count]) {
                selectAll choosesel = self.select;
                if(choosesel){
                    choosesel(0);
                    //            button.tag = 0;
                    //            [self.image setImage:[UIImage imageNamed:@"top_right_no_select"]];
                }
            }
        }
        
        return;
    }

        //拼装播放路径，播放具体某个录像
        NSString *str = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,data.address];

        [clipPubthings showVideoOrAudio:str];

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    if(self.dataArray==nil||self.dataArray.count==0){
//        return NO;
//    }
//    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RecordData *data = [self.dataArray objectAtIndex:indexPath.row];
        NSArray *array = [[NSArray alloc] initWithObjects:data, nil];
        [pgToast setText:@"删除中"];
        [ossSynch deleteNameOrAddress:array];
    
        [self.dataArray removeObject:data];
        [self.act_tab reloadData];
        
    }
}



-(void)deleteSelectDatas{
    if(self.deleteArray==nil||self.deleteArray.count==0){
        QukanAlert *alert = [[QukanAlert alloc] initWithCotent:@"请选择一个文件" Delegate:nil];
        [alert show];
        return;
    }
    
    __weak NSArray *array = self.deleteArray;
    WS(weakSelf);
    [clipPubthings showHUD];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [ossSynch deleteNameOrAddress:array];
        for(RecordData *data in array){
            [weakSelf.dataArray removeObject:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.act_tab reloadData];
            [clipPubthings hideHUD];
        });
    });
    

    
}

@end
