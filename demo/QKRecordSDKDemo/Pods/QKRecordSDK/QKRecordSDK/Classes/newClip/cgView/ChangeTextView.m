//
//  ChangeTextView.m
//  QukanTool
//
//  Created by yang on 17/6/19.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "ChangeTextView.h"
#import "ChooseColorCell.h"
#import "QKMoviePart.h"
#import "ClipPubThings.h"
#import "MovieClipDataBase.h"


@interface ChangeTextView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(strong,nonatomic) NSArray *array_colorList;
@property(strong,nonatomic) UICollectionView *collect;

@property(strong,nonatomic) IBOutlet UIView *v_msg;

@property(strong,nonatomic) IBOutlet UIView *v_collect;
@property(strong,nonatomic) IBOutlet UIView *v_value;

@property(strong,nonatomic)IBOutlet UITextField *fld_text;
@property(strong,nonatomic)IBOutlet UIView *v_bottom;
@property(strong,nonatomic) IBOutlet UISlider *sld_size;
@property(strong,nonatomic) IBOutlet UISlider *sld_during;
@property(strong,nonatomic) IBOutlet UISlider *sld_startTime;
@property(strong,nonatomic) IBOutlet UISlider *sld_alpha;
@property(strong,nonatomic) IBOutlet UILabel *lbl_size;
@property(strong,nonatomic) IBOutlet UILabel *lbl_time;
@property(strong,nonatomic) IBOutlet UILabel *lbl_startTime;
@property(strong,nonatomic) IBOutlet UILabel *lbl_alpha;

@property(strong,nonatomic) NSArray *array_parts;
@property(copy,nonatomic) NSString *color;
@property(strong,nonatomic) IBOutlet UIButton *btn_close;

@property(strong,nonatomic) IBOutlet UILabel *lbl_text;;
@property(strong,nonatomic) IBOutlet UIView *v_text;;

@property(strong,nonatomic) IBOutlet NSLayoutConstraint *height;


@end

@implementation ChangeTextView

//键盘高度变化的通知回调函数
- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow");
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardBounds =
    [[info objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;
    self.v_bottom.frame = CGRectMake(0, qk_screen_height - self.v_bottom.frame.size.height - keyboardBounds.height, self.v_bottom.frame.size.width, self.v_bottom.frame.size.height);
    self.height.constant = qk_screen_height - self.v_bottom.frame.size.height - keyboardBounds.height;
}


-(id)init:(NSString*)text color:(NSString*)color fontSize:(NSInteger)fontSize during:(double)during startTime:(double)startTime{
    
    if(self = [super initWithFrame:CGRectMake(0, 0, qk_screen_width, qk_screen_height)]){
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(keyboardWillShow:)
         name:UIKeyboardWillShowNotification
         object:nil];
        
        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"ChangeTextView1" owner:self options:nil];
        UIView *v_addName = [array firstObject];
        v_addName.frame = self.bounds;
        [self addSubview:v_addName];
        
        [self hiddenAll];
        self.v_msg.hidden = NO;
        
        self.v_bottom.frame = CGRectMake(0, self.frame.size.height - 115, self.v_bottom.frame.size.width, 115);
        self.fld_text.text = text;
        self.fld_text.layer.cornerRadius = 3.0;
        self.fld_text.layer.borderWidth = 1;
        self.fld_text.layer.borderColor = [UIColor colorWithRed:188/255.0 green:188/255.0 blue:188/255.0 alpha:1.0].CGColor;
        
        self.height.constant = self.frame.size.height - 115;

        
        [self initCollection];
        self.color = color;
        double alpha = [self getAlpha:color];
        self.sld_size.value = fontSize;
        self.sld_during.value = during;
        self.sld_alpha.value = alpha;
        self.lbl_size.text = [NSString stringWithFormat:@"%ldpt",fontSize];
        self.lbl_time.text = [NSString stringWithFormat:@"%.2lfs",during];
        self.lbl_alpha.text = [NSString stringWithFormat:@"%.0lf%%",alpha*100];
 
        //这里需要客户根据自身需求进行修改，字幕裁剪需要获取到当前视频的所有片段进行计算
        NSArray *array_parts = [clipData getMovies];
        self.array_parts = array_parts;
        double allTime = 0;
        for(QKMoviePart *part in array_parts){
            part.beginTime = allTime;
            allTime += part.movieDuringTime;
        }
        self.sld_startTime.maximumValue = allTime;
        self.sld_startTime.value = startTime;
        self.lbl_startTime.text = [NSString stringWithFormat:@"%.1lfs",startTime];
        
        
        [self.sld_size setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateHighlighted];
        [self.sld_size setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateNormal];
        
        [self.sld_alpha setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateHighlighted];
        [self.sld_alpha setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateNormal];
        
        [self.sld_during setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateHighlighted];
        [self.sld_during setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateNormal];
        
        [self.sld_startTime setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateHighlighted];
        [self.sld_startTime setThumbImage:[clipPubthings imageNamed:@"video_edit_dubbed_scroll_bars"] forState:UIControlStateNormal];
        [self.fld_text becomeFirstResponder];
        [self.btn_close setTitleColor:clipPubthings.color forState:UIControlStateNormal];
        
        [self.fld_text addTarget:self action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
     
        self.lbl_text.text = text;
        self.lbl_text.font = [UIFont systemFontOfSize:fontSize];
        self.lbl_text.textColor = [self getColorFromString:color];
    }
    return self;
}


