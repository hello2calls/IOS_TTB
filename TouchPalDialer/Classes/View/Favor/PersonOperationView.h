//
//  PersonOperationView.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-17.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteDataModel.h"
#import "OperationScrollView.h"
#import "FavoPersonViewProtocol.h"
@interface PersonOperationView : UIView {
	
	FavoriteDataModel *fav_person;
	id<FavoPersonViewProtocoldelegate> __unsafe_unretained person_opera_delegate;
	NSInteger operation_view_y;
}

@property(nonatomic,retain)FavoriteDataModel *fav_person;
@property(nonatomic,assign)NSInteger operation_view_y;
@property(nonatomic,assign)id<FavoPersonViewProtocoldelegate> person_opera_delegate;


- (id)initWithPerson:(FavoriteDataModel *)person Index:(NSInteger)index;
@end
