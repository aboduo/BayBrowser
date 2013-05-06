//
//  CommentsView.h
//  BayBrowser
//
//  Created by Ethan Arbuckle on 5/4/13.
//
//

#import <UIKit/UIKit.h>

@interface CommentsView : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
}
@property IBOutlet UITableView *table;
- (IBAction)done:(id)sender;
@end
