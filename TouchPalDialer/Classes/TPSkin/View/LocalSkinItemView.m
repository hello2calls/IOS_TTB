//
//  LocalSkinItemView.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-15.
//
//

#import "LocalSkinItemView.h"
#import "TPDialerResourceManager.h"
#import "RemoteSkinItemView.h"
#import "FunctionUtility.h"

@interface LocalSkinItemView ()

@property (nonatomic, retain) UIImageView *checkedView;
@property (nonatomic, retain) UIButton *deleteButton;
@property (nonatomic, retain) UIImageView *iconImageView;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, retain) UIView *soundView;
@end

@implementation LocalSkinItemView
@synthesize skinInfo = skinInfo_;

- (id)initWithSkinInfo:(TPSkinInfo *)skinInfo
{
    self = [super initWithFrame:CGRectMake(0, 0, 10.0f, 10.0f)];
    if (self) {
        _inEditing = NO;
        skinInfo_ = skinInfo;
        
        CGFloat itemMarginTop = 10.0f;
        CGFloat itemPadding = 10.0f;
        
        // button size
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat buttonMarginTop = 10.0f;
        CGSize buttonSize = CGSizeMake([self getMaxWidthForDownloadButton], 28.0f);
        
        // insert the content container
        UIImage *iconImage = skinInfo.skinIcon;
        
        // item container, contains the icon image, the skin name and the button
        CGFloat itemContainerWidth = TPScreenWidth() - 2 * itemPadding;
        CGFloat iconImageHeight = (iconImage.size.height / iconImage.size.width) * itemContainerWidth;
        CGFloat itemContainerHeight = iconImageHeight + buttonMarginTop * 2 + buttonSize.height;
        CGSize itemContainerSize = CGSizeMake(itemContainerWidth, itemContainerHeight);
        self.backgroundColor = [UIColor whiteColor];
        UIView *itemContainer = [[UIView alloc] initWithFrame:CGRectMake(itemPadding, itemPadding, itemContainerSize.width, itemContainerSize.height)];
//        itemContainer.bounds = CGRectMake(0, 0, itemContainer.bounds.size.width, itemContainer.bounds.size.height);
        
        // icon image
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemContainerSize.width, iconImageHeight)];
        self.iconImageView.image = skinInfo.skinIcon;
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.iconImageView.clipsToBounds = YES;
        
        // a top-drifting button on the icon image to reponse to the click event
        UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, itemContainerSize.width, iconImageHeight)];
        [imageButton addTarget:self action:@selector(onIconClicked) forControlEvents: UIControlEventTouchUpInside];
        
        // button
        UIButton *button_ = self.deleteButton;
        button_.frame = CGRectMake(itemContainerSize.width - buttonSize.width, self.iconImageView.bounds.size.height + buttonMarginTop, buttonSize.width, buttonSize.height);
        button_.layer.cornerRadius = 4;
        button_.titleLabel.font = [UIFont systemFontOfSize:15];
        
        if ([skinInfo.skinID isEqualToString:[TPDialerResourceManager sharedManager].skinTheme]) {
            [self setButtonStatus:SkinItemStatusUsed isEditing:NO];
        } else {
            [self setButtonStatus:SkinItemStatusDownloaded isEditing:NO];
        }
        button_.layer.cornerRadius = 4;
        button_.clipsToBounds = YES;
        
        // skin name text
        UIFont *skinNameFont = [UIFont systemFontOfSize:17.0f];
        NSString *skinName = skinInfo.name;
        CGSize skinNameSize = [skinName sizeWithFont:skinNameFont];
        CGFloat skinNameMarginTop = (itemContainerHeight - iconImageHeight - skinNameSize.height) / 2;
        self.textLabel = [[UILabel alloc]
                          initWithFrame:CGRectMake(0, skinNameMarginTop + iconImageHeight, skinNameSize.width, skinNameSize.height)];
        self.textLabel.backgroundColor = [UIColor clearColor];
        [self.textLabel setText:skinName];
        [self.textLabel setTextColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"]];
        [self.textLabel setFont:skinNameFont];
        
        
        CGFloat hornMargin = 5.0f;
        CGSize hornSize = CGSizeMake(30.0f, 30.0f);
        _horn= [[UILabel alloc] initWithFrame:CGRectMake(
                                                         itemContainerSize.width - hornMargin - hornSize.width, iconImageHeight - hornMargin - hornSize.height,
                                                         hornSize.width, hornSize.height)];
        _horn.clipsToBounds = YES;
        _horn.layer.cornerRadius = hornSize.width / 2;
        _horn.backgroundColor = [TPDialerResourceManager getColorForStyle:@"skin_horn_bg_color"];
        _horn.font = [UIFont fontWithName:@"iPhoneIcon3" size:20.0f];
        _horn.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        _horn.textAlignment = NSTextAlignmentCenter;
        _horn.text = @"4";
        _horn.hidden = YES;
        
        // item container adds subviews
        self.iconImageView.hidden = NO;
        // for the icon image, put a button ontop of it to response to user's click
        self.iconImageView.userInteractionEnabled = YES;
        [self.iconImageView addSubview:imageButton];
        
        // setting up the view tree
        [itemContainer addSubview:self.iconImageView];
        [itemContainer addSubview:button_];
        [itemContainer addSubview:self.textLabel];
    
        // adjust the item's width and height
        self.frame = CGRectMake(0, 0, TPScreenWidth(), itemContainerHeight + itemMarginTop);
        [self addSubview:itemContainer];
        [self addSubview:_horn];
    }
    
    return self;
}

