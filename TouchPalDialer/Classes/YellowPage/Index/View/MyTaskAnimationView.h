//
//  MyTaskAnimationView.h
//  TouchPalDialer
//
//  Created by tanglin on 16/7/18.
//
//

#import "YPUIView.h"
#import "SectionMyTask.h"
#import "MyTaskItem.h"

@interface MyTaskAnimationView :UIView
@property(nonatomic, strong)UIImage* icon;
@property(nonatomic, strong)NSString* url;
@property(nonatomic, strong)MyTaskItem* task;

- (void) drawView;

@end
