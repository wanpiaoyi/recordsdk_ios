# QKRecordSDK
QKRecordSDK

系统最低要求：ios 9.0及以上系统。  
快速集成：    
1、cocoapods导入sdk + demo。    
        use_frameworks!    
        platform :ios, '9.0'    
        target 'QKRecordSDK_Example' do  
        pod 'QKRecordSDK'  
        end  
  
2、添加权限：  
在Info.plist中添加以下权限。  
Privacy - Camera Usage Description  
Privacy - Bluetooth Peripheral Usage Description  
Privacy - Bluetooth Always Usage Description

Privacy - Microphone Usage Description  
Privacy - Photo Library Additions Usage Description  
Privacy - Photo Library Usage Description  
  
3、初始化sdk  
导入头文件ClipPubThings.h.  
appkey:请问销售人员获取。  
[clipPubthings initAppkey:appkey nav:self.navigationController];  
  
4、启动录像功能。  
导入头文件ClipPubThings.h.  
[clipPubThings startLocalRecord];  

5、开启短视频编辑功能。  
导入头文件ClipPubThings.h.  
[clipPubthings showClipController:array];


6、配置直播参数。  
导入头文件ClipPubThings.h.  
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


不集成demo，直接集成SDK的方案。  
1、导入趣看基础库。  
use_frameworks!  
platform :ios, '9.0'  
target 'QKLiveSDK_Example' do  
pod 'QKPubBean'  
end  
  
2、根据《IOS录制短视频SDK文档》开发对应功能。  