- (void) setButtonStatus: (RemoteSkinItemButtonStatus)status isEditing: (BOOL)isEditing {
    UIButton *button_ = self.deleteButton;
    self.buttonStatus = status;
    self.inEditing = isEditing;
    if (!isEditing) {
        //  in normal editing
        [button_ addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        switch (status) {
            case SkinItemStatusDownloaded:
                [button_ setTitle:NSLocalizedString(@"Use", @"") forState:UIControlStateNormal];
                [button_ setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_blue_500"] forState:UIControlStateNormal];
                button_.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_blue_500"].CGColor;
                button_.layer.borderWidth = 1.0f;
                
                [button_ setBackgroundImage:[FunctionUtility imageWithColor:[UIColor clearColor] withFrame:button_.bounds] forState:UIControlStateNormal];
                [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_blue_500"] withFrame:button_.bounds]
                                   forState:UIControlStateHighlighted];
                [button_ setBackgroundImage:[FunctionUtility imageWithColor:[UIColor whiteColor]
                                                                  withFrame:button_.bounds] forState:UIControlStateNormal];
                //
                break;
            case SkinItemStatusUsed:
                [button_ setTitle:NSLocalizedString(@"In use", @"") forState:UIControlStateNormal];
                [button_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_blue_500"] withFrame:button_.bounds]
                                   forState:UIControlStateNormal];
                [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_blue_700"] withFrame:button_.bounds]
                                   forState:UIControlStateHighlighted];
                button_.layer.borderColor = [UIColor clearColor].CGColor;
                //
                break;
            default:
                break;
        }
        
    } else {
        // in editing mode
        [button_ addTarget:self action:@selector(deleteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [button_ setTitle:NSLocalizedString(@"delete_skin", @"") forState:UIControlStateNormal];
        [button_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_red_400"] withFrame:button_.bounds]
                           forState:UIControlStateNormal];
        [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_red_600"] withFrame:button_.bounds]
                           forState:UIControlStateHighlighted];
        button_.layer.borderColor = [UIColor clearColor].CGColor;
    }
    

}

- (void)viewTapped
{
    if (self.delegate) {
        [self.delegate localSkinItemViewDidClick:self];
    }
}

- (void)deleteButtonClicked
{
    if (self.delegate) {
        [self.delegate localSkinItemViewDeleteButtonDidClick:self];
    }
}

- (BOOL)showsCheckedView
{
    return !self.checkedView.hidden;
}

- (void)setShowsCheckedView:(BOOL)showsCheckedView
{
    //self.checkedView.hidden = !showsCheckedView;
}

- (BOOL)showsDeleteButton
{
    return self.deleteButton.hidden;
}

- (void)setShowsDeleteButton:(BOOL)showsDeleteButton
{
    //self.showsDeleteButton = showsDeleteButton;
    self.deleteButton.hidden = !showsDeleteButton;
    [self setButtonStatus:self.buttonStatus isEditing:YES];
}

- (void) buttonClicked {
    
    if (self.delegate) {
        [self.delegate localSkinItemViewDidClick:self];
    }
}

- (void) onIconClicked {
    if (self.delegate) {
        cootek_log(@"LocalSkinItemView, onIconClicked");
        [self.delegate localSkinItemIconDidClick:self];
    }
}

- (float) getMaxWidthForDownloadButton {
    UIFont *__statusTextFont = [UIFont systemFontOfSize:15];
    NSMutableArray *sizes = [[NSMutableArray alloc] initWithCapacity:4];
    [sizes addObject:@([NSLocalizedString(@"delete_skin", nil) sizeWithFont:__statusTextFont].width)];
    [sizes addObject:@([NSLocalizedString(@"Use", nil) sizeWithFont:__statusTextFont].width)];
    [sizes addObject:@([NSLocalizedString(@"In Use", nil) sizeWithFont:__statusTextFont].width)];
    [sizes sortUsingComparator:^(id obj1, id obj2){
        if (obj1 == nil || obj2 == nil) return NSOrderedSame;
        if (![obj1 isKindOfClass:[NSNumber class]] || ![obj2 isKindOfClass:[NSNumber class]]) {
            return NSOrderedSame;
        }
        NSNumber *num1 = (NSNumber *) obj1;
        NSNumber *num2 = (NSNumber *) obj2;
        if ([num1 floatValue] > [num2 floatValue]) {
            return NSOrderedDescending;
        } else if ([num1 floatValue] < [num2 floatValue]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    float maxSize = [[sizes lastObject] floatValue];
    return maxSize > 56 ? (maxSize + 10) : 56;
}

@end
