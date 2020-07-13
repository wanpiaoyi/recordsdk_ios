//
//  ChooseLocalLive.m
//  QukanTool
//
//  Created by yang on 15/11/20.
//  Copyright © 2015年 yang. All rights reserved.
//

#import "ChooseLocalLive.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LiveRecordOrLocalRecord.h"
#import "RecordData.h"
#import "OSSSqlite.h"
#import "ClipPubThings.h"
#import "VideoManager.h"

@interface ChooseLocalLive ()<UIDocumentInteractionControllerDelegate>

@property(strong,nonatomic) LiveRecordOrLocalRecord *liveRecord; //活动直播录像
@property(strong,nonatomic) LiveRecordOrLocalRecord *localRecord;//本地直播录像
@property(strong,nonatomic) LiveRecordOrLocalRecord *localClip;//本地裁剪
@property(strong,nonatomic) LiveRecordOrLocalRecord *imgRecord;//本地图片地址
@property(strong,nonatomic) LiveRecordOrLocalRecord *audioRecord;//音乐地址

@property(strong,nonatomic) IBOutlet UIView *v_edict;

@property(strong,nonatomic) IBOutlet UIView *v_exportview;
@property(strong,nonatomic) IBOutlet UIView *v_exportcancel;


@property(strong,nonatomic) IBOutlet UIImageView *image;//全选打钩的图片
@property(strong,nonatomic) IBOutlet UIButton *btn_all;//全选按钮
@property(strong,nonatomic) IBOutlet UIButton *btn_edict;//编辑按钮

@property(strong,nonatomic) IBOutlet UIView *v_viewedict; //全选等控制
@property(strong,nonatomic) IBOutlet UIView *v_top; //全选等控制

@property(strong,nonatomic) IBOutlet UIButton *btn1;
@property(strong,nonatomic) IBOutlet UIButton *btn2;
@property(strong,nonatomic) IBOutlet UIButton *btn3;
@property(strong,nonatomic) IBOutlet UIButton *btn4;
@property(strong,nonatomic) IBOutlet UIButton *btn5;
@property(strong,nonatomic) IBOutlet UILabel *lbl_backscroll;
@property(strong,nonatomic) UIDocumentInteractionController *documentController;
@property(weak,nonatomic) id btnsel;

@property(nonatomic, strong) UIView *selectView;

@property(nonatomic, strong) RecordData *selectdata;

@property NSInteger flag1;
@property NSInteger select;
@property BOOL isedict;


@property(strong,nonatomic) IBOutlet UIView *v_chooseUsers;
@property(strong,nonatomic) IBOutlet UIView *v_showChooseUsers;

@property(copy,nonatomic) NSString *selectToken;


@end

@implementation ChooseLocalLive

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.select==0){
        self.btnsel = self.btn1;
        [self switchLive:1 changestate:YES];
    }else{
        [self switchLive:self.select changestate:YES];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (@available(iOS 13.0, *)) {
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];

     }else{
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
     }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //状态栏占据位置
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;

}




