//
//  FavoriteView.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-16.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoPersonViewProtocol.h"
#import "FavScrollView.h"

@interface FavoriteView : UIView<FavoPersonViewProtocoldelegate> {
	id<FavoPersonViewProtocoldelegate> __unsafe_unretained person_opera_delegate;
	NSArray *fav_list;
	//FavScrollView *fav_scroll_view;
}
@property(nonatomic,assign)id<FavoPersonViewProtocoldelegate> person_opera_delegate;
@property(nonatomic,retain)NSArray *fav_list;

- (id)initWithFrame:(CGRect)frame WithFavList:(NSArray *)list_person; 
@end
