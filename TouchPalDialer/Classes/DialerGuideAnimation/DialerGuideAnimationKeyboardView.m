//
//  DialerGuideAnimationKeyboardView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/8/18.
//
//

#import "DialerGuideAnimationKeyboardView.h"
#import "TPDialerResourceManager.h"
#import "DialerGuideAnimationKey.h"
#import "DialerGuideAnimationKeyAnimation.h"
#import "DialerGuideAnimationKeyboardView.h"
#import "DialerGuideAnimationBoardView.h"

@interface DialerGuideAnimationKeyboardView()<DialerGuideAnimationKeyAnimationDelegate,DialerGuideAnimationBoardViewDelegate>{
    NSMutableArray *_viewArray;
    NSMutableArray *_aniArray;
    
    NSInteger _time;
    DialerGuideAnimationBoardView *_boardView;
}

@end

@implementation DialerGuideAnimationKeyboardView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if ( self ){
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.image = [TPDialerResourceManager getImage:@"dialer_guide_keyboard_bg@2x.png"];
        [self addSubview:imageView];
        
        NSArray *numberArray = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"*",@"0",@"#",nil];
        NSArray *subArray = [NSArray arrayWithObjects:@"",@"ABC",@"DEF",@"GHI",@"JKL",@"MNO",@"PQRS",@"TUV",@"WXYZ",NSLocalizedString(@"full_keyboard", @""),@"+",NSLocalizedString(@"paste", @""),nil];
        
        _aniArray = [[NSMutableArray alloc]initWithCapacity:12];
        for ( int i = 0 ; i < 12 ; i ++ ){
            float originX = (i%3) * frame.size.width/3;
            float originY = (i/3) * frame.size.height/4 + 3;
            DialerGuideAnimationKeyAnimation *view = [[DialerGuideAnimationKeyAnimation alloc]initWithFrame:CGRectMake(originX, originY, frame.size.width/3, frame.size.height/4)];
            view.backgroundColor = [UIColor clearColor];
            view.tag = i;
            view.delegate = self;
            [self addSubview:view];
            [_aniArray addObject:view];
        }
        
        
        _viewArray = [[NSMutableArray alloc]initWithCapacity:12];
        for ( int i = 0 ; i < 12 ; i ++ ){
            float originX = (i%3) * frame.size.width/3;
            float originY = (i/3) * frame.size.height/4 + 3;
            DialerGuideAnimationKey *view = [[DialerGuideAnimationKey alloc]initWithFrame:CGRectMake(originX, originY, frame.size.width/3, frame.size.height/4)];
            view.backgroundColor = [UIColor clearColor];
            view.firstLetter = [numberArray objectAtIndex:i];
            view.secondLetter = [subArray objectAtIndex:i];
            [self addSubview:view];
            [_viewArray addObject:view];
        }
        
        ((DialerGuideAnimationKey*)[_viewArray objectAtIndex:9]).firstSize = 40;
        ((DialerGuideAnimationKey*)[_viewArray objectAtIndex:10]).subSize = 14;
        ((DialerGuideAnimationKey*)[_viewArray objectAtIndex:11]).firstSize = 20;
    }
    
    return self;
}

- (void)startAnimation{
    if ( _delegate == nil )
        return;
    _time = 0;
    [((DialerGuideAnimationKeyAnimation*)[_aniArray objectAtIndex:4]) startAnimation];
}

- (void)onAnimationStop{
    if ( _delegate == nil )
        return;
    _time += 1;
    if ( _time == 4 ){
        [_delegate onAnimationOver];
        return;
    }
    if ( _time == 1 )
        [((DialerGuideAnimationKeyAnimation*)[_aniArray objectAtIndex:3]) startAnimation];
    else if ( _time == 2 )
        [((DialerGuideAnimationKeyAnimation*)[_aniArray objectAtIndex:6]) startAnimation];
    else if ( _time == 3 )
        [((DialerGuideAnimationKeyAnimation*)[_aniArray objectAtIndex:3]) startAnimation];
}

- (void)showViewAnimation{
    NSString *tagStr = @"";
    NSInteger tag = 0;
    if ( _time == 0 ){
        tagStr = @"L";
        tag = 4;
    }else if ( _time == 1 ){
        tagStr = @"I";
        tag = 3;
    }else if ( _time == 2 ){
        tagStr = @"S";
        tag = 6;
    }else if ( _time == 3 ){
        tagStr = @"I";
        tag = 3;
    }
    
    float originX = (tag%3) * self.frame.size.width/3;
    float originY = (tag/3) * self.frame.size.height/4 + 3;
    _boardView = [[DialerGuideAnimationBoardView alloc]initWithFrame:
                                           CGRectMake(originX+self.frame.size.width/24, originY , self.frame.size.width/4, self.frame.size.height/5)
                                                                                     andTitle:tagStr andTag:tag];
    _boardView.delegate = self;
    [self addSubview:_boardView];
    [_boardView startAnimation];
    [_delegate onStartAnimation:_time];
}

-(void)dealloc{
    _delegate = nil;
    _boardView.delegate = nil;
    for ( int i = 0 ; i < [_aniArray count] ; i ++ ){
        ((DialerGuideAnimationKeyAnimation*)[_aniArray objectAtIndex:i]).delegate = nil;
    }
}

@end
