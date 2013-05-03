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

@interface detailsView ()

@end

@implementation detailsView
@synthesize text;

- (void)viewDidLoad
{
    [super viewDidLoad];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        _textString = [self getDescription:_URL];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            text.text = _textString;
        });
    });
}

- (IBAction)close:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (NSString *)getDescription:(NSString*)urlstring {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:urlstring];
    NSData *data = [NSData dataWithContentsOfURL:url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    NSString *path = @"//div[@id='content']/div[@id='main-content']/div/div[@id='detailsouterframe']/div[@id='detailsframe']/div[@id='details']/div[@class='nfo']/pre/text()";
    NSArray *nodes = [parser searchWithXPathQuery:path];
    NSMutableString *texts = [[NSMutableString alloc] init];
    for (TFHppleElement *element in nodes) {
        NSString *postid = [element content];
        [texts appendString:postid];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return texts;
}
@end
