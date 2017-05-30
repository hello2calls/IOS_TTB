//
//  FavorViewController.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteViewController.h"
#import "SelectViewController.h"
#import "FavoPersonViewProtocol.h"


@interface FavorViewController : UIViewController<FavoPersonViewProtocoldelegate, SelectViewProtocalDelegate> {
	FavoriteViewController *fav_controller;
	PersonOperationView *oper_view;	

}
@property(nonatomic,retain) FavoriteViewController *fav_controller;
@property(nonatomic,retain) PersonOperationView *oper_view;

@end
