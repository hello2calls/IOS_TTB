//
//  ImageUtils.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-10.
//
//

@interface ImageUtils : NSObject
+(NSString *) getImageFilePath:(NSString*) fileName;
+(NSString *) getImageFilePath:(NSString*) fileName withTag:(NSString *)tag;
+(UIImage *) getImageFromFileName:(NSString *) fileName;
+(NSString *) getFilePathWithTag:(NSString *) tag;
+(BOOL) saveImageToFile:(NSString *) fileName withUrl:(NSString *)url;
+(BOOL) saveImageToFile:(NSString *) fileName withUrl:(NSString *)url andTag:(NSString *)tag;
+(UIImage *) getImageFromURL:(NSString *) fileURL;
+(UIImage *) getImageFromLocalWithUrl:(NSString*) url;
+(UIImage *) getImageFromLocalWithUrl:(NSString*) url andTag:(NSString* )tag;
+(UIImage *) getImageFromResource:(NSString *) filePath;
+(UIImage *) getImageFromFilePath:(NSString*) filePath;
+ (UIColor *) colorFromHexString:(NSString *) hexString andDefaultColor:(UIColor *)defaultColor;
+ (UIImage*) createImageWithColor: (UIColor*) color;
+ (UIColor *) highlightColor:(UIColor *) color;
+ (void) drawLineWithColor:(UIColor *) color
                  andFromX:(CGFloat) fromX
                  andFromY:(CGFloat) fromY
                    andToX:(CGFloat) toX
                    andToY:(CGFloat) toY
                  andWidth:(CGFloat) width;
+ (void) drawArcRectangleWithContext:(CGContextRef) context
                     andPointTopLeft:(CGPoint) topLeft
                 andPointBottomRight:(CGPoint) bottomRight
                           andRadius:(int) radius;

+(void) getImageFromUrl:(NSString*)url success:(void(^)(UIImage *))successBlock failed:(void(^)(void))failedBlock;
@end