//
//  CommentsCell.h
//  BayBrowser
//
//  Created by Ethan Arbuckle on 5/6/13.
//
//

#import <UIKit/UIKit.h>

@interface CommentsCell : UITableViewCell
@property IBOutlet UITextView *text;
@property IBOutlet UILabel *usernameLabel;
@property IBOutlet UILabel *dateLabel;

@end
