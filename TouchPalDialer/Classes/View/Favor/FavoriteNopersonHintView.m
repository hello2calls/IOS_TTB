//
//  FavoriteNopersonHintView.m
//  TouchPalDialer
//
//  Created by 史玮 阮 on 13-8-19.
//
//

#import "FavoriteNopersonHintView.h"
#import "TPDialerResourceManager.h"

@implementation FavoriteNopersonHintView
@synthesize noFaveView;
@synthesize fav_button;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(365))];
    if (self) {
        // Initialization code
        UIImage* noFavImage = [[TPDialerResourceManager sharedManager] getImageByName:@"favourite_none_pic@2x.png"];
        UIImageView *noFavImageView = [[UIImageView alloc] initWithFrame:CGRectMake((TPScreenWidth()-155)/2, frame.origin.y, 155, 160)];
        self.noFaveView = noFavImageView;
        noFaveView.image = noFavImage;
        [self addSubview:noFaveView];
        
        self.fav_button = [TPUIButton buttonWithType:UIButtonTypeCustom];
        fav_button.frame = CGRectMake(TPScreenWidth() / 2 - 105, frame.size.height - 35 + frame.origin.y, 210, 35);
        
        [self addSubview:fav_button];
        
    }
    return self;
}

- (id)initWithContactNoUnRegFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, frame.origin.y, TPScreenWidth(), TPHeightFit(365))];
    if (self) {
        // Initialization code
        UIImage* noFavImage = [[TPDialerResourceManager sharedManager] getImageByName:@"contacts_group_none_pic@2x.png"];
        UIImageView *noFavImageView = [[UIImageView alloc] initWithFrame:CGRectMake((TPScreenWidth()-155)/2, frame.origin.y, 155, 160)];
        self.noFaveView = noFavImageView;
        noFaveView.image = noFavImage;
        [self addSubview:noFaveView];
        
        self.fav_button = [TPUIButton buttonWithType:UIButtonTypeCustom];
        fav_button.frame = CGRectMake(TPScreenWidth() / 2 - 105, frame.size.height - 35 + frame.origin.y, 210, 35);
        
        [self addSubview:fav_button];
        
    }
    return self;
}

- (id)selfSkinChange:(NSString *)style {
    self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    noFaveView.image = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"hintImage"]];
    CGSize imageSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    UIColor *normalColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"AddMemberButtonColor_normal_color"];
    [normalColor set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *normalColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [fav_button setBackgroundImage:normalColorImg forState:UIControlStateNormal];
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    UIColor *pressColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"AddMemberButtonColor_pressed_color"];
    [pressColor set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [fav_button setBackgroundImage:pressedColorImg forState:UIControlStateHighlighted];
    [fav_button setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultText_color"] forState:UIControlStateNormal];

    NSNumber * toTop = [NSNumber numberWithBool:YES];
    return toTop;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
