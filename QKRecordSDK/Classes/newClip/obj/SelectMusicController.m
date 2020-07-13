//
//  SelectMusicController.m
//  QukanTool
//
//  Created by yangpeng on 2019/11/25.
//  Copyright © 2019 yang. All rights reserved.
//

#import "SelectMusicController.h"
#import "NothingCell.h"
#import "MusicSelectCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QKLiveAndRecord/QKRecordMP3ToPcm.h>
#import "ClipPubThings.h"
#import <StoreKit/StoreKit.h>
// Privacy classify 分类
typedef NS_ENUM(NSUInteger, QKECPrivacyType){
    QKECPrivacyType_None                  = 0,
    QKECPrivacyType_LocationServices      = 1,    // 定位服务
    QKECPrivacyType_Contacts              = 2,    // 通讯录
    QKECPrivacyType_Calendars             = 3,    // 日历
    QKECPrivacyType_Reminders             = 4,    // 提醒事项
    QKECPrivacyType_Photos                = 5,    // 照片
    QKECPrivacyType_BluetoothSharing      = 6,    // 蓝牙共享
    QKECPrivacyType_Microphone            = 7,    // 麦克风
    QKECPrivacyType_SpeechRecognition     = 8,    // 语音识别 >= iOS10
    QKECPrivacyType_Camera                = 9,    // 相机
    QKECPrivacyType_Health                = 10,   // 健康 >= iOS8.0
    QKECPrivacyType_HomeKit               = 11,   // 家庭 >= iOS8.0
    QKECPrivacyType_MediaAndAppleMusic    = 12,   // 媒体与Apple Music >= iOS9.3
    QKECPrivacyType_MotionAndFitness      = 13,   // 运动与健身
};

// QKECAuthorizationStatus 权限状态，参考PHAuthorizationStatus等
typedef NS_ENUM(NSUInteger, QKECAuthorizationStatus){
    QKECAuthorizationStatus_NotDetermined  = 0, // 用户从未进行过授权等处理，首次访问相应内容会提示用户进行授权
    QKECAuthorizationStatus_Authorized     = 1, // 已授权
    QKECAuthorizationStatus_Denied         = 2, // 拒绝
    QKECAuthorizationStatus_Restricted     = 3, // 应用没有相关权限，且当前用户无法改变这个权限，比如:家长控制
    QKECAuthorizationStatus_NotSupport     = 4, // 硬件等不支持
};


typedef void(^AccessForTypeResultBlock)(QKECAuthorizationStatus status, QKECPrivacyType type);


@interface SelectMusicController ()

@property(nonatomic,strong)NSMutableArray *dataarray;
@property(nonatomic,strong) IBOutlet UITableView *tablist;
@property(nonatomic) NSInteger selectMusic;
@end

