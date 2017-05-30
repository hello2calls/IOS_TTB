//
//  SearchRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//
#import "SearchCellView.h"
#import "CitySelectView.h"
#import "SectionSearch.h"

@interface SearchRowView : UIView

@property(nonatomic, retain) SearchCellView *searhView;
@property(nonatomic, retain) CitySelectView *citySelectView;
@property(nonatomic, retain) NSString* selectedCity;

- (id)initWithFrame:(CGRect)frame andData:(SectionSearch *)data;
- (void) resetDataWithSearchItem:(SectionSearch*)item;

@end
