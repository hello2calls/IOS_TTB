//
//  ContactEditNoteView.h
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-26.
//
//

#import <UIKit/UIKit.h>

@interface ContactEditNoteView : UIView<UITextViewDelegate>

- (id)initWithPersonId:(NSInteger)personId note:(NSString *)note;

@property (nonatomic, assign, readonly) NSInteger personId;
@property (nonatomic, retain, readonly) NSString *note;

@end
