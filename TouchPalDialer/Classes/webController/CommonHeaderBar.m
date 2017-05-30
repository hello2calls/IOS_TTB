//
//  CommonHeaderBar.m
//  TouchPalDialer
//
//  Created by game3108 on 15/4/13.
//
//

#import "UIView+WithSkin.h"
#import "CommonHeaderBar.h"
#import "TPDialerResourceManager.h"
#import "HeaderBar.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
@interface CommonHeaderBar (){
    NSString *_headerTitle;
}

@end

@implementation CommonHeaderBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if ( self ){
        _skinEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        
        // header bar as the background container
        HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBarWithFrame:frame title:nil];
        [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
        
        // Label
        if (_headerTitle != nil) {
            _headerLabel = [[TPHeaderLabel alloc] initWithFrame:CGRectMake(60, TPHeaderBarHeightDiff(), frame.size.width - 120, 45)];
            [_headerLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
            _headerLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2];
            _headerLabel.textAlignment = NSTextAlignmentCenter;
            _headerLabel.backgroundColor = [UIColor clearColor];
            _headerLabel.text = _headerTitle;
        }
        
        
        // view settings
        _imageView = headerBar.bgView;
        
        
        [self setSkinEnabled:YES];
        
        BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
         if(isVersionSix) {
            // back button
            UIColor *tColor =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
            
            TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,45, 50)];
            backBtn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
            [backBtn setTitle:@"0" forState:UIControlStateNormal];
            [backBtn setTitle:@"0" forState:UIControlStateHighlighted];
            [backBtn setTitleColor:tColor forState:UIControlStateNormal];
            backBtn.autoresizingMask = UIViewAutoresizingNone;
            [backBtn addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
            _leftButton = backBtn;
            
            _headerLabel.textColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"];
        } else {
            // BackButton
            _leftButton = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(5, 0, 45, 45)];
            [_leftButton setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
            [_leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        }

        // view tree
        [self addSubview:headerBar];
        [self addSubview:_leftButton];
        [self addSubview:_headerLabel];

    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andHeaderTitle:(NSString *)headerTitle{
    if ( headerTitle) {
        _headerTitle  = headerTitle;
    }
    self = [self initWithFrame:frame];
    return self;
    
}

- (void) setHeaderTitle:(NSString *)headerTitle{
    _headerTitle = headerTitle;
    _headerLabel.text = headerTitle;
}

- (void) leftButtonAction{
    [_delegate leftButtonAction];
}

- (void) setLight:(BOOL)ifLight{
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];

    if ( ifLight ){
        if(isVersionSix) {

            UIColor *tColor =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_ht_color"];
            [_leftButton setTitleColor:tColor forState:UIControlStateNormal];

        }else {
            [_leftButton setImage:[TPDialerResourceManager getImage:@"white_navigation_back_icon@2x.png"] forState:UIControlStateNormal];
            _headerLabel.textColor = [UIColor whiteColor];

        }
    }else{
        if(isVersionSix) {
            UIColor *tColor =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
            [_leftButton setTitleColor:tColor forState:UIControlStateNormal];

            
        }else {
            [_leftButton setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
            [_headerLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];

        }
    }
}

- (void) setSkinEnabled:(BOOL)skinEnabled {
    BOOL changed = (_skinEnabled != skinEnabled);
    if (!changed) {
        return;
    }
    _skinEnabled = skinEnabled;
    if (skinEnabled) {
        [[TPDialerResourceManager sharedManager] addSkinHandlerForView:self];
    } else {
        [[TPDialerResourceManager sharedManager] removeSkinHandlerForView:self];
    }
}

- (void) dealloc {
    [[TPDialerResourceManager sharedManager] removeSkinHandlerForView:self];
}

@end
