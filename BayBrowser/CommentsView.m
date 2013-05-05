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

@interface CommentsView ()

@end

@implementation CommentsView

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getComments];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)getComments {
    NSString *torrentURL = @"http://thepiratebay.sx/torrent/6126873";
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:torrentURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *parser = [TFHpple hppleWithHTMLData:data];
        NSArray *nodes = [parser searchWithXPathQuery:@"//div[@id='comments']/div"];
        for (TFHppleElement *element in nodes) {
        }
        

    } failure:nil];
    [operation start];
}

@end
