//
//  SideViewViewController.m
//  BayBrowser
//
//  Created by Ethan Arbuckle on 3/30/13.
//
//

#import "SideViewViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "PostsView.h"
#import "LoginView.h"

@interface SideViewViewController ()

@end

@implementation SideViewViewController

- (void)viewWillAppear:(BOOL)animated {
    CGRect frame = [self.tableView frame];
    frame.size.width = 275;
    [self.tableView setFrame:frame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebarshadow"]];
    [shadow setFrame:CGRectMake(118, 0, 160, _tablest.contentSize.height)];
    [self.view addSubview:shadow];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setScrollEnabled:YES];
    UIImageView *sbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebarbg"]];
    [sbg setFrame:CGRectMake(0, 0, 161.5, 480)];
    [self.tableView setBackgroundView:sbg];
    self.view.backgroundColor = [UIColor clearColor];
    _serch.delegate = self;
    UITextField *searchField = [_serch valueForKey:@"searchField"];
    searchField.placeholder = @"Search Torrents";
    objects = [[NSArray alloc] initWithObjects:@"All", @"Audio", @"Video", @"Applications", @"Games", @"Other", nil];
    [self.view.layer setCornerRadius:5.0];
    [self.view.layer setMasksToBounds:YES];
    self.view.layer.opaque = NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Categories";
    } else {
        return @"BayBrowser 1.0.2";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [objects count];
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"pro"]) {
            return 3;
        } else {
            return 3;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor whiteColor];
    if (indexPath.row == 0) {
        AppDelegate *appd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (!appd.authenticated) {
            cell.textLabel.text = @"Login";
        } else {
            cell.textLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        }
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"Feedback/Bugs";
    }
    if (indexPath.row == 2) {
        cell.textLabel.text = @"About";
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = [objects objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            appDelegate.payPressed = YES;
            [appDelegate.deckController toggleLeftView];
        } else if (indexPath.row == 0) {
            if (!appDelegate.authenticated) {
                LoginView *login = (LoginView *)[self.storyboard instantiateViewControllerWithIdentifier:@"login"];
                [self presentViewController:login animated:YES completion:nil];
            }
        } else {
            NSString *aboutMessage = @"Created by Ethan Arbuckle\n\nThanks to:\nStig Brautaset (JSON)\nSam Vermette\nMarcus Kida\n Jason Morrissey\nKyle Morris\n\nBuild Date: May/16/13";
            UIAlertView *about = [[UIAlertView alloc] initWithTitle:@"BayBrowser 1.0.2" message:aboutMessage delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [about show];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        appDelegate.more = NO;
        appDelegate.reload = YES;
        if (indexPath.row == 0) {
            appDelegate.URL = [NSMutableString stringWithFormat:@"http://apify.ifc0nfig.com/tpb/top?id=all"];
            appDelegate.QUERY = [NSMutableString stringWithFormat:@""];
            appDelegate.label = [NSMutableString stringWithFormat:@"Top 100"];
        } else if (indexPath.row == 1) {
            appDelegate.URL = [NSMutableString stringWithFormat:@"http://apify.ifc0nfig.com/tpb/top?id=100/"];
            appDelegate.QUERY = [NSMutableString stringWithFormat:@""];
            appDelegate.label = [NSMutableString stringWithFormat:@"Top Songs"];
        } else if (indexPath.row == 2) {
            appDelegate.URL = [NSMutableString stringWithFormat:@"http://apify.ifc0nfig.com/tpb/top?id=200/"];
            appDelegate.QUERY = [NSMutableString stringWithFormat:@""];
            appDelegate.label = [NSMutableString stringWithFormat:@"Top Videos"];
        } else if (indexPath.row == 3) {
            appDelegate.URL = [NSMutableString stringWithFormat:@"http://apify.ifc0nfig.com/tpb/top?id=300/"];
            appDelegate.QUERY = [NSMutableString stringWithFormat:@""];
            appDelegate.label = [NSMutableString stringWithFormat:@"Top Applications"];
        } else if (indexPath.row == 4) {
            appDelegate.URL = [NSMutableString stringWithFormat:@"http://apify.ifc0nfig.com/tpb/top?id=400/"];
            appDelegate.QUERY = [NSMutableString stringWithFormat:@""];
            appDelegate.label = [NSMutableString stringWithFormat:@"Top Games"];
        } else if (indexPath.row == 5) {
            appDelegate.URL = [NSMutableString stringWithFormat:@"http://apify.ifc0nfig.com/tpb/top?id=600/"];
            appDelegate.QUERY = [NSMutableString stringWithFormat:@""];
            appDelegate.label = [NSMutableString stringWithFormat:@"Top Other"];
        } else {
        }
        [appDelegate.deckController toggleLeftView];
    }
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.more = YES;
    appDelegate.QUERY = [NSMutableString stringWithFormat:@"%@", searchBar.text];
    appDelegate.URL = [NSMutableString stringWithFormat:@"http://apify.ifc0nfig.com/tpb/search?id="];
    appDelegate.label = [NSMutableString stringWithFormat:@"Results For: %@", appDelegate.QUERY];
    appDelegate.reload = YES;
    [appDelegate.deckController toggleLeftView];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    searchBar.text = @"";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:@"side" bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshTable {
    [_tablest reloadData];
}

@end
