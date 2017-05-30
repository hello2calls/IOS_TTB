//
//  TipsView.m
//  TouchPalDialer
//
//  Created by Alice on 12-2-6.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TipsView.h"
#import "TPDialerResourceManager.h"

@implementation TipsView


- (id)initWithTipsView:(CGRect)frame  withContent:(NSString *)contentString withTipsPosition:(CGRect)rect{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.backgroundColor = [UIColor clearColor];
		
		UILabel *contentView = [[UILabel alloc]initWithFrame:rect];
		contentView.backgroundColor = [UIColor clearColor];
		contentView.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
		contentView.text = contentString;
         contentView.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"defaultText_color"];
        
//        NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//        NSDictionary * tdic = @{NSFontAttributeName:contentView.font, NSParagraphStyleAttributeName:paragraphStyle};
//        CGSize labelsize = [contentString boundingRectWithSize:CGSizeMake(TPScreenWidth()-30, 150)
//                                            options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                         attributes:tdic
//                                            context:nil].size;
        
		CGSize labelsize = [contentString sizeWithFont:contentView.font constrainedToSize:CGSizeMake(TPScreenWidth()-30, 150) lineBreakMode:NSLineBreakByWordWrapping];
		[contentView setFrame:CGRectMake(contentView.frame.origin.x+10, contentView.frame.origin.y, labelsize.width-20, labelsize.height+25)];
		contentView.numberOfLines = 0;
		contentView.lineBreakMode = NSLineBreakByWordWrapping;

		
		UIImage *bgImg = [[[TPDialerResourceManager sharedManager] getImageByName :@"common_tips_bg@2x.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:25];		
		UIImageView *bg_imageview = [[UIImageView alloc] initWithImage:bgImg];		
		bg_imageview.frame = CGRectMake(rect.origin.x-20, rect.origin.y-10, rect.size.width+20, rect.size.height+10);
		[self addSubview:bg_imageview];
		[self addSubview:contentView];
		
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
	
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if (self) {
		[self removeFromSuperview];
	}
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

@end
