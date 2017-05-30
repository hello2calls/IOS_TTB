//
//  ContactItemCell.h
//  TouchPalDialer
//
//  Created by Sendor on 11-8-22.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "ContactCacheDataModel.h"
#import "BaseContactCell.h"
#import "UIView+WithSkin.h"


#define CONTACT_CELL_HEIGHT (66)
#define CONTACT_CELL_MARGIN_LEFT (66)
#define CONTACT_CELL_PHOTO_DIAMETER (36)
#define CONTACT_CELL_PHOTO_MARGIN_RIGHT (10)

typedef enum{
    DisplayTypeDefault,
    DisplayTypeNote,
    DisplayTypeLastModifiedTime
} CellDisplayType;


@protocol ContactItemCellProtocol

- (void)clickCell:(UITableViewCell*)cell;
@optional
- (void)clickCheckStatus:(UITableViewCell*)cell;
- (void)clickSelectALl:(BOOL)is_select;
@end

@interface ContactItemCell : BaseContactCell {
    id<ContactItemCellProtocol> __unsafe_unretained delegate;
    BOOL is_checked;
    UIImageView* check_image_view;
    ContactCacheDataModel* person_data;
}

@property(nonatomic, assign) id<ContactItemCellProtocol> delegate;
@property(nonatomic, retain) ContactCacheDataModel* person_data;
@property(nonatomic, retain) UIImage* checked_image;
@property(nonatomic, retain) UIImage* unchecked_image;
@property(nonatomic, assign) BOOL is_checked;
@property(nonatomic, retain) UILabel *partBLine;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
           personId:(int)personId
    isRequiredCheck:(BOOL)isRequiredCheck
       withDelegate:(id<ContactItemCellProtocol>)cellDelegate
               size:(CGSize)size;
- (void)setMemberCellDataWithCacheItemData:(ContactCacheDataModel*)cachePersonData displayType:(CellDisplayType)displayType;
- (void)setMemberCellData:(ContactCacheDataModel *)personData displayType:(CellDisplayType)displayType;
- (void)updateCheckStatus:(BOOL)isChecked;
- (void)showPartBLine;
- (void)hidePartBLine;
@end
