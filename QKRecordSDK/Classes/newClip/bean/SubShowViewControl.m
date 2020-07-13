//
//  SubShowViewControl.m
//  QukanTool
//
//  Created by yang on 17/6/18.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "SubShowViewControl.h"
#import "ChangeTextView.h"
#import "ChangeImageSize.h"
#import "AddTitleAnimation.h"
#import "AddTitleAnimationKuang.h"
#import "FlyFromRight.h"
#import "ClipPubThings.h"

@interface SubShowViewControl()
@property(strong,nonatomic) NSMutableArray *array_allLbl;
@property(strong,nonatomic) ChangeTextView *change;
@property(strong,nonatomic) ChangeImageSize *changeImage;
@property CGSize superSize;
@property float maxWidth;
@property float scale;

@end
@implementation SubShowViewControl
-(id)init{
    if(self = [super init]){
        self.array_allLbl = [[NSMutableArray alloc] init];
    }
    return self;
}

+(SubShowViewControl*)getSubShowViewControl:(NSDictionary*)dict{
    SubShowViewControl *qk = [[SubShowViewControl alloc] init];
    
    NSString *pointCreen = dict[@"pointCreen"];;
    NSString *pointVer = dict[@"pointVer"];
    NSArray *array_creen = [pointCreen componentsSeparatedByString:@","];
    NSArray *array_ver = [pointVer componentsSeparatedByString:@","];
    qk.pointCreen = CGPointMake([array_creen[0] integerValue], [array_creen[1] integerValue]);
    qk.pointVer = CGPointMake([array_ver[0] integerValue], [array_ver[1] integerValue]);
    //预览界面
    {
        NSMutableArray *array_showviews = [[NSMutableArray alloc] init];
        NSArray *array = dict[@"showviews"];
        for(NSDictionary *dic_showview  in array){
            SubTitleShowview *subpreview = [SubTitleShowview getSubTitleShowview:dic_showview];
            [array_showviews addObject:subpreview];
        }
        qk.array_showviews = array_showviews;
        qk.rect_showView = [qk ChangeAllShowRects];
    }

    qk.animation = [[FlyFromRight alloc] init];
    
    return qk;
}

+(SubShowViewControl*)copySubControl:(SubShowViewControl*)subcontrol{
    SubShowViewControl *qk = [[SubShowViewControl alloc] init];
    qk.pointCreen = subcontrol.pointCreen;
    qk.pointVer = subcontrol.pointVer;

    qk.rect_showView = subcontrol.rect_showView;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(SubTitleShowview *subpreview in subcontrol.array_showviews){
        SubTitleShowview *qk = [SubTitleShowview getSubtitleByBean:[subpreview getDictionaryByBean]];
        [array addObject:qk];
    }
    qk.array_showviews = array;
    qk.animation = [BaseAnimation getAnimationByName:[subcontrol.animation aniMationName]];
    qk.endTime = subcontrol.endTime;
    qk.startTime = subcontrol.startTime;
    return qk;
}
//根据所需要展示的界面调整位置
-(UIView*)getShowView:(CGSize)superSize{
    
    if(superSize.width != self.superSize.width || superSize.height != self.superSize.height){
        [self removeAllShowView];
        self.superSize = superSize;
        float superWidth = 0;
        float scale = 1;

        if(superSize.width > superSize.height){
            superWidth = superSize.width;
        }else{
            superWidth = superSize.height;
        }
        scale = superWidth / controlWidth;

        float maxWidth = [self getMaxWidth];
        
        for(SubTitleShowview *subpreview in self.array_showviews){
            [subpreview changeRect:superSize maxWidth:maxWidth];
        }
        self.rect_showView = [self ChangeAllShowRects];
    }else{
        if(_v_AllShowview != nil){
            return _v_AllShowview;
        }
    }
    
    [self CreateAllShowView];
    return _v_AllShowview;
}

