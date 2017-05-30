//
//  NSString+TPDExtension.m
//  TouchPalDialer
//
//  Created by weyl on 16/11/14.
//
//

#import "NSString+TPDExtension.h"

@implementation NSString (TPDExtension)

- (id)tpd_JSONValue
{
    NSData *data= [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments||NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"[%@]", [NSString stringWithFormat:@"-byb_JSONValue failed:%@", error.localizedDescription]);
        return nil;
    }else{
        return jsonObject;
    }
    
}
@end
