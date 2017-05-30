//
//  FeatureTipModel.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-22.
//
//

#import <Foundation/Foundation.h>

@interface FeatureTipModel : NSObject

@property (nonatomic, copy) NSString* tipKey;
@property (nonatomic, retain) id expectedValue;
@property (nonatomic, assign) BOOL showTip;

+(FeatureTipModel*) featureTipModelWithKey:(NSString*)key expectedValue:(id)value;

-(id) initWithKey:(NSString*) key expectedValue:(id)value;
-(void) removeTip;
@end
