//
//  FileUtils.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-29.
//
//

#ifndef TouchPalDialer_FileUtils_h
#define TouchPalDialer_FileUtils_h

@interface FileUtils : NSObject
+ (BOOL)mergeContentsOfPath:(NSString *)srcDir intoPath:(NSString *)dstDir keepSrc:(BOOL)keep error:(NSError**)err;
+ (void) unzipFile:(NSString*)fileName toFile:(NSString*)dirFile;
+ (void) unzipFile:(NSString*)fileName;
+ (void) copyFile:(NSString*)fileName;
+ (BOOL) checkFileExist:(NSString*)fileName;
+ (NSString*)getAbsoluteFilePath:(NSString*)fileName;
+ (BOOL) fileExistAtAbsolutePath:(NSString *) absolutePath;
+ (BOOL) saveFileAtAbsolutePathWithData:(NSData *) data atPath:(NSString *) absolutePath overWrite:(BOOL) overWrite;
+ (BOOL) isDir:(NSString *) absolutePath;
+ (BOOL) createDir:(NSString *) absolutePath;
+ (BOOL) createfile:(NSString *) absolutePath;
+ (NSString *) absolutePathOfDocument;
+ (BOOL) removeFileInAbsolutePath:(NSString *)absolutePath;
+ (NSArray *) fileNamesInFolder:(NSString *)folderPath byPredicate:(NSPredicate *)predicate;
+ (NSMutableArray *)getAbsPathArrayContentsOfDirectoryAtPath:(NSString *)path;
+ (NSString *)getNewFileInCommonFileWithPathComponent:(NSString *)pathComponent;
+ (NSString *)getNewFileInCommonFileWithPathComponent:(NSString *)pathComponent ifInsertDir:(BOOL)ifInsertDir;
+ (NSString *) getDocumentRelativePath:(NSString *)fullPath;
@end
#endif
