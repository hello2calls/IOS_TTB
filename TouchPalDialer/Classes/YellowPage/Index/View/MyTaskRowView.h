//
//  MyTaskRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 16/7/8.
//
//

#import "YPUIView.h"
#import "SectionMyTask.h"
#import "MyTaskAnimationView.h"
#import "MyTaskItem.h"

@interface MyTaskRowView : YPUIView

@property(nonatomic, strong)UIImage* icon;
@property(nonatomic, strong)NSString* url;
@property(nonatomic, strong)MyTaskItem* task;
@property(nonatomic, strong)MyTaskAnimationView* animationView;
@property(nonatomic, strong)NSIndexPath* path;
@property(nonatomic, assign)BOOL noLine;


- (id)initWithFrame:(CGRect)frame andData:(SectionMyTask*)data andIndexPath:(NSIndexPath*)indexPath;
- (void)drawView;

@end
