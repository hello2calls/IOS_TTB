//
//  FavouriteRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-6-25.
//
//

#ifndef TouchPalDialer_FindRowView_h
#define TouchPalDialer_FindRowView_h

#import "SectionFind.h"

@interface FindRowView : UIView

- (id)initWithFrame:(CGRect)frame andData:(SectionFind*)data andIndexPath:(NSIndexPath*)indexPath;
- (void) resetDataWithFindItem:(SectionFind*)item andIndexPath:(NSIndexPath*)indexPath;

@property (nonatomic, retain) NSMutableArray* findSubViews;
@property (nonatomic, copy) NSIndexPath* rowIndexPath;
@property (nonatomic, retain) SectionFind* findData;
@end

#endif
