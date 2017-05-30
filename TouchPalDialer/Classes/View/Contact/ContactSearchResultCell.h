//
//  ContactSearchResultCell.h
//  TouchPalDialer
//
//  Created by Sendor on 11-8-22.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContractResultModel.h"
#import "CootekTableViewCell.h"
#import "LongGestureController.h"

@interface ContactSearchResultCell : CootekTableViewCell <LongGestureCellDelegate>{

}
@property (nonatomic, retain) ContractResultModel* currentData;
@property (nonatomic, retain) UIView *operViewCon;
@property (nonatomic, retain) UILabel *ifCootekUserView;
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
              withContactData:(ContractResultModel*)contactData;
- (void)updateData:(ContractResultModel*) currentData;
- (void)showAnimation;
- (void)exitAnimation;
@end
