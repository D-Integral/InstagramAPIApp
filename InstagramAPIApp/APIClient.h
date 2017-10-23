//
//  APIClient.h
//  InstagramAPIApp
//
//  Created by Dmytro Skorokhod on 10/23/17.
//  Copyright © 2017 Dmytro Skorokhod. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIClient : NSObject

+ (id)sharedClient;

- (NSURLSessionDataTask *)getRecentMediaDataTask:(void (^)(NSData *data))completionHandler;

@end
