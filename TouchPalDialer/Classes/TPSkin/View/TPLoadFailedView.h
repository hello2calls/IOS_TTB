//
//  WebLoadFailedView.h
//  TouchPalDialer
//
//  Created by siyi on 15/10/29.
//
//

#ifndef TPLoadFailedView_h
#define TPLoadFailedView_h

@protocol TPLoadFailedViewDelegate <NSObject>

- (void) onTapped;
@end

@interface TPLoadFailedView : NSObject


@end

#endif /* TPLoadFailedView_h */