//获取截图
-(UIImage*)getViewToImage:(float)scale animationTime:(double)animationTime{
    
    return [self.animation getViewToImage:scale time:animationTime];
}
//获取截图位置
-(CGRect)getViewImageRect:(double)animationTime{
    return [self.animation checkDrawRect:animationTime];
}



//获取可以使用的的最大宽度
-(float)getMaxWidth{
    if(self.superSize.width > self.superSize.height){
        return self.superSize.width - rightBetween * 2;
    }else{
        return self.superSize.width - rightBetween * 2;
    }
}

-(void)showOrHidShowView:(BOOL)isHidden isPause:(BOOL)isPause animationTime:(double)animationTime{

    self.v_AllShowview.hidden = isHidden;
    self.btn_close.hidden = !isPause;
    if(!isHidden&&!isPause){
        self.v_AllShowview.canMove = NO;
        [self.animation changeAnimation:animationTime];
    }else{
        self.v_AllShowview.canMove = YES;
        [self.animation resetPauseFrame];
    }
}
-(NSString*)getAnimationTime:(double)animationTime{
    return [self.animation getAnimationTime:animationTime];
}

-(void)changeLbl:(id)sender{
    if(self.btn_close.hidden == YES){
        return;
    }
    UIButton *btn = (UIButton*)sender;
    
    NSLog(@"sender:%ld",btn.tag);
    UILabel *lbl = self.array_allLbl[btn.tag];
    __block SubTitleShowview *subPre = self.array_showviews[lbl.tag];
    CGColorRef color = [subPre.text_color CGColor];
    NSString *textColor = @"";
    long numComponents = CGColorGetNumberOfComponents(color);
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents(color);

        textColor = [NSString stringWithFormat:@"%.4lf,%.4lf,%.4lf,%.4lf",components[0],components[1],components[2],components[3]];
    }
    
    self.change = [[ChangeTextView alloc] init:[NSString stringWithFormat:@"%@",lbl.text] color:textColor fontSize:subPre.font_size during:self.endTime startTime:self.startTime];
    if(subPre.addBackground){
        [self.change changeBackColor:subPre.backgroundColor];
    }
    WS(weakSelf);
    [self.change setGetText:^(TextChange state,QKTextChangeBean *bean) {
//        , NSString *textValue,UIColor*textColor, double value
        switch (state) {
            case TextChangeText:
            case TextChangeColor:
            case TextChangeAlpha:
                subPre.text_color = bean.textColor;
                [weakSelf getNewText:bean.textValue subPre:subPre lbl:lbl];
                break;
            case TextChangeSize:
                subPre.font_size = bean.size;
                subPre.font = [UIFont systemFontOfSize:bean.size];
                [weakSelf getNewText:bean.textValue subPre:subPre lbl:lbl];
                break;
           
            case TextChangeDuring:
            {
                changeEndTime changeEnd = weakSelf.changeEnd;
                if(changeEnd){
                    changeEnd(bean);
                }
                [weakSelf getNewText:bean.textValue subPre:subPre lbl:lbl];
            }
                break;
            case TextChangeStartTime:
            {
                changeEndTime changeEnd = weakSelf.changeEnd;
                if(changeEnd){
                    changeEnd(bean);
                }
            }
                break;
                
            default:
                break;
        }
    }];
    [clipPubthings.window addSubview:self.change];
}

-(void)changeImageSize:(id)sender{
    if(self.btn_close.hidden == YES){
        return;
    }
    UIButton *btn = (UIButton*)sender;
    
    __block SubTitleShowview *subPre = self.array_showviews[btn.tag];

    self.changeImage = [[ChangeImageSize alloc] init:subPre.imageScale during:self.endTime startTime:self.startTime];
    WS(weakSelf);
    [self.changeImage setGetImage:^(ImageChange state, QKImageChangeBean *bean) {
        switch (state) {
      
            case ImageChangeScale:
                subPre.imageScale = bean.scale;
                [weakSelf createNewView:subPre];
                break;
                
            case ImageChangeDuring:
            {
                changeEndTime changeEnd = weakSelf.changeEnd;
                if(changeEnd){
                    changeEnd(bean);
                }
                [weakSelf createNewView:subPre];
            }
                break;
            case ImageChangeStartTime:
            {
                changeEndTime changeEnd = weakSelf.changeEnd;
                if(changeEnd){
                    changeEnd(bean);
                }
            }
                break;
                
            default:
                break;
        }
    }];
    
    [clipPubthings.window addSubview:self.changeImage];
}


