//
//  NewsFeedsCellTableViewCell.h
//  TouchPalDialer
//
//  Created by lin tang on 16/11/24.
//
//

#import <UIKit/UIKit.h>
#import "FindNewsItem.h"
#import "UITableViewCell+TPDExtension.h"

typedef NS_ENUM(NSInteger, FeedsLayoutType) {
    LeftImageLayoutType  = 0,
    ThreeImageLayoutType,
    BigImageLayoutType,
    NoImageLayoutType,
    BaiduLeftImageLayoutType,
    BaiduThreeImageLayoutType,
    BaiduBigImageLayoutType,
    UpdateRecLayoutType,
    VideoLayoutType
} ;

@interface NewsFeedsCellTableViewCell : UITableViewCell

@property (nonatomic,weak) FindNewsItem* item;
@property(nonatomic, strong) UIView* borderView;
@property(nonatomic, strong) UILabel* highlightView;
@property (nonatomic, strong) UILabel *videoTimeLabel;
@property (nonatomic, strong) UIImageView *videoPlayImageView;

+ (NSString *) identifierFromItem:(FindNewsItem*) item;
+ (void) registerCellForUITableView:(UITableView*) table;
- (void) setFindnewsItem:(FindNewsItem*) newsItem withIndexPath:(NSIndexPath*) path;
- (NewsFeedsCellTableViewCell *) createCellViewsFromItem:(FindNewsItem *)item;
@end


