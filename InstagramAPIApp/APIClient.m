//
//  APIClient.m
//  InstagramAPIApp
//
//  Created by Dmytro Skorokhod on 10/23/17.
//  Copyright © 2017 D-Integral. All rights reserved.
//

#import "APIClient.h"
#import "InstagramManager.h"

@implementation APIClient

+ (id)sharedClient {
    static APIClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    
    return sharedClient;
}

- (NSURLSessionDataTask *)getRecentMediaDataTask:(void (^)(NSData *data))completionHandler {
    return [[NSURLSession sharedSession] dataTaskWithURL:[self recentMediaURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (nil != error) {
            NSLog(@"Error. Couldn't finish request. %@", error.localizedDescription);
            
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            NSLog(@"Error. Got status code %ld", (long)httpResponse.statusCode);
            
            return;
        }
        
        NSError *parseError;
        id parsedResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        if (nil == parsedResponse) {
            NSLog(@"Error. Couldn't parse response. %@", parseError.localizedDescription);
            
            return;
        }
        
        NSString *imageURLString = parsedResponse[@"data"][0][@"images"][@"standard_resolution"][@"url"];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (nil != error) {
                NSLog(@"Error. Couldn't finish request. %@", error.localizedDescription);
                
                return;
            }
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
                NSLog(@"Error. Got status code %ld", (long)httpResponse.statusCode);
                
                return;
            };
            
            completionHandler(data);
        }] resume];
    }];
}

- (NSURL *)recentMediaURL {
    return [[InstagramManager sharedManager] recentMediaURL];
}

@end