@implementation SelectMusicController
-(void)loadView{
    
    [[[clipPubthings clipBundle]  loadNibNamed:@"SelectMusicController" owner:self options:nil] lastObject];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataarray = [NSMutableArray new];
    self.selectMusic = -1;
    self.tablist.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (@available(iOS 13.0, *)) {
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];

     }else{
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
     }
    WS(weakSelf);
    [SelectMusicController checkAndRequestAccessForAppleMusicWithAccessStatus:^(QKECAuthorizationStatus status, QKECPrivacyType type) {
        if (status != QKECAuthorizationStatus_NotDetermined) {
            if(status == QKECAuthorizationStatus_Authorized){
                dispatch_async(dispatch_get_main_queue(), ^{
                    MPMediaQuery *allMp3 = [[MPMediaQuery alloc] init];
                    // 读取条件
                    MPMediaPropertyPredicate *albumNamePredicate =
                    [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeMusic ] forProperty: MPMediaItemPropertyMediaType];
                    [allMp3 addFilterPredicate:albumNamePredicate];
                    NSArray* allMusicItems = [allMp3 items];
                    for (MPMediaItem *song in allMusicItems) {
                        NSString *songTitle = song.title;
                        NSLog (@"%@, %@, %@", songTitle, song.assetURL,song.artist);

                        if(song.assetURL != nil && [[song.assetURL absoluteString] rangeOfString:@"mp3"].location != NSNotFound){
                           
                            [weakSelf.dataarray addObject:song];

                        }
                    }
                    [weakSelf.tablist reloadData];
                });
            }else{
                NSString *msg = @"";
                switch (status) {
                    case QKECAuthorizationStatus_Denied:
                        msg = @"请开启Apple Music的访问权限";
                        break;
                    case QKECAuthorizationStatus_Restricted:
                        msg = @"应用没有相关权限";
                    break;
                    case QKECAuthorizationStatus_NotSupport:
                        msg = @"设备不支持该功能";
                        break;
                    default:
                        break;
                }
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                [self presentViewController:alert animated:YES completion:nil];

            }
        }
    }];
    

}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataarray == nil) {
        return 0;
    }
    if ([self.dataarray count] == 0) {
        return 1;
    }
    return [self.dataarray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.dataarray count] == 0) {

        
        static NSString *str = @"nothingcell";
        NothingCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if (cell == nil) {
            NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"NothingCell" owner:nil options:nil];
            cell = [array objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.lbl_title.text = @"请给您的手机倒入音乐哟～";
        return cell;
    }
    
    //正常情况的cell
    static NSString *ID = @"cell";
    MusicSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        NSArray *array = [[clipPubthings clipBundle] loadNibNamed:@"MusicSelectCell" owner:nil options:nil];
        cell = [array objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    MPMediaItem *song = [self.dataarray objectAtIndex:indexPath.row];
    NSString *songTitle = song.title;
    cell.lbl_name.text = songTitle;
    if(self.selectMusic == indexPath.row){
        cell.img_logo.image = [clipPubthings imageNamed:@"qk508picFromLibrarySelected"];
    }else{
        cell.img_logo.image = [clipPubthings imageNamed:@"qk508picFromLibrarySelect"];
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataarray count] == 0) {
        return self.tablist.frame.size.height;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataarray count] == 0) {
        return;
    }
    if(self.selectMusic == indexPath.row){
        self.selectMusic = -1;
    }else{
        self.selectMusic = indexPath.row;
    }
    [self.tablist reloadData];
}

