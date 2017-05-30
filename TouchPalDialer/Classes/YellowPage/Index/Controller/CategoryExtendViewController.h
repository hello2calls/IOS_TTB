//
//  CategoryExtendViewController.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-3.
//
//

#ifndef TouchPalDialer_CategoryExtendViewController_h
#define TouchPalDialer_CategoryExtendViewController_h
#import "TPHeaderButton.h"
#import "CootekViewController.h"
#import "NewCategoryItem.h"

@interface CategoryExtendViewController : CootekViewController<UIScrollViewDelegate>

@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) CategoryItem* item;

@end

#endif
