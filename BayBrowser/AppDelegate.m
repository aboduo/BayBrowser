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
#import "WBStickyNoticeView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.window.backgroundColor = [UIColor clearColor];
    [self.window.layer setCornerRadius:5.0];
    [self.window.layer setMasksToBounds:YES];
    self.window.layer.opaque = NO;
    _page = 0;
    _reload = NO;
    _payPressed = NO;
    UIViewController *leftView = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Side"];
    UIViewController *posts = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Posts"];
    _deckController = [[IIViewDeckController alloc] initWithCenterViewController:posts leftViewController:leftView rightViewController:nil];
    _deckController.rightSize = 100;
    _deckController.panningMode = 0;
    self.window.rootViewController = _deckController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    _deckController.panningMode = 0;
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    _deckController.panningMode = 1;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ethanarbuckle.com/message.json"]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"last-message"] isEqual:[JSON objectForKey:@"id"]]) {
            if ([[JSON objectForKey:@"message"] length] > 1) {
                WBStickyNoticeView *notice = [WBStickyNoticeView stickyNoticeInView:_deckController.centerController.view title:[JSON objectForKey:@"message"]];
                [notice show];
                [[NSUserDefaults standardUserDefaults] setValue:[JSON objectForKey:@"id"] forKey:@"last-message"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    } failure:nil];
    [operation start];
}

@end
