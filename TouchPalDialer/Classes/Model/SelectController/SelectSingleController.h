//
//  SelectSingleController.h
//  TouchPalDialer
//
//  Created by game3108 on 16/4/13.
//
//

#import <Foundation/Foundation.h>

@protocol SelectSingleControllerDeledate <NSObject>
- (void)select:(NSDictionary *)dict;
@end

@interface SelectSingleController : NSObject
@property (nonatomic, weak) id<SelectSingleControllerDeledate> delegate;
- (void) showSelectViewBySelectArray:(NSArray *)numberArray;
@end
