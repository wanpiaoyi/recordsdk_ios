//
//  RecordCell.m
//  MobileIPC
//
//  Created by chenyu on 13-10-23.
//  Copyright (c) 2013年 RenewTOOL. All rights reserved.
//

#import "RecordCell.h"
#import "HeaderFile.h"
//#import "UploadControl.h"

@implementation RecordCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(IBAction)hideRightView:(id)sender
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(hideButtonPressed:)])
    {
        [self.delegate performSelector:@selector(hideButtonPressed:) withObject:sender];
    }
}

-(IBAction)showRightView:(id)sender
{
    openEdictView openedict = self.open;
    if(openedict){
        openedict(self.tag);
    }
}

-(void)changeProcess:(RecordData*)data{
    self.data = data;
    WS(weakSelf);
//    [ossUpload checkUploadProcess:^(double process, RecordData *data) {
//        if(weakSelf.data.liveid != nil && [data.liveid isEqualToNumber: weakSelf.data.liveid]){
//            dispatch_async(dispatch_get_main_queue(), ^{
//               weakSelf.lbl_upload.text = [NSString stringWithFormat:@"%.1lf%%",process*100];
//               weakSelf.lbl_upload.textColor = [UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1.0];
//               weakSelf.lbl_upload.layer.borderColor = [UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1.0].CGColor;
//            });
//        }
//    } notice:^(UploadState state, RecordData *data) {
//        if(weakSelf.data.liveid != nil && [data.liveid isEqualToNumber: weakSelf.data.liveid]){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(state != UploadStateSuccess){
//                    weakSelf.lbl_upload.text = @"未同步";
//                    weakSelf.lbl_upload.textColor = [UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1.0];
//                    weakSelf.lbl_upload.layer.borderColor = [UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1.0].CGColor;
//                    [pgToast setText:@"文件传输失败"];
//                }else{
//                    weakSelf.lbl_upload.text = @"已同步";
//                    weakSelf.lbl_upload.textColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:32/255.0 alpha:1.0];
//                    weakSelf.lbl_upload.layer.borderColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:32/255.0 alpha:1.0].CGColor;
//
//                }
//            });
//        }
//    } data:data];
}



@end