-(void)getNewText:(NSString*)str subPre:(SubTitleShowview *)subPre lbl:(UILabel*)lbl{
    [subPre changeSubPre:str];
    [self createNewView:subPre];
}

-(void)createNewView:(SubTitleShowview *)subPre{
    [self removeAllShowView];
    self.rect_showView = [self ChangeAllShowRects];

    [self CreateAllShowView];
    [self.animation setMainView:_v_AllShowview contentView:_v_showview screenWidth:self.superSize.width viewNeedHid:self.btn_close duringTime:self.endTime];
}



//文字改变直接重新计算所有的rects
-(CGRect)ChangeAllShowRects{
    NSInteger nowWidth = 0;
    NSInteger nowHeight = 0;
    
    float superWidth = 0;
    if(self.superSize.width > self.superSize.height){
        superWidth = self.superSize.width;
    }else{
        superWidth = self.superSize.height;
    }
    float scale = superWidth / controlWidth;
    SubTitleShowview *allBackground;
    

    //有一个大背景的，需要有margin值
    float item_marginx = 0;
    float item_marginy = 0;
    
    
    
    for(int i = 0; i< self.array_showviews.count ; i++){
     
        SubTitleShowview *subpreview = self.array_showviews[i];
        CGRect nowRect;
        if(subpreview.type == 1 || subpreview.type == 3){
            nowRect = subpreview.rect;
        }else if(subpreview.type == 4 || subpreview.type == 5){
            allBackground = subpreview;
            item_marginx = [allBackground.array_margin[1] integerValue];
            item_marginy = [allBackground.array_margin[1] integerValue];
            continue;
        }
        else{
            nowRect = subpreview.rect_backGround;
        }
        NSInteger nowPaddingWidth = 0;
        NSInteger topMargin = lineBetween*scale + nowHeight;
        if(nowHeight == 0){
            topMargin = item_marginy;
        }

        if(subpreview.padding == paddingSuntitleLine || subpreview.padding == paddingSuntitleCenter|| subpreview.padding == paddingSuntitleAll){
            if(nowWidth < nowRect.size.width){
                nowWidth = nowRect.size.width;
            }
            if(subpreview.padding == paddingSuntitleCenter){
//                nowWidth = [self getMaxWidth];
                if(self.superSize.width > self.superSize.height){
                    float scale = self.superSize.width / controlWidth;
                    _pointCreen = CGPointMake((self.superSize.width - nowWidth)/2/ scale, _pointCreen.y);
                }else{
                    float scale = self.superSize.height / controlWidth;

                    _pointVer = CGPointMake((self.superSize.width - nowWidth)/2/ scale, _pointVer.y);

                }
                
            }
            [subpreview changeMarginTop:topMargin marginx:item_marginx];
            nowHeight = nowRect.size.height + topMargin;
            continue;
        }else{

            SubTitleShowview *subpreviewNext;
            CGRect nextRect;
            
            if(self.array_showviews.count> i+1){
                subpreviewNext = self.array_showviews[i+1];
                if(subpreviewNext.padding == paddingSuntitleLine || subpreviewNext.padding == paddingSuntitleCenter|| subpreviewNext.padding == paddingSuntitleAll){
                    if(nowWidth < nowRect.size.width){
                        nowWidth = nowRect.size.width;
                    }
                    [subpreviewNext changeMarginTop:topMargin marginx:item_marginx];
                    nowHeight = nowRect.size.height + topMargin;
                    continue;
                }else{
                    if(subpreviewNext.type == 1 || subpreviewNext.type == 3){
                        nextRect = subpreviewNext.rect;
                    }else{
                        nextRect = subpreviewNext.rect_backGround;
                    }
                }
            }else{
                if(nowWidth < nowRect.size.width){
                    nowWidth = nowRect.size.width;
                }
                [subpreview changeMarginTop:topMargin marginx:item_marginx];
                nowHeight = nowRect.size.height + topMargin;
                continue;
            }
            
        
            
            NSInteger viewHeight = nowRect.size.height;
            if(viewHeight < nextRect.size.height){
                [subpreview changeMarginTop:topMargin + (nextRect.size.height - viewHeight)/2 marginx:item_marginx + nextRect.size.width];
                viewHeight = nextRect.size.height;
                [subpreviewNext changeMarginTop:topMargin marginx:item_marginx];
            }else{
                [subpreview changeMarginTop:topMargin marginx:item_marginx + nextRect.size.width];
                [subpreviewNext changeMarginTop:topMargin + (viewHeight - nextRect.size.height)/2 marginx:item_marginx];
            }
            i++;
            nowPaddingWidth = nextRect.size.width + nowRect.size.width + lineBetween*scale;
            if(nowWidth < nowPaddingWidth){
                nowWidth = nowPaddingWidth;
            }
            nowHeight = viewHeight + topMargin;
        }
    }
    if(allBackground != nil){
        
        allBackground.rect_backGround = CGRectMake(0, 0, nowWidth+ [allBackground.array_margin[1] integerValue] + [allBackground.array_margin[3] integerValue], nowHeight +  [allBackground.array_margin[2] integerValue]);
        return allBackground.rect_backGround;
    }
    return CGRectMake(self.rect_showView.origin.x, self.rect_showView.origin.y, nowWidth, nowHeight);
}

