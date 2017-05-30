//
//  CustomTextField.h
//  CallInfoShow
//
//  Created by Liangxiu on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomTextFieldPasteDelegate
- (void)textField:(UITextField *)textField didPasteWithEffectText:(NSString *)text;
@end

@interface CustomTextField : UITextField
@property (nonatomic,assign) BOOL needFilterCharacters;
@property (nonatomic,assign) id<CustomTextFieldPasteDelegate> pasteDelegate;
@property (nonatomic,assign) NSInteger leftInset;
@end
