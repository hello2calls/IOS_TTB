//
//  SectionFindNews.h
//  TouchPalDialer
//
//  Created by tanglin on 15/12/23.
//
//

#import "SectionBase.h"
#import "FindNewsItem.h"

@interface SectionFindNews : SectionBase

@property(nonatomic, strong) NSString* queryId;
@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) NSString* tu;

- (id) initWithJson: (NSDictionary*) json;

@end
