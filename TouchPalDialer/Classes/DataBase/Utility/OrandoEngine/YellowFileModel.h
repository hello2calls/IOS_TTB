//
//  YellowFileModel.h
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-22.
//
//

#import <Foundation/Foundation.h>


@interface YellowFileModel : NSObject
{
    NSInteger fileID;
}
@property(nonatomic,assign)NSInteger fileID;

-(BOOL) openFile:(NSString*)fileName inFolder:(NSString*)folder forIndex:(NSInteger)index;
-(BOOL) isValid;
-(FILE*) fileAtIndex:(NSInteger) index;
-(void) closeAllFiles;
@end

