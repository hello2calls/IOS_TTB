//
//  PersonOperationView.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-17.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "PersonOperationView.h"
#import "TPDialerResourceManager.h"

@implementation PersonOperationView

@synthesize fav_person;
@synthesize person_opera_delegate;
@synthesize operation_view_y;

- (id)initWithPerson:(FavoriteDataModel *)person Index:(NSInteger)index{
    
    self = [super initWithFrame:CGRectMake(0,0,TPScreenWidth(),TPScreenHeight())];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
		self.fav_person = person;
        
        OperationScrollView *scroll=[[OperationScrollView alloc] initWithPersonID:self.fav_person withArray:nil];
 		[self addSubview:scroll];
    }
    return self; 
}

- (void)drawRect:(CGRect)rect {
    int height;
    int shadow = 7.5;
    height = (TPScreenHeight() > 500) ? 394 : 340;    
    
    UIImage *bg = [[TPDialerResourceManager sharedManager] getCachedImageByName:@"fav_pop_person_bg@2x.png"];
    [bg drawInRect:CGRectMake((TPScreenWidth()-285)*0.5 - shadow, (TPScreenHeight()-height)*0.5 - shadow,
                              285 + 2*shadow,height + 2*shadow)];
}

@end
