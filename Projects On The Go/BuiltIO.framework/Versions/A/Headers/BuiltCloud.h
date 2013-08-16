//
//  BuiltCloud.h
//  builtDemo
//
//  Created by Akshay Mhatre on 07/08/13.
//  Copyright (c) 2013 raweng. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Execute a code snippet in cloud*/

@interface BuiltCloud : NSObject

/**
 @abstract Makes a call to a cloud function
 */
+ (void)executeWithName:(NSString *)functionName
                   data:(NSDictionary *)properties
              onSuccess:(void (^) (void))successBlock
                onError:(void (^) (NSError *error))errorBlock;

@end
