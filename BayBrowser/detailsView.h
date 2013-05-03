//
//  detailsView.h
//  BayBrowser
//
//  Created by Ethan Arbuckle on 5/2/13.
//
//

#import <UIKit/UIKit.h>

@interface detailsView : UIViewController
@property IBOutlet UITextView *text;
@property NSString *textString;
@property NSString *URL;
- (IBAction)close:(id)sender;
- (NSString *)getDescription:(NSString*)urlstring;
@end
