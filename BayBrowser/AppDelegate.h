//
//  AppDelegate.h
//  BayBrowser
//
//  Created by Ethan Arbuckle on 3/23/13.
//
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "AFNetworking.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, IIViewDeckControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property IIViewDeckController *deckController;
@property NSMutableString *QUERY;
@property NSMutableString *URL;
@property NSMutableString *label;
@property NSMutableString *username;
@property NSMutableString *password;
@property NSInteger *page;
@property BOOL more;
@property BOOL loadingSomething;
@property BOOL reload;
@property BOOL payPressed;
@property BOOL authenticated;
- (void)login;
@end
