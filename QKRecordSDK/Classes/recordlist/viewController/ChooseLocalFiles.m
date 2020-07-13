//
//  ChooseLocalFiles.m
//  QukanTool
//
//  Created by yang on 17/1/9.
//  Copyright © 2017年 yang. All rights reserved.
//

#import "ChooseLocalFiles.h"
#import "RecordData.h"
#import "ClipPubThings.h"

@interface ChooseLocalFiles ()
@property NSInteger select;
@property NSInteger videos_select;

@property(strong,nonatomic) SelectVideoByType *liveRecord; //活动直播录像
@property(strong,nonatomic) SelectVideoByType *localRecord;//本地直播录像
@property(strong,nonatomic) SelectVideoByType *localClip;//本地裁剪
@property(strong,nonatomic) SelectVideoByType *localImage;//本地图片
@property(strong,nonatomic) SelectVideoByType *localAudio;//本地录音
@property(nonatomic, strong) UIView *selectView;


@property(strong,nonatomic) IBOutlet UIButton *btn1;
@property(strong,nonatomic) IBOutlet UIButton *btn2;
@property(strong,nonatomic) IBOutlet UIButton *btn3;
@property(weak,nonatomic) id btnsel;
@property(strong,nonatomic) IBOutlet UILabel *lbl_backscroll;
@property(strong,nonatomic) IBOutlet UIButton *btn_title;
@property(nonatomic) NSInteger selectFirst;

@property(strong,nonatomic) IBOutlet UIButton *btn_choose; //右边确认按钮
@property NSTimeInterval startTime;

@property(copy,nonatomic) NSString *fileInserName;


@end

