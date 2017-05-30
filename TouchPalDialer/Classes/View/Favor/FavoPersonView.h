//
//  FavoPersonView.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-16.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoriteDataModel.h"
#import "PersonOperationView.h"
#import "FavoPersonViewProtocol.h"

@interface FavoPersonView : UIView<FavoPersonViewProtocoldelegate> {
    //PersonOperationView *operation_view;
	BOOL isEnableTouch;
	FavoriteDataModel *person_fav;
	NSInteger index;//九方格中第几个
	id<FavoPersonViewProtocoldelegate> __unsafe_unretained person_opera_delegate;
    NSInteger item_current_page;

}
@property(nonatomic,retain) FavoriteDataModel *person_fav;
@property(nonatomic,assign)	BOOL isEnableTouch;
@property(nonatomic,assign) NSInteger index;
@property(nonatomic,assign)	id<FavoPersonViewProtocoldelegate> person_opera_delegate;
@property(nonatomic,assign)	 NSInteger item_current_page;;

-(id)initWithFavoPerson:(FavoriteDataModel *)person WithFrame:(CGRect)frame_person Index:(NSInteger)index_temp withPage:(NSInteger)page;
@end
