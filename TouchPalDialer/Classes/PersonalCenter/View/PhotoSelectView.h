//
//  PhotoSelectView.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/14.
//
//

#import <UIKit/UIKit.h>

@protocol PhotoSelectDelegate <NSObject>

- (void) photoSelected;

@end

@interface PhotoSelectView : UIView

@property (nonatomic, weak) id<PhotoSelectDelegate> delegate;

@end
