//
//  detailsView.h
//  BayBrowser
//
//  Created by Ethan Arbuckle on 5/2/13.
//
//

#import <UIKit/UIKit.h>
#import "AFImagePager.h"

@interface detailsView : UIViewController <AFImagePagerDataSource, AFImagePagerDelegate, UIScrollViewDelegate>
@property IBOutlet UITextView *text;
@property IBOutlet UIScrollView *scoller;
@property IBOutlet AFImagePager *pictureView;
@property NSString *textString;
@property NSString *URL;
- (IBAction)close:(id)sender;
- (IBAction)comments:(id)sender;
- (NSString *)getDescription:(NSString*)urlstring;
@end
