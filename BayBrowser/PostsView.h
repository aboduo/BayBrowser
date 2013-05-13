//
//  PostsView.h
//  BayBrowser
//
//  Created by Ethan Arbuckle on 3/23/13.
//
//

#import <UIKit/UIKit.h>
#import "JMTabView.h"
#import "JMSlider.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "IIViewDeckController.h"
#import "AppDelegate.h"
#import "GADBannerView.h"
#import "PayPalMobile.h"

@interface PostsView : UIViewController <UITableViewDataSource, UITableViewDelegate, JMTabViewDelegate, JMSliderDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, IIViewDeckControllerDelegate, PayPalPaymentDelegate>
{
    AppDelegate *appDelegate;
    NSArray *buttonData;
    NSMutableArray *buttons;
    UIActionSheet *menu;
    UIActionSheet *menutwo;
    GADBannerView *bannerAd;
}

@property NSDictionary *posts;
@property NSMutableArray *arrayposts;
@property NSMutableArray *seeders;
@property NSMutableArray *leechers;
@property NSMutableArray *size;
@property NSMutableArray *uplo;
@property NSMutableArray *ids;
@property NSMutableArray *magnet;
@property IBOutlet UINavigationBar *bar;
@property (nonatomic, retain) IBOutlet UITableView *theTable;
@property JMTabView *tabView;
@property (nonatomic, retain) UITableViewCell *sideSwipeCell;
@property (nonatomic, retain) IBOutlet UIView *sideSwipeView;
@property (nonatomic) UISwipeGestureRecognizerDirection *sideSwipeDirection;
@property (nonatomic) BOOL animatingSideSwipeView;

- (UIImage *)imageFilledWith:(UIColor *)color using:(UIImage *)startImage;
- (IBAction)showLeft:(id)sender;
- (void)right:(UIGestureRecognizer *)recognizer;
- (void)setupGestureRecognizer;
- (void)swipe:(UIGestureRecognizer *)recognizer direction:(UISwipeGestureRecognizerDirection)direction;
- (void)animationDidStopAddingSwipeView:(NSString *)animationID finished:(NSString *)finished context:(void *)comtext;
- (void)removeSideSwipeView:(BOOL)animated;
- (void)setupSideSwipeView;
- (void)setStatus:(NSString *)status;
- (void)refresh;
- (void)sortBy:(NSInteger *)index;
- (void)first;
- (void)changeTheme:(BOOL)fullTheme;
- (void)setCrap;
- (void)verifyPro;
- (void)pay;
- (void)feedback;
- (void)requestAd;
- (NSString *)getDescription:(NSString*)urlstring;

@end
