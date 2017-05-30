//
//  MiniBannerRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 16/1/25.
//
//

#import "YPUIView.h"
#import "SectionMiniBanner.h"

@interface MiniBannerRowView : YPUIView
- (void) resetDataWithItem:(SectionMiniBanner*)item andIndexPath:(NSIndexPath*)indexPath;

@end
