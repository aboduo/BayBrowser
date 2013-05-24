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
#import "WBErrorNoticeView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (([[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] length]>1) && ([[[NSUserDefaults standardUserDefaults] valueForKey:@"password"] length]>1)) {
        self.username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        [self login];
    }
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.window.backgroundColor = [UIColor clearColor];
    [self.window.layer setCornerRadius:5.0];
    [self.window.layer setMasksToBounds:YES];
    self.window.layer.opaque = NO;
    _username = [[NSMutableString alloc] init];
    _password = [[NSMutableString alloc] init];
    _page = 0;
    _reload = NO;
    _payPressed = NO;
    UIViewController *posts = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Posts"];
  //  UIViewController *posts = [[PostsView alloc] init];
        UIViewController *leftView = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Side"];
    _deckController = [[IIViewDeckController alloc] initWithCenterViewController:posts leftViewController:leftView rightViewController:nil];
    _deckController.rightSize = 100;
    _deckController.panningMode = 0;
    self.window.rootViewController = _deckController;
    [self.window makeKeyAndVisible];
    [self checkForMessages];
    return YES;
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    _deckController.panningMode = 0;
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    _deckController.panningMode = 1;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self checkForMessages];
}

- (void)checkForMessages {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ethanarbuckle.com/message.json"]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ((![[[NSUserDefaults standardUserDefaults] valueForKey:@"last-message"] isEqual:[JSON objectForKey:@"id"]]) || ([[JSON objectForKey:@"force"] rangeOfString:@"YES"].location != NSNotFound)) {
            if (([[JSON objectForKey:@"show"] rangeOfString:@"NO"].location == NSNotFound) || ([[JSON objectForKey:@"force"] rangeOfString:@"YES"].location != NSNotFound)) {
                WBErrorNoticeView *notice = [[WBErrorNoticeView alloc] initWithView:_deckController.centerController.view title:@"Notice"];
                notice.sticky = YES;
                notice.message = [JSON objectForKey:@"message"];
                [notice show];
                [[NSUserDefaults standardUserDefaults] setValue:[JSON objectForKey:@"id"] forKey:@"last-message"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    } failure:nil];
    [operation start];
    PostsView *posts = (PostsView *)_deckController.centerController;
    [posts requestAd];
}

- (void)login {
    [self logout];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://thepiratebay.sx/login.php?username=%@&password=%@&act=login&submit=Login", [[NSUserDefaults standardUserDefaults] valueForKey:@"username"], [[NSUserDefaults standardUserDefaults] valueForKey:@"password"]]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([response rangeOfString:@"You have no active torrents."].location != NSNotFound) {
            _authenticated = YES;
            UIViewController *leftView = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateViewControllerWithIdentifier:@"Side"];
            _deckController.leftController = leftView;
        } else {
            _authenticated = NO;
        }
    } failure:nil];
    [operation start];
}

- (void)logout {
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://thepiratebay.sx/logout.php/"]]];
    [operation start];
}

@end
