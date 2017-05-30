//
//  TPDVideoPlayerController.h
//  FirstSight
//
//  Created by siyi on 2016-11-25.
//  Copyright © 2016 CooTek. All rights reserved.
//

#ifndef TPDVideoPlayerController_h
#define TPDVideoPlayerController_h


//#define DEBUG_FEEDS_VIDEO_TOKEN @"4703947e-dd55-4c33-9afc-415683e4a9f0"

//#define DEBUG_FEEDS_VIDEO

//
// 注意这里的DEBUG_VIDEO_URL 中的 city，必须是没有urlencode的，
//

/*
 测试服务器 视频 token
    17ba0154-ed71-4f2d-af2e-aa2f65674d
    cb836700-5ed6-45a7-ada1-d20a8fc51762
 
 */
#ifdef DEBUG_FEEDS_VIDEO
    #define DEBUG_VIDEO_URL @"http://ws2.cootekservice.com/news/feeds?layout=31&prt=1481595623037&ct=MULTI&rt=JSON&noad=1&ctclass=EMBEDDED&tu=101&token=4703947e-dd55-4c33-9afc-415683e4a9f0&ctn=5&city=上海&ctid=7174206234684168657&ch=cootek.contactplus.ios.public&network=WIFI&nt=WIFI&mode=1&v=5651"

    #define DEBUG_URL_DETAIL_VIDEO_LIST @"http://ws2.cootekservice.com/news/feeds?layout=16&prt=1481595623037&ct=MULTI&rt=JSON&noad=1&ctclass=EMBEDDED&tu=115&token=4703947e-dd55-4c33-9afc-415683e4a9f0&ctn=5&city=上海&ctid=7174206234684168657&ch=cootek.contactplus.ios.public&network=WIFI&nt=WIFI&mode=1&v=5651"
#endif

#define VIDEO_CELL_HEIGHT (111)

#define N_FEEDS_VIDEO_SEND_STATS @"feeds_video_send_stats"
#define N_FEEDS_VIDEO_RESET_STATS @"feeds_video_reset_stats"
#define N_FEEDS_VIDEO_PAUSED_STATS @"feeds_video_paused_stats"

#import <Foundation/Foundation.h>
#import "CootekViewController.h"
#import "VKVideoPlayer.h"
#import "VKVideoPlayerView.h"
#import "TPVideoPlayer.h"
#import "TPVideoPlayerView.h"
#import "FindNewsItem.h"

@interface TPDVideoPlayController : UIViewController <TPVideoPlayerDelegate, UITableViewDelegate, UITableViewDataSource>
- (instancetype) initWithVideoURLString:(NSString *)videoURLString;
- (instancetype) initWithNewItem:(FindNewsItem *)newsItem;

- (void) backButtonPressed;

@property (nonatomic, strong) NSString *videoURLString;
@property (nonatomic, strong) FindNewsItem *newsItem;

@property (nonatomic, strong) TPVideoPlayer *player;
@property (nonatomic, strong) TPVideoPlayerView *playerView;
@property (nonatomic, assign) long previousPausedTime;
@end



#endif /* TPDVideoPlayerController_h */
