//
//  ChangeTime.m
//  QukanTool
//
//  Created by yang on 17/6/19.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "ChangeTime.h"
#import "ClipPubThings.h"
#import "QukanAlert.h"

@implementation ChangeTime
- (void)keyboardWillhidden:(NSNotification *)notification {
    //    [self hidKeyboard];
    self.v_bottom.frame = CGRectMake(0, clipPubthings.screen_height - self.v_bottom.frame.size.height, self.v_bottom.frame.size.width, self.v_bottom.frame.size.height);
}
//键盘高度变化的通知回调函数
- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow");
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardBounds =
    [[info objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;
    self.v_bottom.frame = CGRectMake(0, clipPubthings.screen_height - self.v_bottom.frame.size.height - keyboardBounds.height, self.v_bottom.frame.size.width, self.v_bottom.frame.size.height);
}


-(id)init:(NSString*)text{
    
    if(self = [super initWithFrame:CGRectMake(0, 0, clipPubthings.screen_width, clipPubthings.screen_height)]){
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(keyboardWillShow:)
         name:UIKeyboardWillShowNotification
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(keyboardWillhidden:)
         name:UIKeyboardWillHideNotification
         object:nil];
        
        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"ChangeTime1" owner:self options:nil];
        UIView *v_addName = [array firstObject];
        v_addName.frame = self.bounds;
        [self addSubview:v_addName];
        [self.fld_text becomeFirstResponder];
        self.fld_text.text = text;
        self.fld_text.layer.cornerRadius = 3.0;
        self.fld_text.layer.borderWidth = 1;
        self.fld_text.layer.borderColor = [UIColor colorWithRed:188/255.0 green:188/255.0 blue:188/255.0 alpha:1.0].CGColor;
        
  
    }
    return self;
}


-(IBAction)sureView:(id)sender{
    NSString *str = self.fld_text.text;
    if(str == nil || str.length == 0){
        QukanAlert *alert = [[QukanAlert alloc] initWithCotent:@"内容不能为空哟" Delegate:self];
        [alert show];
        return;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.fld_text resignFirstResponder];
    getSureText getText = self.getText;
    if(getText){
        getText(self.fld_text.text);
    }
    [self removeFromSuperview];

}


@end
