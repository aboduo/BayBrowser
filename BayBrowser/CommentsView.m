//
//  CommentsView.m
//  BayBrowser
//
//  Created by Ethan Arbuckle on 5/4/13.
//
//

#import "CommentsView.h"
#import "TFHpple.h"
#import "AFNetworking.h"
#import "CommentsCell.h"
#import "MBProgressHUD.h"

@interface CommentsView () {
    NSMutableArray *comments;
    NSMutableArray *usernames;
    NSMutableArray *commentTimes;
    MBProgressHUD *hud;
}
@end

@implementation CommentsView

- (void)viewDidLoad {
    [super viewDidLoad];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    _table.dataSource = self;
    _table.delegate = self;
    comments = [[NSMutableArray alloc] init];
    usernames = [[NSMutableArray alloc] init];
    commentTimes = [[NSMutableArray alloc] init];
    [self getComments];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [usernames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@", [[usernames objectAtIndex:section] stringByReplacingOccurrencesOfString:@" " withString:@""]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"CommentsCell";
    CommentsCell *cell = (CommentsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.text.text = [[[comments objectAtIndex:indexPath.section] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    return cell;
}

- (void)getComments {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_URL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *parser = [TFHpple hppleWithHTMLData:data];
        NSArray *nodes = [parser searchWithXPathQuery:@"//div[@id='comments']/div"];
        for (TFHppleElement * element in nodes) {
            NSArray *commentArray = [element childrenWithTagName:@"div"];
            for (TFHppleElement * commentLevtwo in commentArray) {
                NSMutableString *plainText = [[NSMutableString alloc] initWithFormat:@"%@", [commentLevtwo text]];
                if ([[plainText stringByReplacingOccurrencesOfString:@" " withString:@""] length] >= 1) {
                    NSArray *linkArray = [commentLevtwo childrenWithTagName:@"a"];
                    for (TFHppleElement * link in linkArray) {
                        [plainText appendString:[NSMutableString stringWithFormat:@" %@", [link text]]];
                    }
                }
                if ([[plainText stringByReplacingOccurrencesOfString:@" " withString:@""] length] >= 2) [comments addObject:plainText];
            }
            NSArray *usernameArray = [element childrenWithTagName:@"p"];
            for (TFHppleElement * usernamesEle in usernameArray) {
                for (TFHppleElement * usernameLevtwo in [usernamesEle children]) {
                    NSString *usernameText = [usernameLevtwo text];
                    if ([[usernameText stringByReplacingOccurrencesOfString:@" " withString:@""] length] >= 1) {
                        [usernames addObject:usernameText];
                    }
                    if ([[[usernameLevtwo content] stringByReplacingOccurrencesOfString:@" " withString:@""] length] >= 1) {
                        NSString *dateTime = [[usernameLevtwo content] stringByReplacingOccurrencesOfString:@" at " withString:@""];
                        [commentTimes addObject:[dateTime stringByReplacingOccurrencesOfString:@" CET:" withString:@""]];
                    }
                }
            }
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([comments count] > 1) {
            _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [_table reloadData];
        } else {
            UILabel *noComments = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
            noComments.text = @"No Comments";
            noComments.textColor = [UIColor blackColor];
            noComments.textAlignment = NSTextAlignmentCenter;
            noComments.backgroundColor = [UIColor clearColor];
            noComments.center = self.view.center;
            [self.view addSubview:noComments];
        }
    } failure:nil];
    [operation start];
}

- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = [comments objectAtIndex:indexPath.section];
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:UILineBreakModeWordWrap];
    return size.height + 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

@end
