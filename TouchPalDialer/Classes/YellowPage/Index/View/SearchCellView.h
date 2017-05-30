//
//  SearchView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//

#ifndef TouchPalDialer_SearchView_h
#define TouchPalDialer_SearchView_h

@class SectionSearch;
@interface SearchCellView : UISearchBar<UISearchBarDelegate>
 
@property(nonatomic, retain) SectionSearch* item;

- (id) initWithFrame:(CGRect)frame andData:(SectionSearch*)data;
- (void) drawView;
@end
#endif

