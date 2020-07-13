//
//  AssetForOneGroupViewControllerCell.m
//  aaaaaaaa
//
//  Created by yangfan on 15/11/25.
//  Copyright © 2015年 Adron. All rights reserved.
//

#import "AssetForOneGroupViewControllerCell.h"

@implementation AssetForOneGroupViewControllerCell

- (void)awakeFromNib {
  // Initialization code
  [super awakeFromNib];
}

- (IBAction)cellClick:(UIButton *)sender1 {
//  CellClickBlock block = _cellClickBlock;
//  if (block && _index) {
//    block(_index);
//  }
    [self.btn_smallClick setSelected:!self.btn_smallClick.isSelected];
    SmallClickBlock block = _smallClickBlock;
    if (block && _index) {
        block(_index, self.btn_smallClick.isSelected);
    }
}

- (IBAction)smallClick:(UIButton *)sender1 {
  [self.btn_smallClick setSelected:!self.btn_smallClick.isSelected];
  SmallClickBlock block = _smallClickBlock;
  if (block && _index) {
    block(_index, self.btn_smallClick.isSelected);
  }
}
@end
