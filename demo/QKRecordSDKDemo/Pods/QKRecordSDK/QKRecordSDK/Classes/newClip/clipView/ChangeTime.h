//
//  ChangeTime.h
//  QukanTool
//
//  Created by yang on 17/6/19.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^getSureText)(NSString *text);
@interface ChangeTime : UIView

@property(copy,nonatomic)getSureText getText;

@property(strong,nonatomic)IBOutlet UITextView *fld_text;
@property(strong,nonatomic)IBOutlet UIView *v_bottom;

-(id)init:(NSString*)text;

@end
