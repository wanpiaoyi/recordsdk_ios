//
//  DraftsViewController.m
//  QukanTool
//
//  Created by yang on 17/6/27.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "DraftsViewController.h"
#import "SubTitlesSql.h"
#import "DraftsCell.h"
#import "QKClipController.h"
@interface DraftsViewController ()

@property(strong,nonatomic) IBOutlet UITableView *tab_drafts;
@property(strong,nonatomic) NSMutableArray *array_drafts;
@end

@implementation DraftsViewController
-(void)loadView{
    // Initialization code
    [[[clipPubthings clipBundle]  loadNibNamed:@"DraftsViewController" owner:self options:nil] lastObject];

}

-(IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.array_drafts = [subsql getDraftsLists];
    [self.tab_drafts reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.array_drafts count] == 0) {
        return self.tab_drafts.frame.size.height;
    }
    return 78 + (clipPubthings.screen_width - 26)/16.0*9;
//    return 77;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.array_drafts == nil) {
        return 0;
    }
    if ([self.array_drafts count] == 0) {
        return 0;
    }
    return [self.array_drafts count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    //正常情况的cell
    static NSString *ID = @"cell";
    DraftsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"DraftsCell" owner:nil options:nil];
        cell = [array objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.btn_delete.layer.cornerRadius = 3.0;
        cell.btn_delete.layer.borderWidth = 1;
        cell.btn_delete.layer.borderColor = [UIColor colorWithRed:241/255.0 green:60/255.0 blue:71/255.0 alpha:1.0].CGColor;
        cell.lbl_broken.layer.cornerRadius = 3.0;
        
    }
    QKMoviePartDrafts *drafts = self.array_drafts[indexPath.row];
    cell.drafts = drafts;

    cell.tag = indexPath.row;
    if(drafts.isBroken){
        cell.edict.hidden = YES;
        cell.lbl_broken.hidden = NO;
    }else{
        if(drafts.checked){
            cell.edict.hidden = NO;
            cell.lbl_broken.hidden = YES;
        }else{
            [cell checkBroken];
        }

    }
    cell.img_background.tag = indexPath.row;
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,drafts.img_address];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *image = [NSData dataWithContentsOfFile:filePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(cell.img_background.tag == indexPath.row){
                cell.img_background.image = [UIImage imageWithData:image];
            }
        });
    });
    
    
    cell.tag = indexPath.row;
    WS(weakSelf);
    [cell setDeleteDra:^(QKMoviePartDrafts *drafts){
        [subsql deleteSqlAndFile:drafts];
        [weakSelf.array_drafts removeObject:drafts];
        [weakSelf.tab_drafts reloadData];
    }];
    cell.lbl_name.text = drafts.part_name;
    cell.lbl_createTime.text = [NSString stringWithFormat:@"日期:%@",drafts.change_time];;
    cell.lbl_during.text = [NSString stringWithFormat:@"时长:%@",[self timeToString:drafts.during]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.array_drafts count] == 0) {
        return;
    }
    QKMoviePartDrafts *drafts = self.array_drafts[indexPath.row];

    if(drafts.isBroken){
        return;
    }
    if(drafts.checked){
        QKClipController *movieClip = [[QKClipController alloc] initWithDrafts:drafts];
        [self.navigationController pushViewController:movieClip animated:YES];
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

@end
