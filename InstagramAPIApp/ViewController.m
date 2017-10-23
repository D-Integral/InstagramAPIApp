//
//  ViewController.m
//  WebAPIApp
//
//  Created by Dmytro Skorokhod on 10/20/17.
//  Copyright © 2017 Dmytro Skorokhod. All rights reserved.
//

#import "ViewController.h"
#import "InstagramManager.h"
#import "APIClient.h"

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
    [[[APIClient sharedClient] getRecentMediaDataTask:[self updateImageBlock]] resume];
}

- (void)enableUI:(BOOL)flag {
    self.loginButton.enabled = !flag;
    self.logoutButton.enabled = flag;
    self.refreshButton.enabled = flag;
}

- (UpdateRecentMediaBlock)updateImageBlock {
    return ^(NSData *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData:data];
        });
    };
}

@end
