//
//  ImageUtils.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-10.
//
//

#import "ImageUtils.h"
#import "NetworkUtility.h"
#import "CTUrl.h"

#define COLOR_HIGHLIGHT_OFFSET -0.2
@implementation ImageUtils

+(NSString *) getImageFilePath:(NSString*) fileName
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *pngFilePath = [cacheDirectory stringByAppendingPathComponent:fileName];
    return pngFilePath;
}

+(NSString *) getImageFilePath:(NSString*) fileName withTag:(NSString *)tag
{
   
    NSFileManager* fm = [NSFileManager defaultManager];
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *tagPath = [cacheDirectory stringByAppendingPathComponent:tag];
    BOOL isDirectory = YES;
    BOOL exists = [fm fileExistsAtPath:tagPath isDirectory:&isDirectory];
    if (!exists || !isDirectory) {
        [fm createDirectoryAtPath:tagPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *pngFilePath = [tagPath stringByAppendingPathComponent:fileName];
    return pngFilePath;
}

+(UIImage *) getImageFromFileName:(NSString*) fileName
{
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@", docDir,fileName];
    UIImage *img = [UIImage imageWithContentsOfFile:pngFilePath];
    return img;
}

+(BOOL) saveImageToFile:(NSString*) fileName withUrl:(NSString*)url
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *localFilePath = [cacheDirectory stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        return YES;
    }

    NSURL *urlRequest=[NSURL URLWithString:[CTUrl encodeRequestUrl:url]];
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] initWithURL:urlRequest
                                                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                         timeoutInterval:10];
    NSHTTPURLResponse *urlResponse = nil;
    NSData *imageData = [NetworkUtility sendSafeSynchronousRequest:httpRequest
                                                      returningResponse:&urlResponse
                                                                  error:nil];
    if ([urlResponse statusCode] == 200) {
        return [imageData writeToFile:localFilePath atomically:YES];
    } else {
        return NO;
    }
    
}

+(BOOL) saveImageToFile:(NSString *) fileName withUrl:(NSString *)url andTag:(NSString *)tag
{
    NSString* localFilePath = [ImageUtils getImageFilePath:fileName withTag:tag];
    if ([[NSFileManager defaultManager] fileExistsAtPath: localFilePath]) {
        return YES;
    }
    
    NSURL *urlRequest=[NSURL URLWithString:[CTUrl encodeRequestUrl:url]];
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] initWithURL:urlRequest
                                                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                timeoutInterval:10];
    NSHTTPURLResponse *urlResponse = nil;
    NSData *imageData = [NetworkUtility sendSafeSynchronousRequest:httpRequest
                                                 returningResponse:&urlResponse
                                                             error:nil];
    if ([urlResponse statusCode] == 200) {
        return [imageData writeToFile:localFilePath atomically:YES];
    } else {
        return NO;
    }
}

+(UIImage *) getImageFromURL:(NSString *)fileURL
{
    UIImage * result;
    
    result = [ImageUtils getImageFromLocalWithUrl:fileURL];
    if (result) {
        return result;
    }
    
    BOOL save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:fileURL] withUrl:fileURL];
    if(save){
        result = [ImageUtils getImageFromLocalWithUrl:fileURL];
    }
    
    return result;
}

+(NSString *) getFilePathWithTag:(NSString *) tag
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *localFilePath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", tag]];
    
    return localFilePath;
}

+(void) getImageFromUrl:(NSString*)url success:(void(^)(UIImage *))successBlock failed:(void(^)(void))failedBlock
{
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            __block UIImage* img = [ImageUtils getImageFromURL:url];
            dispatch_sync(dispatch_get_main_queue(), ^(){
                if (img) {
                    successBlock(img);
                } else {
                    failedBlock();
                }
            });
            
        });
    }
}


+(UIImage *) getImageFromLocalWithUrl:(NSString*) url
{
    
    return [ImageUtils getImageFromCacheFile:[CTUrl encodeUrl:url]];
}

+(UIImage *) getImageFromLocalWithUrl:(NSString*) url andTag:(NSString* )tag
{
    return [ImageUtils getImageFromCacheFile:[CTUrl encodeUrl:url] withTag:tag];
}


+(UIImage *) getImageFromCacheFile:(NSString*) fileName withTag:(NSString* )tag
{
    UIImage *img = [UIImage imageWithContentsOfFile:[ImageUtils getImageFilePath:fileName withTag:tag]];
    return img;
}

+(UIImage *) getImageFromCacheFile:(NSString*) fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *localFilePath = [cacheDirectory stringByAppendingPathComponent:fileName];
    UIImage *img = [UIImage imageWithContentsOfFile:localFilePath];
    return img;
}


+(UIImage *) getImageFromResource:(NSString*) filePath
{
    NSString* extension = [filePath pathExtension];
    NSString* fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
    NSString* directory = [filePath stringByDeletingLastPathComponent];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:extension inDirectory:directory];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    return img;
}

+(UIImage *) getImageFromFilePath:(NSString*) filePath
{
    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    return img;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString andDefaultColor:(UIColor *)defaultColor {
    
    if(hexString == nil || (hexString.length != 7 && hexString.length != 9)) {
        return defaultColor;
    }

    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    if(hexString.length == 7) {
        rgbValue += 0xff000000;
    }
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:((rgbValue & 0xFF000000) >> 24)/255.0];
}

+ (UIColor *) highlightColor:(UIColor *) color
{
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    red += COLOR_HIGHLIGHT_OFFSET;
    green += COLOR_HIGHLIGHT_OFFSET;
    blue += COLOR_HIGHLIGHT_OFFSET;
    return [[UIColor alloc]initWithRed:red green:green blue:blue alpha:alpha];
}

+ (void) drawLineWithColor:(UIColor *) color
                  andFromX:(CGFloat) fromX
                  andFromY:(CGFloat) fromY
                    andToX:(CGFloat) toX
                    andToY:(CGFloat) toY
                  andWidth:(CGFloat) width
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, width);
    
    CGContextMoveToPoint(context, fromX, fromY); //start at this point
    
    CGContextAddLineToPoint(context, toX, toY); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}

+ (void) drawArcRectangleWithContext:(CGContextRef) context
                  andPointTopLeft:(CGPoint) topLeft
                  andPointBottomRight:(CGPoint) bottomRight
                  andRadius:(int) radius
{
    CGContextMoveToPoint(context, topLeft.x + radius, topLeft.y);
    CGContextAddArcToPoint(context, topLeft.x, topLeft.y, topLeft.x, topLeft.y + radius, radius);
    CGContextAddArcToPoint(context, topLeft.x, bottomRight.y , topLeft.x + radius, bottomRight.y, radius);
    CGContextAddArcToPoint(context, bottomRight.x, bottomRight.y, bottomRight.x, bottomRight.y - radius, radius);
    CGContextAddArcToPoint(context, bottomRight.x, topLeft.y, bottomRight.x - radius, topLeft.y, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

+ (UIImage*) createImageWithColor: (UIColor*) color
{
    
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end