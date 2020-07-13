//
//  SelectVideoByType.m
//  QukanTool
//
//  Created by yang on 17/1/9.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "SelectVideoByType.h"
#import "SelectVideoCell.h"
#import "RecordData.h"
#import "HeaderFile.h"
#import "OSSSqlite.h"
#import "NothingCell.h"
#import "ClipPubThings.h"
#import "PubBundle.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation SelectVideoByType

- (id)initWithFrame:(CGRect)frame{
    
    if ((self = [super initWithFrame:frame])) {
        self.startTime = 0;
        self.backgroundColor = [UIColor clearColor];
        //        self.autoresizingMask = AutoSizingMask;
        self.act_tab = [[UITableView alloc] initWithFrame:self.bounds];
        self.act_tab.delegate = self;
        self.act_tab.dataSource = self;
        self.act_tab.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.act_tab.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        [self addSubview:self.act_tab];
        self.array_choose = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)setRecordSearch:(NSString*) type{
    if(self.isSelect){
        return;
    }
    self.isSelect = YES;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];

    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        weakSelf.type = type;
        NSMutableArray *array = [ossSynch getAllRecord:type];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.dataArray = array;
            if(weakSelf.fileInserName != nil&&!weakSelf.getVideos){
                for(RecordData *data in array){
                    if(data.liveendname != nil && [data.liveendname isEqualToString:weakSelf.fileInserName]){
                        NSDate *resDate = [formatter dateFromString:data.start_time];
                        NSTimeInterval startTime = [resDate timeIntervalSince1970];
                        if(weakSelf.startTime <= startTime){
                            [weakSelf.array_choose addObject:data];
                            data.Select = YES;
                        }
                    }
                }
            }
            weakSelf.getVideos = YES;
            [weakSelf.act_tab reloadData];
            weakSelf.isSelect = NO;
        });
        
    });
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
        
        NothingCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if (cell == nil) {
            NSArray *array = [[PubBundle bundle] loadNibNamed:@"NothingCell" owner:nil options:nil];
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
    
    SelectVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"SelectVideoCell" owner:nil options:nil];
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
    
    if (data.Select == YES)
    {
        cell.headerImage.image = [clipPubthings imageNamed:@"qktool_title_use"];
        
    }else
    {
        cell.headerImage.image = [clipPubthings imageNamed:@"qktool_title_unuse"];
    }
    if(self.justOne){
        cell.headerImage.hidden = YES;
    }

    [data setImageView:cell.img_pic];
    

    cell.lbl_upload.hidden = YES;
    
    if(data.uploadState == 2){
        cell.lbl_upload.text = @"已同步";
        cell.lbl_upload.textColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:32/255.0 alpha:1.0];
        cell.lbl_upload.layer.borderColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:32/255.0 alpha:1.0].CGColor;
    }else{
        cell.lbl_upload.textColor = [UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1.0];
        cell.lbl_upload.layer.borderColor = [UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1.0].CGColor;
    }
    
    cell.tag = indexPath.row;
    
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SelectVideoCell *cell1 = (SelectVideoCell*)cell;
    if (data.Select == NO)
    {
        data.Select = YES;
        cell1.headerImage.image = [clipPubthings imageNamed:@"qktool_title_use"];
        [self.array_choose addObject:data];
    }else
    {
        data.Select = NO;
        cell1.headerImage.image = [clipPubthings imageNamed:@"qktool_title_unuse"];
        [self.array_choose removeObject:data];
    }
    if(self.selectOne){
        self.selectOne(data.Select);
    }


    
}


@end
