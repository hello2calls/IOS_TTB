//
//  GroupSelector.h
//  TouchPalDialer
//
//  Created by zhang Owen on 12/5/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupSelectorDelegate
- (void)groupChanged;
@end

@interface GroupSelector : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray *groupBelongArr;
    int  personId;
}

@property(nonatomic, retain) NSArray *groupBelongArr;
@property(nonatomic, retain) id<GroupSelectorDelegate> delegate;
@property(nonatomic, assign) int personId;

@end
