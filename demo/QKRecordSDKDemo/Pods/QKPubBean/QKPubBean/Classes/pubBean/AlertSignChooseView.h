//
//  AlertSignChooseView.h
//  QukanTool
//
//  Created by yang on 2018/2/28.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertSignChooseBean.h"
//#import "BaseBean.h"

typedef void (^chooseCallBack)(AlertSignChooseBean *bean);
@interface AlertSignChooseView : UIView
//传入的array 需要重新组装
//-(instancetype)initWithObjects:(NSArray*)array  callBack:(chooseCallBack)callBack;

//传入的array 不需要重新组装
-(instancetype)init:(NSArray*)array  frame:(CGRect)frame callBack:(chooseCallBack)callBack;
@end
