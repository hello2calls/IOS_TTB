//
//  ContactItemCell.m
//  TouchPalDialer
//
//  Created by Sendor on 11-8-22.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "ContactItemCell.h"
#import "HighLightLabel.h"
#import "Person.h"
#import "FunctionUtility.h"
#import "PhoneNumber.h"
#import "ContactCacheDataManager.h"
#import "CootekNotifications.h"
#import "NumberPersonMappingModel.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "ImageCacheModel.h"
#import "PersonDBA.h"
#import "TouchpalMembersManager.h"
#import "UserDefaultsManager.h"
#import "AllViewController.h"


@interface ContactItemCell(){
}
- (NSString *)timeString;
@end
@implementation ContactItemCell

@synthesize checked_image;
@synthesize unchecked_image;
@synthesize delegate;
@synthesize person_data;
@synthesize is_checked;
@synthesize bottomLine;
@synthesize partBottomLine;
@synthesize partBLine;

// partBLine cell bottom line

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           personId:(int)personId
    isRequiredCheck:(BOOL)isGroupCell
       withDelegate:(id<ContactItemCellProtocol>)cellDelegate
               size:(CGSize)size {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userContentView.frame = CGRectMake(0, 0, size.width, size.height);
        person_data = nil;
        
        if (isGroupCell) {
            self.faceSticker.hidden = YES;
            check_image_view = [[UIImageView alloc] init];
            check_image_view.frame = CGRectMake(CONTACT_CELL_LEFT_GAP, (TPScreenWidth() - CONTACT_CELL_PHOTO_DIAMETER) / 2, CONTACT_CELL_PHOTO_DIAMETER, CONTACT_CELL_PHOTO_DIAMETER);
            [self.userContentView addSubview:check_image_view];
            [self.userContentView bringSubviewToFront:check_image_view];
            
        }else{
            self.faceSticker.hidden = NO;
        }
        
        // adjust heights of nameLabel and numberLabel
        [self adjustHeightOfLabel:self.nameLabel];
        self.numberLabel.hidden = YES;
        
        // UILabel: bottom line
        UIColor *lineColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
        
        CGFloat lineHeight = 0.5;
        partBLine = [[UILabel alloc]initWithFrame:CGRectMake(
                                CONTACT_CELL_MARGIN_LEFT, CONTACT_CELL_HEIGHT - lineHeight,
                                self.userContentView.frame.size.width - CONTACT_CELL_MARGIN_LEFT, lineHeight)];
        partBLine.backgroundColor = lineColor;
        
        self.operView.frame = CGRectMake(0, CONTACT_CELL_HEIGHT, self.userContentView.frame.size.width, CONTACT_CELL_HEIGHT);
        CGAffineTransform trans = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.01);
        self.operView.transform = trans;
        
        // view settings
        NSArray *views = @[self.ifCootekUserView, self.faceSticker, self.markSticker];
        [FunctionUtility verticallyCenterViewArray:views inParentHeight:CONTACT_CELL_HEIGHT];
        
        // view tree
        [self addSubview:partBLine];
        
        // view layout
        [self adjustNameAndNumberLabel];
        
        self.delegate = cellDelegate;
    }
    return self;
}

- (void)showPartBLine {
    partBLine.hidden = NO;
}

- (void)hidePartBLine {
    partBLine.hidden = YES;
}

- (void)setMemberCellDataWithCacheItemData:(ContactCacheDataModel*)cachePersonData displayType:(CellDisplayType)displayType{
    self.currentData = (id)cachePersonData;
    [self setMemberCellData:cachePersonData displayType:displayType];
}

