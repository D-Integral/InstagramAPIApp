//
//  InstagramManager.m
//  InstagramAPIApp
//
//  Created by Dmytro Skorokhod on 10/20/17.
//  Copyright © 2017 Dmytro Skorokhod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramManager.h"
#import <NXOAuth2.h>

static NSString * const kInstagramAccountType = @"Instagram";

static NSString * const kClientId = @"4e20e6be907a4d57aee6e104788e64b8";
static NSString * const kSecret = @"20249876abc941f19f36531a3618bba3";

static NSString * const kAuthorizationURLString = @"https://api.instagram.com/oauth/authorize";
static NSString * const kTokenURLString = @"https://api.instagram.com/oauth/access_token";
static NSString * const kRedirectURLString = @"http://djp3.westmont.edu/classes/2015-coursera-live/redirect.php/myscheme/thing.com";

static NSString * const kRecentMediaBaseURLString = @"https://api.instagram.com/v1/users/self/media/recent/?access_token=";

@interface InstagramManager ()

@property (atomic) NSString *outgoingRedirect;
@property (atomic) NSString *incomingRedirect;

@end

@implementation InstagramManager

+ (id)sharedManager {
    static InstagramManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark -

- (void)setup {
    self.outgoingRedirect = @"http://djp3.westmont.edu/classes/2015-coursera-live/redirect.php/myscheme/thing.com";
    self.incomingRedirect = @"myscheme://thing.com";
    
    [[NXOAuth2AccountStore sharedStore] setClientID:kClientId
                                             secret:kSecret
                                   authorizationURL:[self authorizationURL]
                                           tokenURL:[self tokenURL]
                                        redirectURL:[self redirectURL]
                                     forAccountType:[self accountType]];
}

- (BOOL)openURL:(nonnull NSURL *)url {
    if ([self.incomingRedirect containsString:[url scheme]] && [self.incomingRedirect containsString:[url host]]) {
        NSURL *constructed = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.outgoingRedirect, [url query]]];
        return [[NXOAuth2AccountStore sharedStore] handleRedirectURL:constructed];
    }
    
    return [[NXOAuth2AccountStore sharedStore] handleRedirectURL:url];
}

- (void)loginToInstagram {
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:[self accountType]];
}

- (void)logoutFromInstagram {
    for (id account in [self instagramAccounts]) {
        [[NXOAuth2AccountStore sharedStore] removeAccount:account];
    }
}

#pragma mark -

- (NSString *)accountType {
    return kInstagramAccountType;
}

- (NSArray *)instagramAccounts {
    return [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self accountType]];
}

- (NXOAuth2Account *)instagramAccount {
    NSArray *instagramAccounts = [self instagramAccounts];
    
    if (0 == instagramAccounts.count) {
        return nil;
    }
    
    return instagramAccounts[0];
}

- (NSString *)accessToken {
    return [self instagramAccount].accessToken.accessToken;
}

#pragma mark -

- (NSURL *)authorizationURL {
    return [NSURL URLWithString:kAuthorizationURLString];
}

- (NSURL *)tokenURL {
    return [NSURL URLWithString:kTokenURLString];
}

- (NSURL *)redirectURL {
    return [NSURL URLWithString:self.outgoingRedirect];
}

- (NSString *)recentMediaURLAsString {
    return [kRecentMediaBaseURLString stringByAppendingString:[self accessToken]];
}

- (NSURL *)recentMediaURL {
    return [NSURL URLWithString:[self recentMediaURLAsString]];
}

@end