-(IBAction)selectMusic:(id)sender{
    if(self.selectMusic == -1){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择一段音乐" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    [clipPubthings showHUD_Login:@"处理中"];
    MPMediaItem *song = [self.dataarray objectAtIndex:self.selectMusic];
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableArray *musics = [NSMutableArray new];
        NSUserDefaults *application = [NSUserDefaults standardUserDefaults];
        NSArray *array = [application objectForKey:@"local_pcmmusic"];
        if(array != nil){
            musics = [NSMutableArray arrayWithArray:array];
        }
        NSString *sessionId = [[NSUUID UUID] UUIDString];
        
        NSString *outPath = [NSString stringWithFormat:@"%@/musicPcm/%@.pcm",clipPubthings.pressfixPath,sessionId];
        NSString *address = [NSString stringWithFormat:@"musicPcm/%@.pcm",sessionId];
        NSString *nowMusicPath = [song.assetURL absoluteString];
        BOOL toPcm = true;
        for(NSDictionary *dic in musics){
            NSString *path = dic[@"address"];
            if(path != nil && [path isEqualToString:address]){
                outPath = [NSString stringWithFormat:@"%@/musicPcm/%@1.pcm",clipPubthings.pressfixPath,sessionId];
                address = [NSString stringWithFormat:@"musicPcm/%@1.pcm",sessionId];
            }
            NSString *musicPath = dic[@"musicPath"];
            if(musicPath != nil && [musicPath isEqualToString:nowMusicPath]){
                toPcm = false;
                address = path;
                break;
            }
        }
        
        if(toPcm){
            NSLog(@"toPcm");
            [QKRecordMP3ToPcm mixAudioWithUrl:song.assetURL toFile:outPath preferedSampleRate:44100];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:address forKey:@"address"];
            [dic setObject:nowMusicPath forKey:@"musicPath"];
            if(song.title != nil){
                [dic setObject:song.title forKey:@"name"];
            }else{
                [dic setObject:@"未知" forKey:@"name"];
            }
            [musics addObject:dic];
            [application setObject:musics forKey:@"local_pcmmusic"];
        }
        QKMusicBean *bean = [[QKMusicBean alloc] init];
        bean.address = address;
        bean.name = song.title;
        NSLog(@"%@ %@",song.title,address);

        dispatch_async(dispatch_get_main_queue(), ^{
            [clipPubthings hideHUD];

            if(weakSelf.playMusic){
                weakSelf.playMusic(bean);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    });
}


#pragma mark -------------------- MediaAndAppleMusic --------------------
#pragma mark -
+ (void)checkAndRequestAccessForAppleMusicWithAccessStatus:(AccessForTypeResultBlock)accessStatusCallBack
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.3f) {
        
        SKCloudServiceAuthorizationStatus status = [SKCloudServiceController authorizationStatus];
        
        if (status == SKCloudServiceAuthorizationStatusNotDetermined) {
//            [self executeCallBack:accessStatusCallBack accessStatus:QKECAuthorizationStatus_NotDetermined type:QKECPrivacyType_MediaAndAppleMusic];
            
            [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
                switch (status) {
                    case SKCloudServiceAuthorizationStatusNotDetermined:
                    {
                        [self executeCallBack:accessStatusCallBack accessStatus:QKECAuthorizationStatus_NotDetermined type:QKECPrivacyType_MediaAndAppleMusic];
                    }
                        break;
                    case SKCloudServiceAuthorizationStatusRestricted:
                    {
                        [self executeCallBack:accessStatusCallBack accessStatus:QKECAuthorizationStatus_Restricted type:QKECPrivacyType_MediaAndAppleMusic];
                    }
                        break;
                    case SKCloudServiceAuthorizationStatusDenied:
                    {
                        [self executeCallBack:accessStatusCallBack accessStatus:QKECAuthorizationStatus_Denied type:QKECPrivacyType_MediaAndAppleMusic];
                    }
                        break;
                    case SKCloudServiceAuthorizationStatusAuthorized:
                    {
                        [self executeCallBack:accessStatusCallBack accessStatus:QKECAuthorizationStatus_Authorized type:QKECPrivacyType_MediaAndAppleMusic];
                    }
                        break;
                    default:
                        break;
                }
            }];
        } else if (status == SKCloudServiceAuthorizationStatusRestricted) {
            [self executeCallBack:accessStatusCallBack accessStatus:QKECAuthorizationStatus_Restricted type:QKECPrivacyType_MediaAndAppleMusic];
            
        } else if (status == SKCloudServiceAuthorizationStatusDenied) {
            [self executeCallBack:accessStatusCallBack accessStatus:QKECAuthorizationStatus_Denied type:QKECPrivacyType_MediaAndAppleMusic];

        } else{
            // SKCloudServiceAuthorizationStatusAuthorized
            [self executeCallBack:accessStatusCallBack accessStatus:QKECAuthorizationStatus_Authorized type:QKECPrivacyType_MediaAndAppleMusic];
        }
    }else{
        [self executeCallBack:accessStatusCallBack accessStatus:QKECAuthorizationStatus_NotSupport type:QKECPrivacyType_MediaAndAppleMusic];
        NSLog(@"AppleMusic只支持iOS9.3+");
    }
}

// all CallBack
+ (void)executeCallBack:(AccessForTypeResultBlock)accessStatusCallBack accessStatus:(QKECAuthorizationStatus)accessStatus type:(QKECPrivacyType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (accessStatusCallBack) {
            accessStatusCallBack(accessStatus, type);
        }
    });
}

@end