- (void)setMemberCellData:(ContactCacheDataModel*)personData displayType:(CellDisplayType)displayType{
	// image
    self.person_data = personData;
    self.faceSticker.personID = personData.personID;
    NSString *name = @"";
    NSString *number = @"";
    UIImage* faceImage = nil;
    
    // name
    if ([FunctionUtility isNilOrEmptyString:personData.displayName]) {
        name = NSLocalizedString(@"(No name)", @"(No name)");
    }else {
        name = personData.displayName;
    }
    // signature or note or lastModifiedDate

     switch (displayType) {
          case DisplayTypeNote:{
              // smart grouping: note group
              // two lines
              self.numberLabel.hidden = NO;
              [self adjustNameAndNumberLabel];
              number = [personData note];
              break;
          }
          case DisplayTypeLastModifiedTime:{
              // smart grouping: recently added
              // two lines
              self.numberLabel.hidden = NO;
              [self adjustNameAndNumberLabel];
              number = [self timeString];
              break;
          }
          default:{
              // smart grouping: others
              // one lines
              self.numberLabel.hidden = YES;
              [self adjustNameAndNumberLabel];
          }
        break;
     }
    
    BOOL isRegistered = [TouchpalMembersManager isRegisteredByContactCachedModel:personData];
    BOOL ifFamily = [FunctionUtility CheckIfExistInBindSuccessListarrayWithPhoneArray:personData.phones];
    
    if (ifFamily) {
        self.ifCootekUserView.hidden = NO;
        self.ifCootekUserView.font = [UIFont fontWithName:@"iPhoneIcon1" size:18];
        self.ifCootekUserView.text = @"s";
        self.ifCootekUserView.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"0xfc5c8d"];
    } else {
        if (isRegistered) {
            self.ifCootekUserView.hidden = NO;
            CGRect oldFrame = self.nameLabel.frame;
            NSString *userLabelString = NSLocalizedString(@"voip_cootek_user_label", "");
            UIFont *userLabelFont = [UIFont fontWithName:@"iPhoneIcon3" size:18];
            self.ifCootekUserView.textColor = [TPDialerResourceManager getColorForStyle:@"voip_cootekUser_label_color"];
            self.ifCootekUserView.font = userLabelFont;
            self.ifCootekUserView.text = userLabelString;
            self.nameLabel.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, TPScreenWidth() - 90 - oldFrame.origin.x, oldFrame.size.height);
            oldFrame = self.numberLabel.frame;
            self.numberLabel.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, TPScreenWidth() - 90 - oldFrame.origin.x, oldFrame.size.height);
            
        } else {
            self.ifCootekUserView.hidden = YES;
            [self resetFrame];
        }
    }
    
    if (!self.faceSticker.hidden) {
        faceImage = [personData image];
        if (!faceImage) {
            faceImage = [PersonDBA getDefaultImageByPersonID:personData.personID
                                                isCootekUser:!self.ifCootekUserView.hidden];
        }
    }
    [self refreshCellView:faceImage withNumber:number withNumberHitRange:NSMakeRange(0, 0)  withName:name withNameHitArray:nil];
}

- (void)resetFrame{
    CGRect oldFrame = self.nameLabel.frame;
    self.nameLabel.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, TPScreenWidth() - 30 - oldFrame.origin.x, oldFrame.size.height);
    oldFrame = self.numberLabel.frame;
    self.numberLabel.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, TPScreenWidth() - 30 - oldFrame.origin.x, oldFrame.size.height);
}



- (NSString *)timeString{
    //time comparsion
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:-1]; // note that I'm setting it to -1
    NSDate *oneYearBefore = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    NSString *theDateString = [person_data createDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *theDate = [dateFormatter dateFromString:theDateString];
    
    if([theDate compare:oneYearBefore]<0){
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }else{
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    }
    NSString *number = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Creation date", @""), [dateFormatter stringFromDate:theDate]];
    return number;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)updateCheckStatus:(BOOL)isChecked {
    is_checked = isChecked;
    if (is_checked) {
        check_image_view.image = checked_image;
    } else {
        check_image_view.image = unchecked_image;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    if (!CGRectContainsPoint(check_image_view.frame, location)) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    if (CGRectContainsPoint(check_image_view.frame, location)) {
        person_data.isChecked = !self.person_data.isChecked;
        [self updateCheckStatus:person_data.isChecked];
        [delegate clickCheckStatus:self];
        if (person_data.isChecked){
            NSLog(@"%@       checked to YES",person_data.displayName);
        } else {
            NSLog(@"%@       checked to NO",person_data.displayName);
        }
    } else {
        person_data.isChecked = !self.person_data.isChecked;
        [self updateCheckStatus:person_data.isChecked];
        [self clickCell];
        if (person_data.isChecked){
            NSLog(@"%@       checked to YES",person_data.displayName);
        } else {
            NSLog(@"%@       checked to NO",person_data.displayName);
        }
        [super touchesEnded:touches withEvent:event];
    }
}

-(void) clickCell {
    [delegate clickCell:self];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    self.textNameColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"titleLabel_textColor"]];
    self.nameLabel.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"titleLabel_backgroundColor"]];
    self.textNumberColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"subtitleLabel_textColor"]];
    self.numberLabel.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"subtitleLabel_backgroundColor"]];

    self.checked_image = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"checkedImage"]];
    self.unchecked_image = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"uncheckedImage"]];
    check_image_view.image = unchecked_image;
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return  toTop;
}

- (void)drawRect:(CGRect)rect {
    
}

@end
