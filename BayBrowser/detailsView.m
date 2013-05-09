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
#import "CommentsView.h"
#import "NSString+HTML.h"

@interface detailsView ()

@end

NSMutableArray *urlsForView;
@implementation detailsView
MBProgressHUD *hud;
@synthesize text, segControl;

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
        text.text = [texts stringByDecodingHTMLEntities];
        CGRect frame = text.frame;
        frame.size.height = frame.size.height + 200;
        text.frame = frame;
        [text updateConstraints];
    } failure:nil];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
            hud.mode = MBProgressHUDModeIndeterminate;
    }];
    [operation start];
    return texts;
}

- (NSMutableArray *) arrayWithImageUrlStrings
{
    return urlsForView;
}

- (UIImage *)placeHolderImageForImagePager {
    return [UIImage imageNamed:@"loadingImage.jpg"];
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image
{
    return UIViewContentModeScaleToFill;
}

- (IBAction)comments:(id)sender {
    CommentsView *currentView = [self.storyboard instantiateViewControllerWithIdentifier:@"comments"];
    [currentView setURL:_URL];
    [self presentViewController:currentView animated:YES completion:nil];
}

- (IBAction)segChange:(id)sender {
    NSLog(@"%d", segControl.selectedSegmentIndex);
}
@end
