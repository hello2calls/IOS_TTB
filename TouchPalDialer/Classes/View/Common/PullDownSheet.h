//
//  PullDownSheet.h
//  TouchPalDialer
//
//  Created by Simeng on 14-7-3.
//
//

#import <UIKit/UIKit.h>
#import "TPUIButton.h"

@protocol PullDownSheetDelegate<NSObject>
- (void)doClickOnPullDownSheet:(int)index;
- (void)removePullDownSheet;
@end

@interface PullDownSheet : UIView{
}

@property (nonatomic,retain) NSArray *contentArray;
@property (nonatomic,retain) UIView *shadowView;
@property (nonatomic,assign) float btnAreaHeight;
@property (nonatomic,assign) int btnCount;
@property (nonatomic,assign) id<PullDownSheetDelegate> delegate;
- (id)initWithContent:(NSArray *)contents;
- (void)addContentTitle:(NSString *)title ifNeedToast:(BOOL)needToast andKey:(NSString *)key;
- (void)clearAllBtns;
@end
