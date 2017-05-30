//
//  RecommendRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//
@class SectionRecommend;
@class ActivityItem;
@interface RecommendRowView : UIView

- (id)initWithFrame:(CGRect)frame andData:(SectionRecommend *)dataArray andIndex:(NSIndexPath*)path;
- (void) resetDataWithRecommendItem:(SectionRecommend*)item andIndexPath:(NSIndexPath*)indexPath;
@property (nonatomic, retain) NSMutableArray* cellViews;
@property (nonatomic, retain) SectionRecommend* sectionRecommend;
@property (nonatomic, retain) NSIndexPath* indexPath;
@property (nonatomic, retain) ActivityItem* activity;

@end