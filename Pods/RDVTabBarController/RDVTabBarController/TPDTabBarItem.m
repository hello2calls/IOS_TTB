//
//  TPDTabBarItem.m
//  TouchPalDialer
//
//  Created by weyl on 16/12/23.
//
//

#import "TPDTabBarItem.h"
#import <Masonry.h>


@interface TPDTabBarItem ()
@property (nonatomic,strong) UIImageView* mainImageView;
@property (nonatomic,strong) UIImageView* pushImageView;
@property (nonatomic) BOOL hasPush;
@property (nonatomic) NSString* mainImageName;
@property (nonatomic,strong) UIImage* mainImageNormal;
@property (nonatomic,strong) UIImage* mainImageSelected;

@end


@implementation TPDTabBarItem
+(TPDTabBarItem*)dialTabItem{
    TPDTabBarItem* ret = [[TPDTabBarItem alloc] init];
    ret.imageAndTextPrefix = @"common_tabbar_call_log";
    ret.imagePrefix = @"common_tabbar_dialer";
    ret.textPrefix = @"";
    [ret reconfig];
    return ret;
}

+(TPDTabBarItem*)contactTabItem{
    TPDTabBarItem* ret = [[TPDTabBarItem alloc] init];
    ret.imageAndTextPrefix = @"common_tabbar_contacts";
    ret.imagePrefix = @"common_tabbar_contact";
    ret.textPrefix = @"";
    [ret reconfig];
    return ret;
}

+(TPDTabBarItem*)discoveryTabItem{
    TPDTabBarItem* ret = [[TPDTabBarItem alloc] init];
    ret.imageAndTextPrefix = @"common_tabbar_discovery";
    ret.imagePrefix = @"common_tabbar_find";
    ret.textPrefix = @"common_tabbar_discovery_text";
    [ret reconfig];
    return ret;
}

+(TPDTabBarItem*)meTabItem{
    TPDTabBarItem* ret = [[TPDTabBarItem alloc] init];
    ret.imageAndTextPrefix = @"common_tabbar_me";
    ret.imagePrefix = @"common_tabbar_me";
    ret.textPrefix = @"common_tabbar_me_text";
    [ret reconfig];
    return ret;
}

-(void)reconfig{
//    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    BOOL hasText = YES;
    self.hasPush = NO;
    
    if (self.hasPush) {
        if (hasText) {
            self.mainImageName = self.textPrefix;
        }else{
            self.mainImageName = self.imagePrefix;
        }
        self.pushImageView.hidden = NO;
    }else{
        if (hasText) {
            self.mainImageName = self.imageAndTextPrefix;
        }else{
            self.mainImageName = @"";
        }
        self.pushImageView.hidden = YES;
    }
    
    Class class = NSClassFromString(@"TPDialerResourceManager");
    SEL selector = NSSelectorFromString(@"getImage:");
    self.mainImageNormal = [class performSelector:selector  withObject:[NSString stringWithFormat:@"%@_normal@2x.png",self.mainImageName]];
    
    self.mainImageSelected = [class performSelector:selector  withObject:[NSString stringWithFormat:@"%@_pressed@2x.png",self.mainImageName]];
    
    [self setNeedsDisplay];
}


-(void)drawRect:(CGRect)rect{
    
    if (self.isSelected || self.isHighlighted) {
        [self.mainImageView setImage:self.mainImageSelected];
    }else{
        [self.mainImageView setImage:self.mainImageNormal];
        
    }
    
}

-(double)itemHeight{
    return 49;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.mainImageView = [[UIImageView alloc] init];
        self.mainImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.pushImageView = [[UIImageView alloc] init];
        self.pushImageView.contentMode = UIViewContentModeScaleAspectFit;

        [self addSubview:self.mainImageView];
        [self addSubview:self.pushImageView];
        
        [self.mainImageView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.pushImageView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).offset(-18);
            make.width.height.equalTo(26);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"N_CALL_LOG_LIST_CHANGED" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [self reconfig];
        }];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
