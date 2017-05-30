//
//  FileUtils.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-29.
//
//

#import <Foundation/Foundation.h>
#import "FileUtils.h"
#import <ZipArchive/ZipArchive.h>

@implementation FileUtils

+ (BOOL)mergeContentsOfPath:(NSString *)srcDir intoPath:(NSString *)dstDir keepSrc:(BOOL)keep error:(NSError**)err {
    
    cootek_log([NSString stringWithFormat:@"- mergeContentsOfPath: %@\n intoPath: %@", srcDir, dstDir]);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *srcDirEnum = [fm enumeratorAtPath:srcDir];
    NSString *subPath;
    while ((subPath = [srcDirEnum nextObject])) {
        
        NSString *srcFullPath =  [srcDir stringByAppendingPathComponent:subPath];
        NSString *potentialDstPath = [dstDir stringByAppendingPathComponent:subPath];
        
        // Need to also check if file exists because if it doesn't, value of `isDirectory` is undefined.
        BOOL isDirectory = ([[NSFileManager defaultManager] fileExistsAtPath:srcFullPath isDirectory:&isDirectory] && isDirectory);
        
        // Create directory, or delete existing file and move file to destination
        if (isDirectory) {
            [fm createDirectoryAtPath:potentialDstPath withIntermediateDirectories:YES attributes:nil error:err];
            if (err && *err) {
                cootek_log([NSString stringWithFormat:@"ERROR: %@", *err]);
                return NO;
            }
        }
        else {
            if ([fm fileExistsAtPath:potentialDstPath]) {
                [fm removeItemAtPath:potentialDstPath error:err];
                if (err && *err) {
                    cootek_log([NSString stringWithFormat:@"ERROR: %@", *err]);
                    return NO;
                }
            }
            
            if (keep) {
                [fm copyItemAtPath:srcFullPath toPath:potentialDstPath error:err];
            } else {
                [fm moveItemAtPath:srcFullPath toPath:potentialDstPath error:err];
            }
            
            if (err && *err) {
                cootek_log([NSString stringWithFormat:@"ERROR: %@", *err]);
                return NO;
            }
        }
    }
    return YES;
}


+ (void) unzipFile:(NSString*)fileName toFile:(NSString *)dirFile {
    ZipArchive* zip = [[ZipArchive alloc] init];
    
    NSString *zipFilePath = fileName;
    NSString* unzipto = dirFile ;
    if( [zip UnzipOpenFile:zipFilePath] ) {
        BOOL ret = [zip UnzipFileTo:unzipto overWrite:YES];
        if( NO==ret ){
            cootek_log(@"zip file failed");
        }
        [zip UnzipCloseFile];
    }
}

+ (void) unzipFile:(NSString*)fileName {
    ZipArchive* zip = [[ZipArchive alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *zipFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    NSString* unzipto = [zipFilePath stringByDeletingLastPathComponent] ;
    if( [zip UnzipOpenFile:zipFilePath] ) {
        BOOL ret = [zip UnzipFileTo:unzipto overWrite:YES];
        if( NO==ret ){
            cootek_log(@"zip file failed");
        }
        [zip UnzipCloseFile];
    }
}


+ (void)copyFile:(NSString *)fileName {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] copyItemAtPath:sourcePath
                                            toPath:[documentsDirectory stringByAppendingPathComponent:fileName]
                                             error:NULL];
}

+ (BOOL) checkFileExist:(NSString*)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
    
}


+ (NSString *)getAbsoluteFilePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (NSString *) getDocumentRelativePath:(NSString *)fullPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths.firstObject;
    if ([fullPath hasPrefix:documentDirectory]) {
        return [fullPath substringFromIndex:documentDirectory.length + 1];
    } else {
        return fullPath;
    }
}

+ (BOOL) fileExistAtAbsolutePath:(NSString *) absolutePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:absolutePath];
}

