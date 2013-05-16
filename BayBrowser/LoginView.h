//
//  LoginView.h
//  BayBrowser
//
//  Created by Ethan Arbuckle on 5/15/13.
//
//

#import <UIKit/UIKit.h>

@interface LoginView : UIViewController

@property IBOutlet UITextField *username;
@property IBOutlet UITextField *pass;
- (IBAction)login:(id)sender;
- (IBAction)cancel:(id)sender;
@end
