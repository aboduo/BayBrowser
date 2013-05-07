//
//  AppDelegate.m
//  BayBrowser
//
//  Created by Ethan Arbuckle on 3/23/13.
//
//

#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "PostsView.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"1821d485-30b2-45b1-91c9-3f7c72103788"];
    self.window.backgroundColor = [UIColor clearColor];
    [self.window.layer setCornerRadius:5.0];
    [self.window.layer setMasksToBounds:YES];
    self.window.layer.opaque = NO;
    _page = 0;
    _reload = NO;
    UIViewController *leftView = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Side"];
    UIViewController *posts = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Posts"];
    _deckController = [[IIViewDeckController alloc] initWithCenterViewController:posts leftViewController:leftView rightViewController:nil];
    _deckController.rightSize = 100;
    _deckController.panningMode = 0;
    self.window.rootViewController = _deckController;
    [self.window makeKeyAndVisible];
    return YES;
    [TestFlight passCheckpoint:@"Launched"];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    _deckController.panningMode = 0;
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    _deckController.panningMode = 1;
}

@end