-(void)removeSubTitle{
    NSLog(@"removeSubTitle");
    [_v_AllShowview removeFromSuperview];
    if(self.subChange){
        self.subChange(-1);
    }
}

-(void)createView{
    if(_v_AllShowview == nil){
        float addMargin = 20;
        if(self.isTitle){
            addMargin = 0;
        }
        CGRect rect_allshowView = CGRectMake(self.rect_showView.origin.x, self.rect_showView.origin.y - addMargin, self.rect_showView.size.width + addMargin, self.rect_showView.size.height + addMargin);
        //带删除按钮的总显示界面
        MovieView *v_AllShowView = [[MovieView alloc] initWithFrame:rect_allshowView];
        
        CGRect rect_showView = CGRectMake(0, addMargin, self.rect_showView.size.width, self.rect_showView.size.height);
        //显示字幕的界面
        UIView *v_showview = [[UIView alloc] initWithFrame:rect_showView];
        
        [v_AllShowView addSubview:v_showview];
        v_showview.backgroundColor = [UIColor clearColor];
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(rect_showView.size.width - addMargin, 0, addMargin*2, addMargin*2);
        [btn1 setBackgroundImage:[clipPubthings imageNamed:@"qklive_record_cgdeleteout"] forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(removeSubTitle) forControlEvents:UIControlEventTouchUpInside];
        [v_AllShowView addSubview:btn1];
        _v_showview = v_showview;
        _v_AllShowview = v_AllShowView;
        if(self.isTitle){
            [v_AllShowView setUserInteractionEnabled:NO];
        }
        self.btn_close = btn1;
        WS(weakSelf);
        //
        [v_AllShowView setFrameChanged:^(CGRect rect){
            float addMargin = 20;
            if(self.isTitle){
                addMargin = 0;
            }

            [weakSelf.animation setMainView:weakSelf.v_AllShowview contentView:weakSelf.v_showview screenWidth:weakSelf.superSize.width  viewNeedHid:weakSelf.btn_close duringTime:self.endTime];
            if(weakSelf.superSize.width > weakSelf.superSize.height){
                float superWidth = self.superSize.width;
                float scale = superWidth / controlWidth;

                weakSelf.pointCreen = CGPointMake(rect.origin.x/scale, (rect.origin.y+addMargin)/scale);
            }else{
                float superWidth = self.superSize.height;
                float scale = superWidth / controlWidth;
                weakSelf.pointVer = CGPointMake(rect.origin.x/scale, (rect.origin.y+addMargin)/scale);

            }
        }];
    }

}

