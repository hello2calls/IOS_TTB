//
//  FavoriteViewController.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-17.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "FavoriteView.h"
#import "FavoPersonViewProtocol.h"
#import "PersonOperationView.h"
#import "FavoriteModel.h"
#import "FavoPersonViewProtocol.h"
#import "TPUIButton.h"
#import "FavoriteNopersonHintView.h"

@interface FavoriteViewController:UIViewController<FavoPersonViewProtocoldelegate>
{
	FavoriteView *fav_view;
	id<FavoPersonViewProtocoldelegate> __unsafe_unretained person_opera_delegate;
    FavoriteModel *fav_model;
    FavoriteNopersonHintView *noFavorHint;
}

@property(nonatomic,retain)FavoriteView *fav_view;
@property(nonatomic,assign)id<FavoPersonViewProtocoldelegate> person_opera_delegate;
@property(nonatomic,retain)FavoriteModel *fav_model;
@property(nonatomic,retain)FavoriteNopersonHintView *noFavorHint;

-(void)reloadFavoriteView;
@end
