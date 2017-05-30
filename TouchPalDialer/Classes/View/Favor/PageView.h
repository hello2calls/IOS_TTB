//
//  PageView.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-16.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoPersonViewProtocol.h"

@interface PageView : UIView<FavoPersonViewProtocoldelegate> {
	NSInteger page_number;
	NSArray *fav_list_one;
	id<FavoPersonViewProtocoldelegate> __unsafe_unretained person_opera_delegate;
}
@property(nonatomic,retain) NSArray *fav_list_one;
@property(nonatomic,assign) NSInteger page_number;
@property(nonatomic,assign)id<FavoPersonViewProtocoldelegate> person_opera_delegate;
-(id)initWithPageNumber:(NSInteger)number FavoritesList:(NSArray *)list_fav Frame:(CGRect)frame;
@end