-(void)removeAllShowView{
    [self.array_allLbl removeAllObjects];
    for(UIView *v in _v_showview.subviews){
        [v removeFromSuperview];
    }
}

-(void)CreateAllShowView{
    [self createView];
    float superWidth = 0;
    BOOL isCreen;
    if(self.superSize.width > self.superSize.height){
        superWidth = self.superSize.width;
        isCreen = YES;
    }else{
        superWidth = self.superSize.height;
        isCreen = NO;
    }
    float margin_x;
    float margin_y;
    
    float addMargin = 20;
    if(self.isTitle){
        addMargin = 0;
    }
    
    NSString *pressfixPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    float scale = superWidth / controlWidth;
    if(isCreen){
        margin_x = _pointCreen.x * scale;
        margin_y = _pointCreen.y * scale;
    }else{
        margin_x = _pointVer.x * scale;
        margin_y = _pointVer.y * scale;
    }
    
    CGRect rect_allshowView = CGRectMake(margin_x, margin_y - addMargin, self.rect_showView.size.width + addMargin, self.rect_showView.size.height + addMargin);
    if(rect_allshowView.origin.y + rect_allshowView.size.height > self.superSize.height){
        rect_allshowView = CGRectMake(margin_x,self.superSize.height - (self.rect_showView.size.height + addMargin) - rightBetween, self.rect_showView.size.width + addMargin, self.rect_showView.size.height + addMargin);
    }
//    NSLog(@"self.superSize:%@ rect_allshowView1:%@",NSStringFromCGSize(self.superSize),NSStringFromCGRect(rect_allshowView));

    if(rect_allshowView.origin.x + rect_allshowView.size.width > self.superSize.width){
        rect_allshowView = CGRectMake(self.superSize.width - (self.rect_showView.size.width + rightBetween),rect_allshowView.origin.y, self.rect_showView.size.width + addMargin, self.rect_showView.size.height + addMargin);
    }
    
    CGRect rect_showView = CGRectMake(0, addMargin, self.rect_showView.size.width, self.rect_showView.size.height);
//    NSLog(@"rect_allshowView:%@ rect_showView:%@",NSStringFromCGRect(rect_allshowView),NSStringFromCGRect(rect_showView));

    _v_showview.frame = rect_showView;
    _v_AllShowview.frame = rect_allshowView;
    int i = 0;
    for(SubTitleShowview *subPre in self.array_showviews){
        CGRect rect = subPre.rect;
        if(subPre.align == alignSuntitleRight){
            rect = CGRectMake(rect_showView.size.width - rect.size.width - rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        }else if(subPre.align == alignSuntitleCenter){
            rect = CGRectMake((rect_showView.size.width - rect.size.width - rect.origin.x)/2, rect.origin.y, rect.size.width, rect.size.height);
            NSLog(@"rect:%@ rect_allshowView:%@ rect_showView:%@",NSStringFromCGRect(rect),NSStringFromCGRect(rect_allshowView),NSStringFromCGRect(rect_showView));

        }


        if(subPre.type == 1){
            UIImageView *img = [[UIImageView alloc] initWithFrame:rect];
            if(subPre.padding == paddingSuntitleAll){
                img.frame = CGRectMake(0, rect.origin.y, rect_showView.size.width, rect.size.height);
            }
            NSLog(@"%@ subPre.padding:%d",subPre.img_name,subPre.padding);
            img.image = [UIImage imageNamed:subPre.img_name];
            [_v_showview addSubview:img];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = rect;
            btn.tag = i;
            [btn addTarget:self action:@selector(changeImageSize:) forControlEvents:UIControlEventTouchUpInside];
            [_v_showview addSubview:btn];
        }else if(subPre.type == 3){
            UIImageView *img = [[UIImageView alloc] initWithFrame:rect];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",pressfixPath,subPre.img_name];
            NSData *image = [NSData dataWithContentsOfFile:filePath];

            
            img.image = [UIImage imageWithData:image];
            [_v_showview addSubview:img];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = rect;
            btn.tag = i;
            [btn addTarget:self action:@selector(changeImageSize:) forControlEvents:UIControlEventTouchUpInside];
            [_v_showview addSubview:btn];
            
        }else if(subPre.type == 4|| subPre.type == 5){
            CGRect rect_background = subPre.rect_backGround;
            if(subPre.type == 4){
                UILabel *lbl = [[UILabel alloc] initWithFrame:rect_background];
                lbl.backgroundColor = subPre.backgroundColor;
                [_v_showview addSubview:lbl];
            }else{
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:rect_background];
                UIImage *img = [UIImage imageNamed:subPre.img_name];
//                NSLog(@"rect:%@ imgname:%@",NSStringFromCGRect(rect_background),subPre.img_name);
                img = [img stretchableImageWithLeftCapWidth:20 topCapHeight:15];
                imgView.image = img;
                [_v_showview addSubview:imgView];
//                imgView.backgroundColor = [UIColor redColor];
            }
            
        }else{
            if(subPre.addBackground){
                CGRect rect_background = subPre.rect_backGround;
                if(subPre.align == alignSuntitleRight){
                    rect_background = CGRectMake(rect_showView.size.width - rect_background.size.width - rect_background.origin.x, rect_background.origin.y, rect_background.size.width, rect_background.size.height);
                }else if(subPre.align == alignSuntitleCenter){
                     rect_background = CGRectMake((rect_showView.size.width - rect_background.size.width - rect_background.origin.x)/2, rect_background.origin.y, rect_background.size.width, rect_background.size.height);
                }
                UILabel *lbl = [[UILabel alloc] initWithFrame:rect_background];
                lbl.backgroundColor = subPre.backgroundColor;
    
                [_v_showview addSubview:lbl];
            }
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:rect];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.text = subPre.text;
            lbl.textColor = subPre.text_color;
            lbl.font = [UIFont fontWithName:subPre.font_name size:scale*subPre.font_size];
            [_v_showview addSubview:lbl];
            lbl.numberOfLines = 0;
            lbl.tag = i;
            if(subPre.align == alignSuntitleRight){
                lbl.textAlignment = NSTextAlignmentRight;
            }else if(subPre.align == alignSuntitleCenter){
                lbl.textAlignment = NSTextAlignmentCenter;

            }
            
            [self.array_allLbl addObject:lbl];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = rect;
            [btn addTarget:self action:@selector(changeLbl:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = self.array_allLbl.count - 1;
            [_v_showview addSubview:btn];
 
        }
        i++;
    }

    [self.animation setMainView:_v_AllShowview contentView:_v_showview screenWidth:self.superSize.width  viewNeedHid:self.btn_close duringTime:self.endTime];
    self.btn_close.frame = CGRectMake(self.animation.rect_mainView.size.width - addMargin*2, 0, addMargin*2, addMargin*2);

}

#pragma mark - 创建片头和片尾
//片头
+(SubShowViewControl*)createTitleShowView:(NSString*)imgName{
    SubShowViewControl *qk = [[SubShowViewControl alloc] init];
    qk.isTitle = YES;
    NSString *pressfixPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    NSString *filePath = [NSString stringWithFormat:@"%@/%@",pressfixPath,imgName];
    NSData *image = [NSData dataWithContentsOfFile:filePath];
    UIImage *img = [UIImage imageWithData:image];
//    CGSize size = img.size;
    int width = 0;
    int height = 0;
    float scale = img.size.width * 1.0/ img.size.height;
    if(scale > titleImgMaxwidth / titleImgMaxheight){
        width = titleImgMaxwidth;
        height = width / scale;
    }else{
        height = titleImgMaxheight;
        width = height *scale;
    }
    
    
    
    NSNumber *type = @(3);
    NSString *margin = @"0,0,0,0";
    NSNumber *align = @(1);
    NSNumber *padding = @(0);
    NSString *img_name = imgName;
    NSString *imgSize = [NSString stringWithFormat:@"%d,%d",width,height];
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:type,@"type",margin,@"margin",align,@"align",padding,@"padding",img_name,@"imgName",imgSize,@"imgSize", nil];
    

    
    
    qk.pointCreen = CGPointMake((showSubTitleWidth - width) /2,(showSubTitleHeight - height) /2);
    qk.pointVer = CGPointMake((showSubTitleHeight - width) /2,(showSubTitleWidth - height) /2);
    //预览界面
    {
        NSMutableArray *array_showviews = [[NSMutableArray alloc] init];
        NSArray *array = [NSArray arrayWithObjects:dict, nil];
        
        for(NSDictionary *dic_showview  in array){
            SubTitleShowview *subpreview = [SubTitleShowview getSubTitleShowview:dic_showview];
            [array_showviews addObject:subpreview];
        }
        qk.array_showviews = array_showviews;
        qk.rect_showView = [qk ChangeAllShowRects];
        
    }
    
//    qk.animation = [[AddTitleAnimation alloc] init];
    qk.animation = [[AddTitleAnimationKuang alloc] init];
    
    return qk;
}

