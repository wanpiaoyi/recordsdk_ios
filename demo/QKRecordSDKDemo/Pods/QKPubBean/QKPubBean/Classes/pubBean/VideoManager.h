
#import <UIKit/UIKit.h>
#define videoManager ((VideoManager*)[VideoManager sharePubThings])

@interface VideoManager : NSObject


//是否显示直播录像
@property BOOL liveVideoShow;

//是否显示录制录像
@property BOOL recordVideoShow;

//是否显示剪辑录像
@property BOOL clipVideoShow;
+(VideoManager *)sharePubThings;


@end