-(IBAction)sureView:(id)sender{
    NSString *str = self.fld_text.text;
    if(str == nil || str.length == 0){
        NSLog(@"内容不能为空哟");
        return;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.fld_text resignFirstResponder];
    [self removeFromSuperview];

    
}


-(void)changeBackColor:(UIColor*)color{
    self.v_text.backgroundColor = color;
}


-(IBAction)changeType:(id)sender{
    [self hiddenAll];
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case 0:
            self.v_msg.hidden = NO;
            if(![self.fld_text isFirstResponder]){
                self.v_bottom.frame = CGRectMake(0, qk_screen_height - self.v_bottom.frame.size.height, self.v_bottom.frame.size.width, 115);
                self.height.constant = qk_screen_height - self.v_bottom.frame.size.height;
                [self.fld_text becomeFirstResponder];
                
                
            }
            break;
        case 1:
            self.v_collect.hidden = NO;
            self.v_bottom.frame = CGRectMake(0, self.frame.size.height - 350, self.v_bottom.frame.size.width, 350);
            [self.fld_text resignFirstResponder];
            self.height.constant = self.frame.size.height - 350;
            break;
        case 2:
            self.v_value.hidden = NO;
            self.v_bottom.frame = CGRectMake(0, self.frame.size.height - 350, self.v_bottom.frame.size.width, 350);
            [self.fld_text resignFirstResponder];
            self.height.constant = self.frame.size.height - 350;
            break;
        default:
            break;
    }
}

-(void)hiddenAll{
    self.v_msg.hidden = YES;
    self.v_collect.hidden = YES;
    self.v_value.hidden = YES;
}
#pragma mark - 隐藏键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

#pragma mark - 字幕的色值大小等调整
-(IBAction)changeSize:(id)sender{
    double value = self.sld_size.value;
    self.lbl_size.text = [NSString stringWithFormat:@"%.0lfpt",value];
    QKTextChangeBean *bean = [[QKTextChangeBean alloc] init];
    bean.textColor = [self getColorFromString:self.color];
    bean.textValue = self.fld_text.text;
    bean.size = value;
    [self textChangeValue:TextChangeSize bean:bean];
    self.lbl_text.font = [UIFont systemFontOfSize:value];

}
-(IBAction)changeDuring:(id)sender{
    double value = self.sld_during.value;
    self.lbl_time.text = [NSString stringWithFormat:@"%.2lfs",value];
    QKTextChangeBean *bean = [[QKTextChangeBean alloc] init];
    bean.textColor = [self getColorFromString:self.color];
    bean.textValue = self.fld_text.text;
    bean.endTime = self.sld_during.value;
    [self textChangeValue:TextChangeDuring bean:bean];
}

-(IBAction)changeStartTime:(id)sender{
    double value = self.sld_startTime.value;
    self.lbl_startTime.text = [NSString stringWithFormat:@"%.2lfs",value];
    
    QKTextChangeBean *bean = [[QKTextChangeBean alloc] init];
    bean.textColor = [self getColorFromString:self.color];
    bean.textValue = self.fld_text.text;
    [self getMoviePartId:value qkshow:bean];
    bean.endTime = self.sld_during.value;
    [self textChangeValue:TextChangeStartTime bean:bean];
}

-(IBAction)changeAlpha:(id)sender{
    double value = self.sld_alpha.value;
    self.lbl_alpha.text = [NSString stringWithFormat:@"%.0lf%%",value*100];
    
    self.color = [self changeColor:self.color alpha:value];
    
    QKTextChangeBean *bean = [[QKTextChangeBean alloc] init];
    bean.textColor = [self getColorFromString:self.color];
    bean.textValue = self.fld_text.text;
    
    [self textChangeValue:TextChangeAlpha bean:bean];
    self.lbl_text.textColor = [self getColorFromString:self.color];
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange：%@", textView.text);
    QKTextChangeBean *bean = [[QKTextChangeBean alloc] init];
    bean.textColor = [self getColorFromString:self.color];
    bean.textValue = textView.text;
    [self textChangeValue:TextChangeText bean:bean];
}

- (void)textFieldTextChanged:(UITextField *)textView {
    NSLog(@"textViewDidChange：%@", textView.text);
    self.lbl_text.text = textView.text;
    QKTextChangeBean *bean = [[QKTextChangeBean alloc] init];
    bean.textColor = [self getColorFromString:self.color];
    bean.textValue = textView.text;
    [self textChangeValue:TextChangeText bean:bean];
}

-(void)textChangeValue:(TextChange)state bean:(QKTextChangeBean *)bean{
    changeTextValue getText = self.getText;
    if(getText){
        getText(state,bean);
    }
}