//片尾
+(SubShowViewControl*)createPwShow:(NSDictionary*)dict_pw{
    SubShowViewControl *qk = [[SubShowViewControl alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc]init];

    {
        {
            NSDictionary *dict = [SubShowViewControl getAllBackgroundImage:@"qktool_pwbackgroundImg.png" margin:@"16,13,16,13"];
            [array addObject:dict];
        }
        NSString *fbdw = dict_pw[@"fbdw"];
        if(fbdw != nil &&fbdw.length > 0){
            NSDictionary *dict = [SubShowViewControl getDefautLbl:fbdw fontsize:16];
            [array addObject:dict];
        }
        NSString *bjry = dict_pw[@"bjry"];
        if(bjry != nil &&bjry.length > 0){
            NSDictionary *dict = [SubShowViewControl getDefautLbl:[NSString stringWithFormat:@"采编:%@",bjry] fontsize:13];
            [array addObject:dict];
        }
        NSString *bqsm = dict_pw[@"bqsm"];
        if(bqsm != nil &&bqsm.length > 0){
            NSDictionary *dict = [SubShowViewControl getDefautLbl:[NSString stringWithFormat:@"%@",bqsm] fontsize:13];
            [array addObject:dict];
        }
    }
    
    qk.pointCreen = CGPointMake(250,85);
    qk.pointVer = CGPointMake(80,360);
    //预览界面
    {
        NSMutableArray *array_showviews = [[NSMutableArray alloc] init];
        
        for(NSDictionary *dic_showview  in array){
            SubTitleShowview *subpreview = [SubTitleShowview getSubTitleShowview:dic_showview];
            [array_showviews addObject:subpreview];
        }
        qk.array_showviews = array_showviews;
        qk.rect_showView = [qk ChangeAllShowRects];
        
    }
    
    qk.animation = [[FlyFromRight alloc] init];
    
    return qk;
}
+(NSDictionary*)getDefautLbl:(NSString*)text fontsize:(NSInteger)size{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@(2) forKey:@"type"];
    [dict setObject:@"0,0,0,0" forKey:@"margin"];
    [dict setObject:@(1) forKey:@"align"];
    [dict setObject:@(0) forKey:@"padding"];
    [dict setObject:text forKey:@"text"];
    [dict setObject:@"Helvetica" forKey:@"fontName"];
    [dict setObject:@(size) forKey:@"fontSize"];
    [dict setObject:@"1,1,1,1" forKey:@"textColor"];
    [dict setObject:@"0,0,0,0" forKey:@"backgroundColor"];
    return dict;
}

