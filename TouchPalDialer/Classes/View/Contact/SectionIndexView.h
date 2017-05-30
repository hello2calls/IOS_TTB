//
//  SectionIndexView.h
//  TouchPalDialer
//
//  Created by zhang Owen on 11/22/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#define INDEX_SECTION_VIEW_WIDTH (24)
#define INDEX_SECTION_VIEW_HEIGHT_PERCENT (0.55)

#import <UIKit/UIKit.h>



@protocol SectionIndexDelegate

- (void)addClearView;
- (void)beginNavigateSection:(NSString *)section_key;
- (void)move:(double)top;
- (void)endNavigateSection;

@end


@interface SectionIndexView : UIView {
	NSArray *keys;
	int current_section;
	id<SectionIndexDelegate> __unsafe_unretained delegate;
	
	float constvalue;
}

@property(nonatomic, retain) NSArray *keys;
@property(nonatomic) int current_section;
@property(nonatomic, assign) id<SectionIndexDelegate> delegate;

- (id)initSectionIndexView:(CGRect)frame;
- (void)clear;

@end