+ (BOOL) saveFileAtAbsolutePathWithData:(NSData *) data atPath:(NSString *) absolutePath overWrite:(BOOL) overWrite;{
    if (data == nil || absolutePath == nil) return NO;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (!overWrite && [fm fileExistsAtPath:absolutePath] ) return NO;
    
    NSError *err = nil;
    NSString *dir = [absolutePath stringByDeletingLastPathComponent];
    if (![fm fileExistsAtPath:dir]) {
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
    }
    if (err != nil) return NO;
    return [data writeToFile:absolutePath atomically:YES];
}

+ (BOOL) isDir:(NSString *) absolutePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    [fm fileExistsAtPath:absolutePath isDirectory:&isDir];
    return isDir;
}

+ (BOOL) createDir:(NSString *) absolutePath {
    if (!absolutePath || absolutePath.length == 0) {
        return NO;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err = nil;
    [fm createDirectoryAtPath:absolutePath withIntermediateDirectories:YES attributes:nil error:&err];
    return !err;
}
+ (BOOL) createfile:(NSString *) absolutePath {
    if (!absolutePath || absolutePath.length == 0) {
        return NO;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err = nil;
    [fm createFileAtPath:absolutePath contents:nil attributes:nil];
    return !err;
}


+ (NSString *) absolutePathOfDocument {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}



+(NSMutableArray *)getAbsPathArrayContentsOfDirectoryAtPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *AbsPathArray = [NSMutableArray array];
    if ([self isDir:path]) {
        NSError *error = nil;
        NSArray *array = [fm contentsOfDirectoryAtPath:path error:&error];
        for (NSString *content in array) {
            NSString *nextPath = [path stringByAppendingPathComponent:content];
            [AbsPathArray  addObjectsFromArray:[self getAbsPathArrayContentsOfDirectoryAtPath:nextPath]];
        }
    }else{
        [AbsPathArray addObject:path];
    }
    return AbsPathArray;
}

+ (BOOL) removeFileInAbsolutePath:(NSString *)absolutePath{
     NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:absolutePath]){
        NSError *error;
        [fm removeItemAtPath:absolutePath error:&error];
        if (error) {
            cootek_log(@"%@",[error description]);
            return NO;
        }
        return YES;
        
    }
    return NO;
}


+ (NSArray *) fileNamesInFolder:(NSString *)folderPath byPredicate:(NSPredicate *)predicate {
    NSArray *ret = [[NSArray alloc] init];
    if ([FileUtils isDir:folderPath]) {
        NSError *error = nil;
        ret = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
        if (error == nil && predicate != nil) {
            ret = [ret filteredArrayUsingPredicate:predicate];
        }
    }
    return ret;
}
+ (NSString *)getNewFileInCommonFileWithPathComponent:(NSString *)pathComponent {
    NSString *docmentCommonFileDirPath= [FileUtils getAbsoluteFilePath:@"commonFile"];
    if (![self fileExistAtAbsolutePath:docmentCommonFileDirPath]) {
        [FileUtils createDir:docmentCommonFileDirPath];
    }
    NSString *CommonFileNewFilePath = [docmentCommonFileDirPath stringByAppendingPathComponent:pathComponent];
    return CommonFileNewFilePath;
    
}
+ (NSString *)getNewFileInCommonFileWithPathComponent:(NSString *)pathComponent ifInsertDir:(BOOL)ifInsertDir {
    NSString *docmentCommonFileDirPath= [FileUtils getAbsoluteFilePath:@"commonFile"];
    if (![self fileExistAtAbsolutePath:docmentCommonFileDirPath]) {
        [FileUtils createDir:docmentCommonFileDirPath];
    }
    NSString *CommonFileNewFilePath = [docmentCommonFileDirPath stringByAppendingPathComponent:pathComponent];
    
    if (ifInsertDir && ![self fileExistAtAbsolutePath:[CommonFileNewFilePath stringByDeletingLastPathComponent]]) {
        [FileUtils createDir:[CommonFileNewFilePath stringByDeletingLastPathComponent]];
    }
    return CommonFileNewFilePath;
}

@end