+(NSDictionary*)getAllBackground:(NSString*)color margin:(NSString*)margin{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@(4) forKey:@"type"];
    [dict setObject:margin forKey:@"margin"];
    [dict setObject:@(1) forKey:@"align"];
    [dict setObject:@(0) forKey:@"padding"];
    [dict setObject:@"" forKey:@"text"];
    [dict setObject:@"Helvetica" forKey:@"fontName"];
    [dict setObject:@(10) forKey:@"fontSize"];
    [dict setObject:@"1,1,1,1" forKey:@"textColor"];
    [dict setObject:color forKey:@"backgroundColor"];
    return dict;
}


+(NSDictionary*)getAllBackgroundImage:(NSString*)imgName margin:(NSString*)margin{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@(5) forKey:@"type"];
    [dict setObject:margin forKey:@"margin"];
    [dict setObject:@(1) forKey:@"align"];
    [dict setObject:@(0) forKey:@"padding"];
    [dict setObject:@"" forKey:@"text"];
    [dict setObject:imgName forKey:@"imgName"];
    [dict setObject:@"13,13" forKey:@"imgSize"];
    [dict setObject:@"Helvetica" forKey:@"fontName"];
    [dict setObject:@(10) forKey:@"fontSize"];
    [dict setObject:@"1,1,1,1" forKey:@"textColor"];
    return dict;
}






