//
//  TaskAnimationManager.h
//  TouchPalDialer
//
//  Created by tanglin on 16/7/15.
//
//

#import <Foundation/Foundation.h>
#import "SectionMyTask.h"

#define FLG_REQ_INDEX_ACTIVITY 1
#define FLG_REQ_INDEX_JSON 2
#define FLG_REQ_INDEX_FONT  4
#define FLG_REQ_FIND_NEWS   8
#define FLG_REQ_ALL 15

@interface TaskAnimationManager : NSObject

@property(strong, setter=setTaskSection:, getter=taskSection)SectionMyTask* setcionTask;
@property(strong, setter=setIndexPath:, getter=indexPath)NSIndexPath* indexPath;

// 1:index_activity, 2:minibanner, 4:index_font, 8:find_news;
@property(assign) NSInteger requestFlg;

+ (TaskAnimationManager *)instance;

@end
