//
//  MoviePartCell.m
//  QukanTool
//
//  Created by yang on 2017/12/14.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "MoviePartCell.h"
#import "ClipPubThings.h"

@implementation MoviePartCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.lbl_showSelect.layer.borderWidth = 1;
    self.lbl_showSelect.layer.borderColor = clipPubthings.color.CGColor;
    self.lbl_border.layer.borderColor = clipPubthings.color.CGColor;
}

-(IBAction)chooseTransfer:(id)sender{
    choosePartTransfer choose = self.choose;
    if(choose){
        choose(self.tag);
    }
}

@end
