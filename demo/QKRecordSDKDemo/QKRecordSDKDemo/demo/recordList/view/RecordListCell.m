//
//  RecordCell.m
//  MobileIPC
//
//  Created by chenyu on 13-10-23.
//  Copyright (c) 2013年 RenewTOOL. All rights reserved.
//

#import "RecordListCell.h"

@implementation RecordListCell


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
}



@end
