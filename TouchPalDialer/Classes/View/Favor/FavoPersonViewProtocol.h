//
//  FavoPersonViewProtocol.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-17.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FavoPersonViewProtocoldelegate

@optional
- (void)showOperationView:(UIView *)op_view;
- (void)setCurrentPage:(NSInteger)current;
- (void)showAllContactList;
@required
- (void)closeOperationView:(UIView *)op_view;
@end
