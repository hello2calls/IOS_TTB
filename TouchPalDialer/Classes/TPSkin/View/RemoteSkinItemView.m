//
//  RemoteSkinItemView.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-16.
//
//

#import "RemoteSkinItemView.h"
#import "TPDialerResourceManager.h"
#import "TPUIButton.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"

@interface RemoteSkinItemView () {
    UIButton *button_;
    UIView *progressView_;
    CGSize _buttonSize;
    UILabel *_horn;
}

@property (nonatomic, retain) UIImageView *iconImageView;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UIButton *soundButton;


@end

@implementation RemoteSkinItemView
@synthesize skinInfo = skinInfo_;
@synthesize buttonStatus = buttonStatus_;
@synthesize downloadProgress = downloadProgress_;

- (id)initWithSkinInfo:(TPSkinInfo *)skinInfo
{
    self = [super initWithFrame:CGRectMake(0, 0, REMOTE_SKIN_ITEM_VIEW_WIDTH, REMOTE_SKIN_ITEM_VIEW_HEIGHT)];
    if (self) {
        skinInfo_ = skinInfo;
        
        CGFloat itemMarginTop = 10.0f;
        CGFloat itemPadding = 10.0f;
        

        // button size
        button_ = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat buttonMarginTop = 10.0f;
        CGSize buttonSize = CGSizeMake([self getMaxWidthForDownloadButton], 28.0f);
        _buttonSize = buttonSize;
        
        // insert the content container
        UIImage *iconImage = skinInfo.skinIcon;
        
        // item container, contains the icon image, the skin name and the button
        CGFloat itemContainerWidth = TPScreenWidth() - 2 * itemPadding;
        CGFloat iconImageHeight = (iconImage.size.height / iconImage.size.width) * itemContainerWidth;
        CGFloat itemContainerHeight = iconImageHeight + buttonMarginTop * 2 + buttonSize.height;
        CGSize itemContainerSize = CGSizeMake(itemContainerWidth, itemContainerHeight);
        self.backgroundColor = [UIColor whiteColor];
        UIView *itemContainer = [[UIView alloc] initWithFrame:CGRectMake(itemPadding, itemPadding,
                                itemContainerSize.width, itemContainerSize.height)];
        itemContainer.bounds = CGRectMake(0, 0, itemContainer.bounds.size.width, itemContainer.bounds.size.height);
        
        // icon image
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemContainerSize.width, iconImageHeight)];
        self.iconImageView.image = skinInfo.skinIcon;
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.iconImageView.clipsToBounds = YES;
        
        // a top-drifting button on the icon image to reponse to the click event
        UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, itemContainerSize.width, iconImageHeight)];
        [imageButton addTarget:self action:@selector(onIconClicked) forControlEvents: UIControlEventTouchUpInside];
        
        // button
        button_.frame = CGRectMake(itemContainerSize.width - buttonSize.width, self.iconImageView.bounds.size.height + buttonMarginTop, buttonSize.width, buttonSize.height);
        button_.titleLabel.font = [UIFont systemFontOfSize:15];
        [button_ addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self setButtonStatus:SkinItemStatusNotDownloaded];
        button_.layer.cornerRadius = 4.0f;
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
        
        //progressView
        UIButton *topButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,
                                buttonSize.width, buttonSize.height)];
        [topButton setTitle:NSLocalizedString(@"downloading", @"") forState:UIControlStateNormal];
        topButton.titleLabel.font = [UIFont systemFontOfSize:15];
        topButton.titleLabel.textColor = [UIColor whiteColor];
        [topButton setBackgroundColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"]];
        
        progressView_ = [[UIView alloc] initWithFrame: CGRectMake(
            itemContainerSize.width - buttonSize.width, self.iconImageView.bounds.size.height + buttonMarginTop,
            0, buttonSize.height)];
        progressView_.layer.cornerRadius = 4.0f;
        progressView_.clipsToBounds = YES;
        progressView_.hidden = YES;
        [progressView_ addSubview:topButton];
        
        // horn icon
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
        
        // theme new tag image view
        CGSize newTagSize = CGSizeMake(40, 40);
        UIImageView *themeNewTagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(itemContainerWidth - newTagSize.width, 0 , newTagSize.width, newTagSize.height)];
        themeNewTagImageView.image = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"theme_new_tag@2x.png"];
        if (skinInfo_.isNew) {
            themeNewTagImageView.hidden = NO;
        } else {
            themeNewTagImageView.hidden = YES;
        }
        // item container adds subviews
        self.iconImageView.hidden = NO;
        // for the icon image, put a button ontop of it to response to user's click
        self.iconImageView.userInteractionEnabled = YES;
        [self.iconImageView addSubview:imageButton];
        [self.iconImageView addSubview:themeNewTagImageView];
        
        [itemContainer addSubview:self.iconImageView];
        [itemContainer addSubview:button_];
        [itemContainer addSubview:self.textLabel];
        [itemContainer addSubview:progressView_];
        [itemContainer addSubview:_horn];
        
        // adjust the item's width and height
        [self addSubview:itemContainer];
        
        self.frame = CGRectMake(0, 0, TPScreenWidth(), itemContainerHeight + itemMarginTop);
    }
    
    return self;
}