-(NSDictionary*)getDictionaryByBean{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%.1lf,%.1lf",self.pointCreen.x,self.pointCreen.y] forKey:@"pointCreen"];
    [dict setObject:[NSString stringWithFormat:@"%.1lf,%.1lf",self.pointVer.x,self.pointVer.y] forKey:@"pointVer"];
    
    [dict setObject:@(self.isTitle) forKey:@"isTitle"];
    [dict setObject:self.animation.aniMationName forKey:@"aniMationName"];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(SubTitleShowview *subpreview  in self.array_showviews){
        [array addObject:[subpreview getDictionaryByBean]];
    }
    [dict setObject:array forKey:@"showviews"];

    return dict;

}

+(SubShowViewControl *)getSubControlByBean:(NSDictionary *)dict{
    SubShowViewControl *qk = [[SubShowViewControl alloc] init];
    NSString *str_pointCreen = dict[@"pointCreen"];
    NSString *str_pointVer = dict[@"pointVer"];
    NSNumber *isTitle = dict[@"isTitle"];
    NSString *aniMationName = dict[@"aniMationName"];
    NSArray *array = dict[@"showviews"];
    
    
    NSArray *array_pointCreen = [str_pointCreen componentsSeparatedByString:@","];
    NSArray *array_pointVer = [str_pointVer componentsSeparatedByString:@","];
    
    qk.pointCreen = CGPointMake([array_pointCreen[0] integerValue], [array_pointCreen[1] integerValue]);
    qk.pointVer = CGPointMake([array_pointVer[0] integerValue], [array_pointVer[1] integerValue]);
    
    qk.isTitle = [isTitle boolValue];
    qk.animation = [BaseAnimation getAnimationByName:aniMationName];
    NSMutableArray *array_showVies = [[NSMutableArray alloc] init];
    for(NSDictionary *dic in array){
        SubTitleShowview *subpreview = [SubTitleShowview getSubtitleByBean:dic];
        [array_showVies addObject:subpreview];
    }
    qk.array_showviews = array_showVies;
    return qk;
}


@end
