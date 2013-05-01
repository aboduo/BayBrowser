//
//  SideViewViewController.h
//  BayBrowser
//
//  Created by Ethan Arbuckle on 3/30/13.
//
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"

@interface SideViewViewController : UITableViewController <IIViewDeckControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    NSArray *objects;
}
@property IBOutlet UISearchBar *serch;
@property IBOutlet UITableView *tablest;
@end
