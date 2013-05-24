//
//  detailsView.m
//  BayBrowser
//
//  Created by Ethan Arbuckle on 5/2/13.
//
//

#import "detailsView.h"
#import "TFHpple.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "NSString+HTML.h"
#import "CommentsCell.h"
#import "AppDelegate.h"

@interface detailsView () {
    NSMutableArray *comments;
    NSMutableArray *usernames;
    NSMutableArray *commentTimes;
    UILabel *noComments;
}
@end

NSMutableArray *urlsForView;
@implementation detailsView
MBProgressHUD *hud;
@synthesize text, segControl, table;

- (void)viewDidLoad {
    [super viewDidLoad];
    _scoller.delegate = self;
    [_scoller setScrollsToTop:YES];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    urlsForView = [[NSMutableArray alloc] init];
    _pictureView.dataSource = self;
    _pictureView.delegate = self;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    [self getDescription:_URL];
    table.delegate = self;
    table.dataSource = self;
    comments = [[NSMutableArray alloc] init];
    usernames = [[NSMutableArray alloc] init];
    commentTimes = [[NSMutableArray alloc] init];
}

- (IBAction)close:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (NSString *)getDescription:(NSString *)urlstring {
    NSMutableString *texts = [[NSMutableString alloc] init];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *newData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *parser = [TFHpple hppleWithHTMLData:newData];
        NSString *path = @"//pre/text()";
        NSArray *nodes = [parser searchWithXPathQuery:path];
        NSArray *urlArray = [parser searchWithXPathQuery:@"//pre/a"];
        for (TFHppleElement * element in nodes) {
            NSString *postid = [element content];
            if (postid) {
                [texts appendString:postid];
            }
        }
        NSMutableArray *screenshotURLs = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 1; i < urlArray.count; i++) {
            [screenshotURLs addObject:urlArray[i]];
        }
        for (TFHppleElement * element in screenshotURLs) {
            NSString *postid = [element text];
            if (postid) {
                if (([postid rangeOfString:@".png"].location != NSNotFound) || ([postid rangeOfString:@".jpg"].location != NSNotFound)) {
                    NSString *parsed = [postid stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    [urlsForView addObject:parsed];
                }
            }
        }
        _pictureView.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
        _pictureView.pageControl.pageIndicatorTintColor = [UIColor blackColor];
        _pictureView.backgroundColor = [UIColor darkGrayColor];
        [_pictureView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        _textString = texts;
        if ([urlsForView count] < 1) {
            UILabel *pic = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
            pic.text = @"No Images";
            pic.textColor = [UIColor blackColor];
            pic.textAlignment = NSTextAlignmentCenter;
            pic.backgroundColor = [UIColor clearColor];
            pic.center = self.pictureView.center;
            [self.view addSubview:pic];
            [_pictureView removeFromSuperview];
        }
        [table reloadData];
    } failure:nil];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
        hud.mode = MBProgressHUDModeIndeterminate;
    }];
    [operation start];
    return texts;
}

- (NSMutableArray *)arrayWithImageUrlStrings {
    return urlsForView;
}

- (UIImage *)placeHolderImageForImagePager {
    return [UIImage imageNamed:@"loadingImage.jpg"];
}

- (UIViewContentMode)contentModeForImage:(NSUInteger)image {
    return UIViewContentModeScaleToFill;
}

- (IBAction)segChange:(id)sender {
    [noComments removeFromSuperview];
    if (segControl.selectedSegmentIndex == 1) {
        [comments removeAllObjects];
        [commentTimes removeAllObjects];
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        [self getComments];
    }
    else {
        [table reloadData];
    }
    [table setContentOffset:CGPointZero animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (segControl.selectedSegmentIndex == 1) {
        return [usernames count];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (segControl.selectedSegmentIndex == 1) {
        return [NSString stringWithFormat:@"%@", [[usernames objectAtIndex:section] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"CommentsCell";
    CommentsCell *cell = (CommentsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (segControl.selectedSegmentIndex == 1) {
        cell.text.text = [[[comments objectAtIndex:indexPath.section] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    } else {
        NSString *newString = [_textString stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        cell.text.text = [newString stringByConvertingHTMLToPlainText];
    }
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
            table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [table reloadData];
        } else {
            [table reloadData];
            noComments = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
            noComments.text = @"No Comments";
            noComments.textColor = [UIColor blackColor];
            noComments.textAlignment = NSTextAlignmentCenter;
            noComments.backgroundColor = [UIColor clearColor];
            noComments.center = self.table.center;
            [self.view addSubview:noComments];
            table.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
    } failure:nil];
    [operation start];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (segControl.selectedSegmentIndex == 1) {
        NSString *str = [comments objectAtIndex:indexPath.section];
        CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:UILineBreakModeWordWrap];
        return size.height + 6;
    } else {
        CGSize size = [_textString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:UILineBreakModeWordWrap];
        return size.height + 6;
    }
}

- (IBAction)addComment:(id)sender {
    AppDelegate *appd = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appd.authenticated) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Add a Comment" message:@"Type your comment" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
        av.alertViewStyle = UIAlertViewStylePlainTextInput;
        [av textFieldAtIndex:0].delegate = self;
        [av show];
            } else {
        UIAlertView *noLogin = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You need to login to add a comment." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [noLogin show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
        NSString *rawComment = [alertView textFieldAtIndex:0].text;
        NSString *comment = [rawComment stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
        NSURL *url = [NSURL URLWithString:@"http://thepiratebay.sx/"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:comment, @"add_comment", _ID, @"id", nil];
        [httpClient postPath:@"/ajax_post_comment.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        } failure:nil];
    }
}
@end