#pragma mark - 字幕列表



-(void)initCollection{
    self.array_colorList = [self getColorList];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(60, 60)]; //设置cell的尺寸
    //    CGSize size = CGSizeMake(previewWidth, previewheight);
    flowLayout.sectionInset = UIEdgeInsetsMake(15, 11, 15,11); //设置其边界
    self.collect = [[UICollectionView alloc]
                    initWithFrame:CGRectMake(0, 0, self.frame.size.width,355)
                    collectionViewLayout:flowLayout];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical]; //设置其布局方向
    
    self.collect.dataSource = self;
    self.collect.delegate = self;
    self.collect.backgroundColor = [UIColor clearColor];
    self.collect.scrollEnabled = YES;
    UINib *nib = [UINib nibWithNibName:@"ChooseColorCell"
                                bundle:[clipPubthings clipBundle]];
    [self.collect registerNib:nib forCellWithReuseIdentifier:@"cell"];
    [self.v_collect addSubview:self.collect];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    if (self.array_colorList == nil || self.array_colorList.count == 0) {
        return 0;
    }
    return self.array_colorList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str = @"cell";
    NSString *color = self.array_colorList[indexPath.row];
    ChooseColorCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:str
                                              forIndexPath:indexPath];
    cell.backgroundColor = [self getColorFromString:color];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *color = self.array_colorList[indexPath.row];
    
    self.color = [self changeColor:color alpha:self.sld_alpha.value];
    
    QKTextChangeBean *bean = [[QKTextChangeBean alloc] init];
    bean.textColor = [self getColorFromString:self.color];
    bean.textValue = self.fld_text.text;
    [self textChangeValue:TextChangeAlpha bean:bean];
    
    self.lbl_text.textColor = [self getColorFromString:self.color];
}

-(NSString*)changeColor:(NSString*)color alpha:(double)value{
    if(color == nil){
        return @"0,0,0,0";
    }
    NSArray *rgbArray = [color componentsSeparatedByString:@","];
    if(rgbArray.count == 4){
        return [NSString stringWithFormat:@"%@,%@,%@,%.4lf",rgbArray[0],rgbArray[1],rgbArray[2],value];
    }
    return @"0,0,0,0";

}

//把string转color
-(UIColor*)getColorFromString:(NSString *)backGroundColor{
    if(backGroundColor == nil){
        return [UIColor clearColor];
    }
    NSArray *rgbArray = [backGroundColor componentsSeparatedByString:@","];
    if(rgbArray.count == 4){
        return [UIColor colorWithRed:[rgbArray[0] floatValue] green:[rgbArray[1] floatValue] blue:[rgbArray[2] floatValue] alpha:[rgbArray[3] floatValue]];
    }
    return [UIColor clearColor];
}

//把string转color
-(double)getAlpha:(NSString *)backGroundColor{
    if(backGroundColor == nil){
        return 0;
    }
    NSArray *rgbArray = [backGroundColor componentsSeparatedByString:@","];
    if(rgbArray.count == 4){
        return [rgbArray[3] floatValue];
    }
    return 0;
}

//获取视频片段
-(void)getMoviePartId:(double)begintime qkshow:(QKTextChangeBean *)bean{
    bean.startTime = begintime;
    double startTime = 0;
    for(int i =0;i<self.array_parts.count;i++){
        QKMoviePart *moviePart = self.array_parts[i];
        if(startTime <= begintime && startTime + moviePart.movieDuringTime > begintime){
            bean.moviePartId = moviePart.moviePartId;
            bean.softStartTime = (begintime - startTime)*moviePart.speed + moviePart.movieStartTime;
            break;
        }
        startTime = startTime + moviePart.movieDuringTime;
    }
}

#pragma mark-获取颜色列表
-(NSArray*)getColorList{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    {
        double red = 0;
        double green = 0;
        double blue = 0;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    {
        double red = 255;
        double green = 255;
        double blue = 255;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 124;
        double green = 124;
        double blue = 124;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 246;
        double green = 41;
        double blue = 41;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 80;
        double green = 195;
        double blue = 44;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    
    {
        double red = 255;
        double green = 107;
        double blue = 18;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 53;
        double green = 142;
        double blue = 242;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    {
        double red = 159;
        double green = 88;
        double blue = 255;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    {
        double red = 255;
        double green = 219;
        double blue = 19;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 35;
        double green = 220;
        double blue = 205;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 186;
        double green = 208;
        double blue = 38;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 255;
        double green = 78;
        double blue = 124;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 100;
        double green = 90;
        double blue = 232;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    
    {
        double red = 135;
        double green = 238;
        double blue = 221;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 153;
        double green = 121;
        double blue = 107;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 111;
        double green = 135;
        double blue = 163;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 162;
        double green = 87;
        double blue = 64;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 202;
        double green = 174;
        double blue = 140;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    
    {
        double red = 158;
        double green = 157;
        double blue = 97;
        [array addObject:[NSString stringWithFormat:@"%.5f,%.5f,%.5f,1.0",red/255.0,green/255.0,blue/255.0]];
    }
    return array;
}
@end
