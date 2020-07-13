//
//  ClipPubThings.h
//  QukanTool
//
//  Created by yang on 2019/2/1.
//  Copyright © 2019 yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PGToastView.h"
#import "MBProgressHUD.h"
#import "QukanAlert.h"

#define clipPubthings ((ClipPubThings*)[ClipPubThings sharePubThings])
#define qk_screen_width [[UIScreen mainScreen] bounds].size.width
#define qk_screen_height [[UIScreen mainScreen] bounds].size.height
#define WS(weakSelf) __weak __typeof(&*self) weakSelf = self;
#define pgToast ((PGToastView*)[PGToastView getPgtoast])

NS_ASSUME_NONNULL_BEGIN
@class QKMoviePartDrafts;
@interface ClipPubThings : NSObject

@property (nonatomic) float deleteTop; //iphonex 情况下 deleteTop 24
@property (nonatomic) float deleteBottom; //iphonex 情况下 deleteTop 34
@property float allHeight;//真实屏幕高度
@property float allWidth; //真实屏幕宽度
@property float screen_height;//屏幕高度，ios6已经自动减去了20
@property float screen_width;//屏幕宽度
@property (nonatomic, strong) NSString *pressfixPath;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong)UINavigationController  *nav;



@property (nonatomic, strong) UIColor *color;
/*
视频处理完成的地址
   在QKClipController saveLocalVideo设置为YES的时候回调
*/
@property(copy,nonatomic) void (^completeUrl)(NSString *path);
/*
存草稿
如果要保存草稿,则生成视频后不会删除任何源文件，请慎重
*/
@property(copy,nonatomic) void (^saveDraft)(QKMoviePartDrafts *drafts);;

/*
获取录制视频的地址
*/
@property(copy,nonatomic) void (^recordUrl)(NSString *path);;

@property(strong,nonatomic) UIImage *logo;
@property (nonatomic, strong) NSBundle *bundle;



-(void)initAppkey:(NSString *)appkey nav:(UINavigationController*)nav;
-(UIWindow*)window;
+(ClipPubThings *)sharePubThings;

-(NSString*)getLogoPath;

-(void)showHUD_Login:(NSString *)str;
-(void)showHUD;
-(void)hideHUD;



-(void)startLocalRecord;
-(void)showClipController:(NSArray*)array;
-(void)showVideoOrAudio:(NSString*)str;
-(void)initRecordListen;

-(NSBundle*)clipBundle;

-(UIImage*)imageNamed:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
