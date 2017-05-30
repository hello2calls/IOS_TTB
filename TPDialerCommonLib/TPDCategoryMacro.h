//
//  TPDCategoryMacro.h
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#ifndef TPDCategoryMacro_h
#define TPDCategoryMacro_h
#import <objc/runtime.h>
#define ADD_DYNAMIC_PROPERTY(PROPERTY_TYPE,PROPERTY_NAME,SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
return ( PROPERTY_TYPE ) objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , PROPERTY_NAME , OBJC_ASSOCIATION_RETAIN); \
}


#define ADD_DYNAMIC_PRIMITIVE_PROPERTY(PROPERTY_TYPE,PROPERTY_NAME,SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
NSNumber *number = objc_getAssociatedObject(self, &kProperty##PROPERTY_NAME); \
return [number integerValue]; \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
NSNumber *number = [NSNumber numberWithInteger: PROPERTY_NAME]; \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , number , OBJC_ASSOCIATION_RETAIN); \
}

#endif /* TPDCategoryMacro_h */
