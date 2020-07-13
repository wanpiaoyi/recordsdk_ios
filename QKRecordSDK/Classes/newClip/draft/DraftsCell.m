//
//  DraftsCell.m
//  QukanTool
//
//  Created by yang on 17/6/27.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "DraftsCell.h"
#import "SubTitlesSql.h"

@implementation DraftsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)deleteDraft:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除该草稿吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    [alert show];
    alert.tag = 99;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 99){
        if (buttonIndex == 1) {
            
            if(self.deleteDra){
                self.deleteDra(self.drafts);
            }
        }
    }
    
}

-(void)checkBroken{
    NSInteger nowTag = self.tag;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *array_movieParts = [self.drafts.dict_save objectForKey:@"array_movieParts"];
    NSFileManager* manager = [NSFileManager defaultManager];
    BOOL broken = NO;
    for(NSDictionary *dict in array_movieParts){
        [array addObject:dict[@"fileAddress"]];
        if(![manager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,dict[@"fileAddress"]]]){
            broken = YES;
            break;
        }
    }
    self.drafts.checked = YES;
    
    if(broken){
        self.drafts.isBroken = broken;
        [subsql updateSql:self.drafts];
        self.lbl_broken.hidden = NO;
        self.edict.hidden = YES;
    }else{
        self.lbl_broken.hidden = YES;
        self.edict.hidden = NO;
    }
}

@end
