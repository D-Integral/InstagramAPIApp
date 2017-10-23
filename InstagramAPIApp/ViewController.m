//
//  ViewController.m
//  InstagramAPIApp
//
//  Created by Dmytro Skorokhod on 10/20/17.
//  Copyright © 2017 Dmytro Skorokhod. All rights reserved.
//

#import "ViewController.h"
#import "InstagramManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self enableUI:NO];
}

- (IBAction)loginButtonTapped:(id)sender {
    [[InstagramManager sharedManager] loginToInstagram];
    
    [self enableUI:YES];
}

- (IBAction)logoutButtonTapped:(id)sender {
    [[InstagramManager sharedManager] logoutFromInstagram];
    
    [self enableUI:NO];
}

- (IBAction)refreshButtonTapped:(id)sender {
    [[self getRecentMediaDataTask] resume];
}

- (void)enableUI:(BOOL)flag {
    self.loginButton.enabled = !flag;
    self.logoutButton.enabled = flag;
    self.refreshButton.enabled = flag;
}

- (NSURL *)recentMediaURL {
    return [[InstagramManager sharedManager] recentMediaURL];
}

- (NSURLSessionDataTask *)getRecentMediaDataTask {
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithData:data];
            });
        }] resume];
    }];
}

@end
