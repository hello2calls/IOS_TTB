//
//  YellowFileModel.m
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-22.
//
//

#import "YellowFileModel.h"
#import "def.h"
#import "ContactEngine.h"

@interface YellowFileModel()
{
    FILE* files[orlando::file_size];
}

@end

@implementation YellowFileModel
@synthesize fileID;

-(id) init
{
    self = [super init];
    if(self != nil) {
        for(int i=0; i< orlando::file_size; i++) {
            files[i] = NULL;
        }
        
        fileID = 0;
    }
    return self;
}

-(BOOL) openFile:(NSString*)fileName inFolder:(NSString*)folder forIndex:(NSInteger)index
{
    if(index >= orlando::file_size) {
        return NO;
    }
    
    NSString* filePath = [NSString stringWithFormat:@"%@/%@",folder, fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExtis = [fileManager fileExistsAtPath:filePath];
    if (fileExtis) {
        files[index] = fopen([filePath UTF8String],"r");
        return YES;
    } else {
        files[index] = NULL;
        return NO;
    }
}

-(BOOL) isValid
{
    return files[orlando::calleridFile] != NULL;
}

-(FILE*) fileAtIndex:(NSInteger) index
{
    if(index >= orlando::file_size) {
        return NULL;
    }
    return files[index];
}

-(void) closeAllFiles
{
    for(int i=0; i< orlando::file_size; i++) {
        if(files[i] != NULL)
        {
            fclose(files[i]);
            files[i] = NULL;
        }
    }
}

@end

