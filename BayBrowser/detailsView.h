//
//  detailsView.h
//  BayBrowser
//
//  Created by Ethan Arbuckle on 5/2/13.
//
//

#import <UIKit/UIKit.h>
#import "AFImagePager.h"
#import "SDSegmentedControl.h"

@interface detailsView : UIViewController <AFImagePagerDataSource, AFImagePagerDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property IBOutlet UITextView *text;
@property IBOutlet UITableView *table;
@property IBOutlet UIScrollView *scoller;
@property IBOutlet AFImagePager *pictureView;
@property NSString *textString;
@property NSString *URL;
@property NSString *ID;
@property IBOutlet SDSegmentedControl *segControl;
- (IBAction)close:(id)sender;
- (IBAction)segChange:(id)sender;
- (IBAction)addComment:(id)sender;
- (NSString *)getDescription:(NSString*)urlstring;
@end
