//
//  FavScrollView.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-16.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoPersonViewProtocol.h"
#import "TPPageController.h"


@interface FavScrollView : UIView<UIScrollViewDelegate, FavoPersonViewProtocoldelegate>{
	NSArray *fav_list;
	TPPageController *pageController;
	UIScrollView *scrollView;
	id<FavoPersonViewProtocoldelegate> __unsafe_unretained person_opera_delegate;
	
	NSInteger page_number;
    NSInteger current_page;
}

@property(nonatomic,retain)	NSArray  *fav_list;
@property(nonatomic,retain) TPPageController *pageController;
@property(nonatomic,retain) UIScrollView *scrollView;

@property(nonatomic,assign) NSInteger current_page;
@property(nonatomic,assign)	NSInteger page_number;
@property(nonatomic,assign)	id<FavoPersonViewProtocoldelegate> person_opera_delegate;

- (id)initWithFrame:(CGRect)frame WithFavList:(NSArray *)list_person; 
- (void)loadScrollViewWithPage:(int)page;
- (NSArray *)getFavData:(NSInteger)page;
@end
