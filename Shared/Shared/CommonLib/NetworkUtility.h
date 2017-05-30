//
//  NetworkUtility.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-10.
//
//

#import <Foundation/Foundation.h>

@interface NetworkUtility : NSObject

//IMPORTANT: no [NSURLConnection sendSynchronousRequest is allowed in the whole project, except for this function.
//Should use [NetworkUtility sendSafeSynchronousRequest: instead.
+ (NSData *)sendSafeSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;

@end
