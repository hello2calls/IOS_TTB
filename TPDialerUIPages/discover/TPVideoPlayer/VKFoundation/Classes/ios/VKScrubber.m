//
//  Created by Viki.
//  Copyright (c) 2014 Viki Inc. All rights reserved.
//

#import "VKScrubber.h"
#import "VKFoundation.h"

@interface VKScrubber ()
@property (nonatomic, strong) UIImageView *scrubberGlow;
@end

@implementation VKScrubber

@synthesize delegate = _delegate;

- (void) initialize {

  [self setMaximumTrackImage:[[UIImage imageNamed:@"VKScrubber_max"]
      resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)]
      forState:UIControlStateNormal];
  [self setMinimumTrackImage:[[UIImage imageNamed:@"VKScrubber_min"]
      resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)]
      forState:UIControlStateNormal];
  [self setThumbImage:[UIImage imageNamed:@"VKScrubber_thumb"]
      forState:UIControlStateNormal];
  
  [self addTarget:self action:@selector(scrubbingBegin) forControlEvents:UIControlEventTouchDown];
  [self addTarget:self action:@selector(scrubbingEnd) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
  [self addTarget:self action:@selector(scrubberValueChanged) forControlEvents:UIControlEventValueChanged];
  
  self.exclusiveTouch = YES;
}

- (void)scrubbingBegin {
  [self.delegate scrubbingBegin];
}

- (void)scrubbingEnd {
  [self.delegate scrubbingEnd];
}

- (void)scrubberValueChanged {
}

@end
