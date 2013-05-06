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

@interface CommentsView () {
    NSMutableArray *comments;
}
@end

@implementation CommentsView

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [comments objectAtIndex:indexPath.row];
    return cell;
}

- (void)getComments {
    NSString *torrentURL = @"http://thepiratebay.sx/torrent/8433464";
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:torrentURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *parser = [TFHpple hppleWithHTMLData:data];
        NSArray *nodes = [parser searchWithXPathQuery:@"//div[@id='comments']/div"];
        for (TFHppleElement *element in nodes) {
            NSArray *aarr = [element childrenWithTagName:@"div"];
            for (TFHppleElement *hi in aarr) {
                NSMutableString *plainText = [[NSMutableString alloc] initWithFormat:@"%@",[hi text]];
                if ([plainText length] > 0) {
                    NSArray *claases = [hi childrenWithTagName:@"a"];
                    for (TFHppleElement *link in claases) {
                        [plainText appendString:[NSMutableString stringWithFormat:@"%@", [link text]]];
                    }
                }
                [comments addObject:plainText];
            }
        }
        [_table reloadData];
    } failure:nil];
    [operation start];
}

- (IBAction)done:(id)sender {
#warning Doesnt dismiss anything, set it all to modal. 
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
