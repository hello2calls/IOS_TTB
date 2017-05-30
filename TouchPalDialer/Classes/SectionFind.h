//
//  SectionFind.h
//  TouchPalDialer
//
//  Created by tanglin on 15/12/17.
//
//

#import "SectionBase.h"
#import "RightTopItem.h"
#import "CategoryItem.h"

@interface SectionFind : SectionBase
@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) NSString* titleColor;
@property(nonatomic, strong) RightTopItem* rightTopItem;

-(id)initWithJson:(NSDictionary *)json;
@end
