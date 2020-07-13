//
//  ChooseFirstImage.h
//  QukanTool
//
//  Created by yang on 2018/1/11.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieClipDataBase.h"
#import "BaseViewController.h"

typedef void (^chooseImg)(UIImage *img);

@interface ChooseFirstImage : BaseViewController

@property(copy,nonatomic) chooseImg choose;
@property DrawType drawType;
//已经有的封面
@property(strong,nonatomic) UIImage *nowImg;
@property(strong,nonatomic) NSArray *array_movies;

@end

