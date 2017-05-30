#import <UIKit/UIKit.h>

@interface HighLightLabel : UIView

@property (retain) NSString*	text;
@property (retain) UIFont*		font;
@property (retain) UIColor*		textColor;
@property (retain) UIColor*		highLightColor;
@property (nonatomic,retain, readonly)NSMutableArray* currentInfoArray;

-(id) initHighLightLabeWithFrame:(CGRect)frame withName:(NSString *)name withInfoArr:(NSMutableArray *)info_arr;
-(id) initHighLightLabeWithFrame:(CGRect)frame withNumber:(NSString *)num withRange:(NSRange)range;
-(void) addHighLightRange:(NSRange)pHighLightRange;
-(void) cleanUpHighLightRange;

- (void)refreshName:(NSString *)name withInfoArr:(NSMutableArray *)info_arr;
- (void)refreshNumber:(NSString *)number withRange:(NSRange)range isOnlyShowAttr:(BOOL)isOnlyShowAttr;
- (void)refreshNumber:(NSString *)number withRange:(NSRange)range isShowAttribution:(BOOL)is_attr isOnlyShowAttr:(BOOL)isOnlyShowAttr;
- (void)refreshNumber:(NSString *)number withRange:(NSRange)range isShowAttribution:(BOOL)is_attr;

@end
