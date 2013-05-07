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
    MBProgressHUD *hud;
}
@end

@implementation CommentsView

- (void)viewDidLoad
{
    [super viewDidLoad];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    _table.dataSource = self;
    _table.delegate = self;
    comments = [[NSMutableArray alloc] init];
    [self getComments];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CommentsCell";
    CommentsCell *cell = (CommentsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.text.text = [[[comments objectAtIndex:indexPath.row] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    return cell;
}

- (void)getComments {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_URL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *parser = [TFHpple hppleWithHTMLData:data];
        NSArray *nodes = [parser searchWithXPathQuery:@"//div[@id='comments']/div"];
        for (TFHppleElement *element in nodes) {
            NSArray *aarr = [element childrenWithTagName:@"div"];
            for (TFHppleElement *hi in aarr) {
                NSMutableString *plainText = [[NSMutableString alloc] initWithFormat:@"%@",[hi text]];
                if ([[plainText stringByReplacingOccurrencesOfString:@" " withString:@""] length] >= 1) {
                    NSArray *claases = [hi childrenWithTagName:@"a"];
                    for (TFHppleElement *link in claases) {
                        [plainText appendString:[NSMutableString stringWithFormat:@" %@", [link text]]];
                    }
                }
                if ([[plainText stringByReplacingOccurrencesOfString:@" " withString:@""] length] >= 2)
                [comments addObject:plainText];
            }
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [_table reloadData];
    } failure:nil];
    [operation start];
}

- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [comments objectAtIndex:indexPath.row];
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:UILineBreakModeWordWrap];
    return size.height+4;
}

@end
