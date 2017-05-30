//
//  CootekTableView.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/3/14.
//
//

#import <UIKit/UIKit.h>

@protocol CootekTableViewDelegate

- (void) onTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) onTouchesEnd:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface CootekTableView : UITableView

@property (nonatomic, assign) id<CootekTableViewDelegate> cootekDelegate;

@end