-(IBAction)removeShowUsers:(id)sender{
    [self.v_showChooseUsers removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showLive = videoManager.liveVideoShow;
    self.showRecord = videoManager.recordVideoShow;
    self.showClip = videoManager.clipVideoShow;

    
    self.select = 0;
    NSInteger count = 0;
    if(self.showLive){
        count++;
    }
    if(self.showClip){
        count++;
    }
    if(self.showRecord){
        count++;
    }
    NSInteger width = clipPubthings.screen_width/count;
    NSInteger useCount = 0;
    if(self.showLive){
        self.btn1.frame = CGRectMake(useCount*width, 0, width, 38);
        useCount++;
        if(self.select==0){
            self.select = 1;
            self.btnsel = self.btn1;

        }
    }else{
        self.btn1.hidden = YES;
    }
    if(self.showRecord){
        self.btn2.frame = CGRectMake(width*useCount, 0, width, 38);
        useCount++;
        if(self.select==0){
            self.select = 2;
            self.btnsel = self.btn2;

        }
    }else{
        self.btn2.hidden = YES;
    }
    
    if(self.showClip){
        self.btn3.frame = CGRectMake(width*useCount, 0, width, 38);
        useCount++;
        if(self.select==0){
            self.select = 3;
            self.btnsel = self.btn3;
        }
    }else{
        self.btn3.hidden = YES;
    }
    
    [self.btnsel setTitleColor:[UIColor colorWithRed:255/255.0 green:100/255.0 blue:32/255.0 alpha:1.0] forState:UIControlStateNormal];

    
    self.lbl_backscroll.frame = CGRectMake(0, 38, width, 2);
    
    self.v_exportview.layer.cornerRadius = 5;
    self.v_exportcancel.layer.cornerRadius = 5;
    if(useCount <= 1){
        self.v_top.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}



-(IBAction)chooseSelect:(id)sender{
    [self.btnsel setTitleColor:[UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0] forState:UIControlStateNormal];

    UIButton *btn = (UIButton*)sender;
    
    [btn setTitleColor:[UIColor colorWithRed:255/255.0 green:100/255.0 blue:32/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.btnsel = btn;
    
    [self switchLive:btn.tag changestate:NO];
    [self showgundong:btn.frame];
}

//显示控制条
-(void)showedict{
    self.v_edict.frame = self.view.bounds;
    [self.view addSubview:self.v_edict];
}

-(IBAction)hidEdict:(id)sender{
    [self.v_edict removeFromSuperview];
}

-(void)switchLive:(NSInteger)tag changestate:(BOOL)change{
    if(self.select==tag&&!change){
        return;
    }
    if(self.selectView!=nil){
        [self.selectView removeFromSuperview];
    }
    self.select = tag;
    
    [self endEdict];
    self.btn_edict.hidden = YES;
    WS(weakSelf);
    switch (tag) {
        case 1:
            if(self.liveRecord==nil){
                self.liveRecord = [[LiveRecordOrLocalRecord alloc] initWithFrame:CGRectMake(0, 112, clipPubthings.screen_width, clipPubthings.screen_height - 112- 0)];
                self.liveRecord.useedict = ^(RecordData *data){
                    weakSelf.selectdata = data;
                    [weakSelf showedict];
                };
                self.liveRecord.select = ^(NSInteger seltype){
                    switch (seltype) {
                        case 0:
                            weakSelf.btn_all.tag = 0;
                            [weakSelf.image setImage:[UIImage imageNamed:@"qktool_more_select"]];

                            break;
                            
                        case 1:
                            weakSelf.btn_all.tag = 1;
                            [weakSelf.image setImage:[UIImage imageNamed:@"qktool_more_selected"]];

                            break;
                            
                        default:
                            break;
                    }
                };
                [self.liveRecord setRecordSearch:liveType];
            }
            
            self.selectView = self.liveRecord;
            
            break;
        case 2:
            if(self.localRecord==nil){
                self.localRecord = [[LiveRecordOrLocalRecord alloc] initWithFrame:CGRectMake(0, 112, clipPubthings.screen_width, clipPubthings.screen_height - 112- 0)];
                self.localRecord.useedict = ^(RecordData *data){
                    weakSelf.selectdata = data;
                    [weakSelf showedict];
                };
                self.localRecord.select = ^(NSInteger seltype){
                    switch (seltype) {
                        case 0:
                            weakSelf.btn_all.tag = 0;
                            [weakSelf.image setImage:[UIImage imageNamed:@"qktool_more_select"]];
                            
                            break;
                            
                        case 1:
                            weakSelf.btn_all.tag = 1;
                            [weakSelf.image setImage:[UIImage imageNamed:@"qktool_more_selected"]];
                            
                            break;
                            
                        default:
                            break;
                    }
                };
                [self.localRecord setRecordSearch:localRecordType];


            }
            self.selectView = self.localRecord;
            break;
        case 3:
            if(self.localClip==nil){
                self.localClip = [[LiveRecordOrLocalRecord alloc] initWithFrame:CGRectMake(0, 112, clipPubthings.screen_width, clipPubthings.screen_height - 112- 0)];
                self.localClip.useedict = ^(RecordData *data){
                    weakSelf.selectdata = data;
                    [weakSelf showedict];
                };
                self.localClip.select = ^(NSInteger seltype){
                    switch (seltype) {
                        case 0:
                            weakSelf.btn_all.tag = 0;
                            [weakSelf.image setImage:[UIImage imageNamed:@"qktool_more_select"]];
                            
                            break;
                            
                        case 1:
                            weakSelf.btn_all.tag = 1;
                            [weakSelf.image setImage:[UIImage imageNamed:@"qktool_more_selected"]];
                            
                            break;
                            
                        default:
                            break;
                    }
                };
            }
            [self.localClip setRecordSearch:clipType];

            self.selectView = self.localClip;

            break;
        case 4:
            
            if(self.imgRecord==nil){
                self.imgRecord = [[LiveRecordOrLocalRecord alloc] initWithFrame:CGRectMake(0, 112, clipPubthings.screen_width, clipPubthings.screen_height - 112- 0)];
                self.imgRecord.useedict = ^(RecordData *data){
                    weakSelf.selectdata = data;
                    [weakSelf showedict];
                };
                self.imgRecord.select = ^(NSInteger seltype){
                    switch (seltype) {
                        case 0:
                            weakSelf.btn_all.tag = 0;
                            [weakSelf.image setImage:[UIImage imageNamed:@"qktool_more_select"]];
                            
                            break;
                            
                        case 1:
                            weakSelf.btn_all.tag = 1;
                            [weakSelf.image setImage:[UIImage imageNamed:@"qktool_more_selected"]];
                            
                            break;
                            
                        default:
                            break;
                    }
                };
                [self.imgRecord setRecordSearch:imageType];
                
                
            }
            
            self.selectView = self.imgRecord;
            break;
        case 5:
            
            if(self.audioRecord==nil){
                self.audioRecord = [[LiveRecordOrLocalRecord alloc] initWithFrame:CGRectMake(0, 112, clipPubthings.screen_width, clipPubthings.screen_height - 112- 0)];
                self.audioRecord.useedict = ^(RecordData *data){
                    weakSelf.selectdata = data;
                    [weakSelf showedict];
                };
                self.audioRecord.select = ^(NSInteger seltype){
                    switch (seltype) {
                        case 0:
                            weakSelf.btn_all.tag = 0;
                            [weakSelf.image setImage:[UIImage imageNamed:@"qktool_more_select"]];
                            
                            break;
                            
                        case 1:
                            weakSelf.btn_all.tag = 1;
                            [weakSelf.image setImage:[UIImage imageNamed:@"qktool_more_selected"]];
                            
                            break;
                            
                        default:
                            break;
                    }
                };
                [self.audioRecord setRecordSearch:localAudioType];
                
                
            }
            
            self.selectView = self.audioRecord;
            break;
            
        default:
            break;
    }
    float safeTop = 20;
    float safeBottom = 0;
    // iPhone X以上设备iOS版本一定是11.0以上。
    if (@available(iOS 11.0, *)) {
        // 利用safeAreaInsets.bottom > 0.0来判断是否是iPhone X以上设备。
        UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
        if (window.safeAreaInsets.bottom > 0.0) {
            safeTop = window.safeAreaInsets.top;
            safeBottom = window.safeAreaInsets.bottom;
        }
    }

    
    if(self.v_top.hidden == YES){
        self.selectView.frame = CGRectMake(0, 54, clipPubthings.screen_width, clipPubthings.allHeight - 54 - safeTop  - safeBottom);
    }else{
        self.selectView.frame = CGRectMake(0, 100, clipPubthings.screen_width, clipPubthings.allHeight - 100 - safeTop  - safeBottom);
    }
    
    
    
    [self.v_maincontroller addSubview:self.selectView];
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"呵呵";
    if (!error) {
        [pgToast setText:@"导入相册成功"];
    }else
    {
        [pgToast setText:@"导入相册失败"];
    }
    NSLog(@"message is %@",message);
}
#pragma mark - 导出、删除、剪辑、上船

-(IBAction)exportButton:(id)sender
{
    if(!self.selectdata){
        return;
    }
    NSString *str = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,self.selectdata.address];
    if([self.selectdata.type isEqualToString:@"image"]){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        
        if(![fileManager fileExistsAtPath:str]){
            return;
        }
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:str];
        if(img!=nil){
            UIImageWriteToSavedPhotosAlbum(img, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        }
        

        return;
    }
    
    
    
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.v_maincontroller];
    [self.v_maincontroller addSubview:HUD];
    
    HUD.labelText = @"视频导入相册中";
    
    WS(weakSelf);
    //显示对话框
    [HUD showAnimated:YES whileExecutingBlock:^{
        //对话框显示时需要执行的操作
        
        
        weakSelf.flag1 = 0;
        
        if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(str))
        {
            UISaveVideoAtPathToSavedPhotosAlbum(str, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
            while (weakSelf.flag1 == 0)
            {
                
                usleep(50*1000);
            }
            
        }else
        {
            QukanAlert *alert = [[QukanAlert alloc] initWithCotent:@"文件异常,无法导入相册" Delegate:nil] ;
            [alert show];
        }
        
    }completionBlock:^{
        
        //操作执行完后取消对话框
        
        [HUD removeFromSuperview];
        [self hidEdict:nil];
        [pgToast setText:@"文件导出成功"];
        
    }];
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    self.flag1 = 1;
}

//分享
-(IBAction)shareButtonPressed:(id)sender
{

    if(!self.selectdata){
        return;
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,self.selectdata.address];

    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
     
    documentController.delegate = self;
//    documentController.UTI = @"com.qk.zjgd";//You need to set the UTI (Uniform Type Identifiers) for the documentController object so that it can help the system find the appropriate application to open your document. In this case, it is set to “com.adobe.pdf”, which represents a PDF document. Other common UTIs are "com.apple.quicktime-movie" (QuickTime movies), "public.html" (HTML documents), and "public.jpeg" (JPEG files)

    self.documentController = documentController;
    [documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    [self hidEdict:nil];
}

-(IBAction)deleteButtonPressed:(id)sender
{
    if(!self.selectdata){
        return;
    }
    
    NSString *str = [NSString stringWithFormat:@"%@/%@",clipPubthings.pressfixPath,self.selectdata.fileName];
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.v_maincontroller];
    [self.v_maincontroller addSubview:HUD];
    HUD.labelText = @"视频删除中...";
    
    
    __weak OSSSqlite *weak_oss = ossSynch;
    WS(weakSelf);
    //显示对话框
    [HUD showAnimated:YES whileExecutingBlock:^{
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:weakSelf.selectdata];
        //对话框显示时需要执行的操作
        [weak_oss deleteNameOrAddress:array];
        
    }completionBlock:^{
        switch (weakSelf.select) {
            case 1:
                [weakSelf.liveRecord removeDateThings:weakSelf.selectdata];
                break;
            case 2:
                [weakSelf.localRecord removeDateThings:weakSelf.selectdata];
                break;
            case 3:
                [weakSelf.localClip removeDateThings:weakSelf.selectdata];
                break;
            case 4:
                [weakSelf.imgRecord removeDateThings:weakSelf.selectdata];
                break;
            case 5:
                [weakSelf.audioRecord removeDateThings:weakSelf.selectdata];
                break;
               
            default:
                break;
        }
        [HUD removeFromSuperview];
    }];
    [self hidEdict:nil];
}


//显示全选按钮等
-(IBAction)changeEdict:(id)sender{
//    if(self.select ==4){
//        return;
//    }
    if(self.isedict){
        [self endEdict];
    }else{
        if([self.selectView isKindOfClass:[LiveRecordOrLocalRecord class]]){
            LiveRecordOrLocalRecord *record = (LiveRecordOrLocalRecord*)self.selectView;
            [record startEdict];
            [self startEdict];
            self.selectView.frame = CGRectMake(0, 112 + 34, clipPubthings.screen_width, clipPubthings.screen_height - 112 - 0 - 35);
        }
    }
}

//全选按钮出发事件
-(IBAction)selectAllCell:(id)sender
{
    BOOL selectAll = NO;
    UIButton *button = (UIButton*)sender;
    if (button.tag == 0)
    {
        button.tag = 1;
        
        [self.image setImage:[UIImage imageNamed:@"qktool_more_selected"]];
        selectAll = YES;
        
        
    }else
    {
        button.tag = 0;
        [self.image setImage:[UIImage imageNamed:@"qktool_more_select"]];
  
    }
    if([self.selectView isKindOfClass:[LiveRecordOrLocalRecord class]]){
        LiveRecordOrLocalRecord *record = (LiveRecordOrLocalRecord*)self.selectView;
        [record selectAllCell:selectAll];
    }

}

-(void)startEdict{
    [self.btn_edict setTitle:@"" forState:UIControlStateNormal];
    
    [self.btn_edict setBackgroundImage:[UIImage imageNamed:@"qktool_file_delete"] forState:UIControlStateNormal];
    self.isedict = YES;
    self.v_viewedict.hidden = NO;
    self.btn_all.tag = 0;
    [self.image setImage:[UIImage imageNamed:@"qktool_more_select"]];

}

-(void)endEdict{
//    if(self.select)
    if(self.isedict){
        switch (self.select) {
            case 1:
                [self.liveRecord edictEnded];
                break;
            case 2:
                [self.localRecord edictEnded];
                break;
            case 3:
                [self.localClip edictEnded];
                break;
            case 4:
                [self.imgRecord edictEnded];
                break;
            case 5:
                [self.audioRecord edictEnded];
                break;
            default:
                break;
        }
        self.selectView.frame = CGRectMake(0, 112, clipPubthings.screen_width, clipPubthings.screen_height - 112 - 0);
        
        self.v_viewedict.hidden = YES;
        self.btn_all.tag = 0;
        self.isedict = NO;
        [self.image setImage:[UIImage imageNamed:@"qktool_more_select"]];
        [self.btn_edict setBackgroundImage:nil forState:UIControlStateNormal];
        [self.btn_edict setTitle:@"多选" forState:UIControlStateNormal];
    }
}



-(IBAction)deleteAllSelect:(id)sender{
    if([self.selectView isKindOfClass:[LiveRecordOrLocalRecord class]]){
        LiveRecordOrLocalRecord *record = (LiveRecordOrLocalRecord*)self.selectView;
        [record deleteSelectDatas];
    }
}

#pragma mark - 顶部切换的时候滑块的滚动
- (void)showgundong:(CGRect)rect {
    float marginLeft = rect.origin.x;

    WS(weakSelf);
    [UIView animateWithDuration:0.3
                     animations:^{
                         [weakSelf.lbl_backscroll setFrame:CGRectMake(marginLeft, 38, weakSelf.lbl_backscroll.frame.size.width, 2)];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}



- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller canPerformAction:(nullable SEL)action
{
    // 响应方法
    NSLog(@"12 %s", __func__);
    return YES;
}
 
- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller performAction:(nullable SEL)action
{
    //
    NSLog(@"13 %s", __func__);
    return YES;
}
 
- (void)documentInteractionControllerWillPresentOptionsMenu:(UIDocumentInteractionController *)controller
{
    // 页面显示后响应
    NSLog(@"9 %s", __func__);
}
 
- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller
{
    // 取消时响应
    NSLog(@"10 %s", __func__);
}
 
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    NSLog(@"1 %s", __func__);
    return self;
}
 
- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    NSLog(@"2 %s", __func__);
    return self.view;
}
 
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    NSLog(@"3 %s", __func__);
    return self.view.frame;
}
 
// 文件分享面板退出时调用
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"4 %s", __func__);
    NSLog(@"dismiss");
}
 
// 文件分享面板弹出的时候调用
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"5 %s", __func__);
    NSLog(@"WillPresentOpenInMenu");
}
 
// 当选择一个文件分享App的时候调用
- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(nullable NSString *)application
{
    NSLog(@"6 %s", __func__);
    NSLog(@"begin send : %@", application);
}
 
// Preview presented/dismissed on document.  Use to set up any HI underneath.
- (void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller
{
    NSLog(@"7 %s", __func__);
}
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    // 完成时响应
    NSLog(@"8 %s", __func__);
}
 
- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(nullable NSString *)application
{
    NSLog(@"11 %s", __func__);
}

@end