- (void)buttonClicked
{
    if (self.delegate) {
        [self.delegate remoteSkinItemViewButtonDidClick:self];
    }
}
- (void)playOnlineSound
{
    if (self.delegate) {
        [self.delegate buttonDidClick:self];
    }
}


- (void) onIconClicked {
    if (self.delegate) {
        cootek_log(@"RemoteSkinItemView, onIconClicked");
        [self.delegate remoteSkinItemIconDidClick:self];
    }
}

-(void)setButtonStatus:(RemoteSkinItemButtonStatus)buttonStatus
{
    switch (buttonStatus) {
        case SkinItemStatusNotDownloaded:
            [button_ setTitle:NSLocalizedString(@"Download now", @"") forState:UIControlStateNormal];
            [button_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"]] forState:UIControlStateNormal];
            [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_700"]] forState:UIControlStateHighlighted];
            [self clearButtonBorder];
            progressView_.hidden = YES;
            break;
        case SkinItemStatusDownloading:
            [button_ setTitle:NSLocalizedString(@"downloading", @"") forState:UIControlStateNormal];
            [button_ setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"] forState:UIControlStateNormal];
            [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"]] forState:UIControlStateNormal];
            [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"]] forState:UIControlStateHighlighted];
            [self clearButtonBorder];
            progressView_.hidden = NO;
            break;
        case SkinItemStatusDownloaded:
            [button_ setTitle:NSLocalizedString(@"Use", @"") forState:UIControlStateNormal];
            [button_ setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_blue_500"] forState:UIControlStateNormal];
            [button_ setBackgroundImage:[FunctionUtility imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_blue_500"]] forState:UIControlStateHighlighted];
            button_.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_blue_500"].CGColor;
            button_.layer.borderWidth = 1.0f;
            progressView_.hidden = YES;
            break;
        case SkinItemStatusUsed:
            [button_ setTitle:NSLocalizedString(@"In use", @"") forState:UIControlStateNormal];
            [button_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_blue_500"]] forState:UIControlStateNormal];
            [button_ setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_blue_700"]] forState:UIControlStateHighlighted];
            [self clearButtonBorder];
            progressView_.hidden = YES;
            break;
        default:
            break;
    }
    buttonStatus_ = buttonStatus;
}

- (void) clearBorder:(UIView *) view {
    if (view) {
        view.layer.borderWidth = 0.0f;
        view.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void) clearButtonBorder {
    if (button_) {
        [self clearBorder:button_];
    }
}

- (RemoteSkinItemButtonStatus)buttonStatus
{
    return buttonStatus_;
}

- (void)setDownloadProgress:(float)downloadProgress
{
    downloadProgress_ = downloadProgress;
    progressView_.frame = [self progressRect:downloadProgress];
}

- (void)setDownloadProgressAnimated:(float)downloadProgress
{
    //[progressView_ setProgress:downloadProgress animated:YES];
    //downloadProgress_ = downloadProgress;
    [self setDownloadProgress:downloadProgress];
    [progressView_ setNeedsDisplay];
}

- (float)downloadProgress
{
    return downloadProgress_;
}

- (CGRect) progressRect:(CGFloat)progress {
    CGRect frame = progressView_.frame;
    return CGRectMake(frame.origin.x, frame.origin.y, _buttonSize.width * progress, frame.size.height);
}

- (BOOL) hornHidden {
    return _horn.hidden;
}

- (void) setHornHidden:(BOOL) hidden {
    _horn.hidden = hidden;
}

- (float) getMaxWidthForDownloadButton {
    UIFont *__statusTextFont = [UIFont systemFontOfSize:15];
    NSMutableArray *sizes = [[NSMutableArray alloc] initWithCapacity:4];
    [sizes addObject:@([NSLocalizedString(@"downloading", nil) sizeWithFont:__statusTextFont].width)];
    [sizes addObject:@([NSLocalizedString(@"Use", nil) sizeWithFont:__statusTextFont].width)];
    [sizes addObject:@([NSLocalizedString(@"In Use", nil) sizeWithFont:__statusTextFont].width)];
    [sizes addObject:@([NSLocalizedString(@"Download now", nil) sizeWithFont:__statusTextFont].width)];
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
