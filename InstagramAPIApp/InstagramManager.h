//
//  InstagramManager.h
//  WebAPIApp
//
//  Created by Dmytro Skorokhod on 10/20/17.
//  Copyright © 2017 Dmytro Skorokhod. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstagramManager : NSObject

+ (id _Nullable )sharedManager;

- (void)setup;
- (BOOL)openURL:(nonnull NSURL *)url;

- (void)loginToInstagram;
- (void)logoutFromInstagram;
- (NSURL *_Nullable)recentMediaURL;

@end
