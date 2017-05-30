//
//  SectionMyTask.h
//  TouchPalDialer
//
//  Created by tanglin on 16/7/8.
//
//

#import "sectionbase.h"
#import "CTUrl.h"

@interface SectionMyTask : SectionBase

- (id) initWithJson:(NSDictionary*)json;

@property(nonatomic, strong)NSMutableArray* items;
@property(nonatomic, assign)BOOL isShowing;

@end