@implementation ChooseLocalFiles
-(void)loadView{
    // Initialization code
    [[[clipPubthings clipBundle]  loadNibNamed:@"ChooseLocalFiles" owner:self options:nil] lastObject];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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

-(id)init{
    self = [super init];
    if(self){
        self.select = -1;
        self.selectFirst = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videos_select = 0;

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
    self.lbl_backscroll.frame = CGRectMake(0, 38, width, 2);
    [self.btn_title setTitle:@"选择源文件" forState:UIControlStateNormal];

    NSInteger useCount = 0;
    if(self.showRecord){
        self.btn1.frame = CGRectMake(useCount*width, 0, width, 38);
        useCount++;
        if(self.selectFirst == -1){
            self.selectFirst = 1;
        }
    }else{
        self.btn1.hidden = YES;
    }
    if(self.showLive){
        self.btn2.frame = CGRectMake(width*useCount, 0, width, 38);
        useCount++;
        if(self.selectFirst == -1){
            self.selectFirst = 2;
        }
    }else{
        self.btn2.hidden = YES;
    }
    
    if(self.showClip){
        self.btn3.frame = CGRectMake(width*useCount, 0, width, 38);
        useCount++;
        if(self.selectFirst == -1){
            self.selectFirst = 3;
        }
    }else{
        self.btn3.hidden = YES;
    }
    
    
    UIButton *btn = nil;
    switch (self.selectFirst) {
        case 1:
            btn = self.btn1;
            break;
        case 2:
            btn = self.btn2;
            break;
        case 3:
            btn = self.btn3;
            break;
        case 4:
            break;
        case 5:
            break;
            
        default:
            btn = self.btn1;
            break;
    };
    [self chooseSelect:btn];
    



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)chooseSelect:(id)sender{
    [self.btnsel setTitleColor:[UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    UIButton *btn = (UIButton*)sender;
    
    [btn setTitleColor:[UIColor colorWithRed:255/255.0 green:100/255.0 blue:32/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.btnsel = btn;
    
    [self switchLive:btn.tag changestate:NO];
    [self showgundong:btn.frame];
}

-(void)switchLive:(NSInteger)tag changestate:(BOOL)change{
    if(self.select==tag&&!change){
        return;
    }
    if(self.selectView!=nil){
        [self.selectView removeFromSuperview];
    }
    self.select = tag;
    
    WS(weakSelf);
    switch (tag) {
        case 1:
            
            if(self.liveRecord==nil){
                self.liveRecord = [[SelectVideoByType alloc] initWithFrame:CGRectMake(0, 112, clipPubthings.screen_width, clipPubthings.screen_height - 112)];
                self.liveRecord.justOne = self.justOne;
                self.liveRecord.selectOne = ^(BOOL select){
                    if(weakSelf.justOne){
                        [weakSelf selectAllVideos:nil];
                    }else{
                        if(select){
                            weakSelf.videos_select++;
                        }else{
                            weakSelf.videos_select--;
                        }
                        [weakSelf.btn_choose setTitle:[NSString stringWithFormat:@"确认(%ld)",weakSelf.videos_select] forState:UIControlStateNormal];
                    }
                };
                self.liveRecord.fileInserName = self.fileInserName;
                self.liveRecord.startTime = self.startTime;
                [self.liveRecord setRecordSearch:liveType];
                
            }
            self.selectView = self.liveRecord;
            
            
            break;
        case 2:
            if(self.localRecord==nil){
                self.localRecord = [[SelectVideoByType alloc] initWithFrame:CGRectMake(0, 112, clipPubthings.screen_width, clipPubthings.screen_height - 112)];
                self.localRecord.justOne = self.justOne;
                self.localRecord.selectOne = ^(BOOL select){
                    if(weakSelf.justOne){
                        [weakSelf selectAllVideos:nil];
                    }else{
                        if(select){
                            weakSelf.videos_select++;
                        }else{
                            weakSelf.videos_select--;
                        }
                        [weakSelf.btn_choose setTitle:[NSString stringWithFormat:@"确认(%ld)",weakSelf.videos_select] forState:UIControlStateNormal];
                    }
                    
                };
                self.localRecord.fileInserName = self.fileInserName;
                self.localRecord.startTime = self.startTime;

                [self.localRecord setRecordSearch:localRecordType];
                
            }
            self.selectView = self.localRecord;
            break;
        case 3:
            if(self.localClip==nil){
                self.localClip = [[SelectVideoByType alloc] initWithFrame:CGRectMake(0, 112, clipPubthings.screen_width, clipPubthings.screen_height - 112)];
                self.localClip.justOne = self.justOne;

                self.localClip.selectOne = ^(BOOL select){
                    if(weakSelf.justOne){
                        [weakSelf selectAllVideos:nil];
                    }else{
                        if(select){
                            weakSelf.videos_select++;
                        }else{
                            weakSelf.videos_select--;
                        }
                        [weakSelf.btn_choose setTitle:[NSString stringWithFormat:@"确认(%ld)",weakSelf.videos_select] forState:UIControlStateNormal];
                    }
                };
                self.localClip.fileInserName = self.fileInserName;
                self.localClip.startTime = self.startTime;
                [self.localClip setRecordSearch:clipType];

                
            }
            self.selectView = self.localClip;
            
            break;
        case 4:
            if(self.localImage==nil){
                self.localImage = [[SelectVideoByType alloc] initWithFrame:CGRectMake(0, 112, clipPubthings.screen_width, clipPubthings.screen_height - 112)];
                self.localImage.justOne = self.justOne;
                
                self.localImage.selectOne = ^(BOOL select){
                    if(weakSelf.justOne){
                        [weakSelf selectAllVideos:nil];
                    }else{
                        if(select){
                            weakSelf.videos_select++;
                        }else{
                            weakSelf.videos_select--;
                        }
                        [weakSelf.btn_choose setTitle:[NSString stringWithFormat:@"确认(%ld)",weakSelf.videos_select] forState:UIControlStateNormal];
                    }
                };
                self.localImage.fileInserName = self.fileInserName;
                self.localImage.startTime = self.startTime;
                [self.localImage setRecordSearch:imageType];
                
                
            }
            self.selectView = self.localImage;
            
            break;
        case 5:
            if(self.localAudio==nil){
                self.localAudio = [[SelectVideoByType alloc] initWithFrame:CGRectMake(0, 112, clipPubthings.screen_width, clipPubthings.screen_height - 112)];
                self.localAudio.justOne = self.justOne;
                
                self.localAudio.selectOne = ^(BOOL select){
                    if(weakSelf.justOne){
                        [weakSelf selectAllVideos:nil];
                    }else{
                        if(select){
                            weakSelf.videos_select++;
                        }else{
                            weakSelf.videos_select--;
                        }
                        [weakSelf.btn_choose setTitle:[NSString stringWithFormat:@"确认(%ld)",weakSelf.videos_select] forState:UIControlStateNormal];
                    }
                };
                self.localAudio.fileInserName = self.fileInserName;
                self.localAudio.startTime = self.startTime;
                [self.localAudio setRecordSearch:localAudioType];
                
                
            }
            self.selectView = self.localAudio;
            
            break;
        default:
            break;
    }
    self.selectView.frame = CGRectMake(0, 94, clipPubthings.screen_width, clipPubthings.screen_height - 94 );
    
    
    
    [self.v_maincontroller addSubview:self.selectView];
}

-(IBAction)selectAllVideos:(id)sender{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(RecordData *data in self.liveRecord.array_choose){
        [array addObject:data];
    }
    for(RecordData *data in self.localRecord.array_choose){
        [array addObject:data];
    }
    
    for(RecordData *data in self.localClip.array_choose){
        [array addObject:data];
    }
    for(RecordData *data in self.localImage.array_choose){
        [array addObject:data];
    }
    for(RecordData *data in self.localAudio.array_choose){
        [array addObject:data];
    }
    if(array.count == 0){
        QukanAlert *alert = [[QukanAlert alloc] initWithCotent:@"请选择至少一个文件" Delegate:nil];
        [alert show];
        return;
    }
    if(self.selectVideos){
        self.selectVideos(array);
    }
    [self back:nil];
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
                         [weakSelf.lbl_backscroll setFrame:CGRectMake(marginLeft, 38, weakSelf.lbl_backscroll.frame.size.width, 2)];
                     }];
}


@end
