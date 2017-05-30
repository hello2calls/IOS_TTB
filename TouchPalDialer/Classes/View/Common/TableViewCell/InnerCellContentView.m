//
//  InnerCellContentView.m
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InnerCellContentView.h"
#import "UIView+WithSkin.h"

#import "TPDialerResourceManager.h"

@implementation InnerCellContentView

- (void) fillWithSource:(ExpandableNode*) sourceNode{
    // override this function to customize the cell
}
@end

@interface DefaultCellContentView() {
    UILabel* headLabel_;
}
@end

@implementation DefaultCellContentView
@synthesize headLabel = headLabel_;
@synthesize icon = icon_;
- (void) fillWithSource:(ExpandableNode*) sourceNode{
    if ([sourceNode.data isKindOfClass:[NSString class]]) {
        headLabel_.text = [NSString stringWithFormat:@"%@", sourceNode.data];
        headLabel_.frame = CGRectMake(45, 0, self.frame.size.width - 35, self.frame.size.height);
        
        icon_.text = sourceNode.imageName;
        icon_.font = [UIFont fontWithName:@"iPhoneIcon2" size:24];
        icon_.frame = CGRectMake(12, 13, 26, 26);

    }
}
- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(45, 0, self.frame.size.width-35, self.frame.size.height);
        headLabel_ = [[UILabel alloc] initWithFrame:rect];
        NSDictionary *operDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"expandableListView_table_style"];
        headLabel_.textColor = [TPDialerResourceManager getColorForStyle:[operDic objectForKey:@"textLabel_color"]];
        [self addSubview:headLabel_];
        headLabel_.backgroundColor = [UIColor clearColor];
        headLabel_.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        rect = CGRectMake(12, 13, 26, 26);
        icon_ = [[UILabel alloc]initWithFrame:rect];
        icon_.textColor = [TPDialerResourceManager getColorForStyle:[operDic objectForKey:@"iconLabel_color"]];
        icon_.backgroundColor = [UIColor clearColor];
        [self addSubview:icon_];
    }
    return self;
}

- (id)selfSkinChange:(NSString *)style{
    NSDictionary *operDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"expandableListView_table_style"];
    headLabel_.textColor = [TPDialerResourceManager getColorForStyle:[operDic objectForKey:@"textLabel_color"]];
    icon_.textColor = [TPDialerResourceManager getColorForStyle:[operDic objectForKey:@"iconLabel_color"]];
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}

@end

