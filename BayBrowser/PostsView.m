//
//  PostsView.m
//  BayBrowser
//
//  Created by Ethan Arbuckle on 3/23/13.
//
//

#import "PostsView.h"
#import "CustomCell.h"
#import "JSON.h"
#import "JMTabView.h"
#import "JMSlider.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Hex.h"
#import "TFHpple.h"
#import "detailsView.h"

@interface PostsView ()
@end

BOOL firstone = TRUE;
BOOL themecolorlight;

@implementation PostsView

@synthesize posts, arrayposts, theTable, seeders, size, uplo, tabView, ids, leechers;

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [theTable setContentOffset:CGPointMake(0, 44) animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGestureRecognizer];
    NSString *dateKey = @"dateKey";
    NSDate *lastRead = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:dateKey];
    if (lastRead == nil) {
        NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], dateKey, nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"theme"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateKey];
    themecolorlight = [[NSUserDefaults standardUserDefaults] boolForKey:@"theme"];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.deckController.delegate = self;
    theTable.delegate = self;
    theTable.dataSource = self;
    self.view.backgroundColor = [UIColor clearColor];
    [self.view.layer setCornerRadius:5];
    [self.view.layer setMasksToBounds:YES];
    self.view.layer.opaque = NO;
    arrayposts = [[NSMutableArray alloc] init];
    seeders = [[NSMutableArray alloc] init];
    size = [[NSMutableArray alloc] init];
    uplo = [[NSMutableArray alloc] init];
    ids = [[NSMutableArray alloc] init];
    leechers = [[NSMutableArray alloc] init];
    tabView = [[JMTabView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [tabView setDelegate:self];
    [tabView addTabItemWithTitle:@"SE" icon:nil];
    [tabView addTabItemWithTitle:@"LE" icon:nil];
    [tabView addTabItemWithTitle:@"Type" icon:nil];
    [self.view addSubview:tabView];
    [tabView setSelectedIndex:0];
    [theTable setTableHeaderView:tabView];
    [self first];
    buttonData = [NSArray arrayWithObjects:
                  [NSDictionary dictionaryWithObjectsAndKeys:@"copy", @"title", @"paperclip.png", @"image", nil],
                  [NSDictionary dictionaryWithObjectsAndKeys:@"safari", @"title", @"safari.png", @"image", nil],
                  [NSDictionary dictionaryWithObjectsAndKeys:@"hide", @"title", @"hide.png", @"image", nil],
                  [NSDictionary dictionaryWithObjectsAndKeys:@"action", @"title", @"action.png", @"image", nil],
                  nil];
    buttons = [[NSMutableArray alloc] initWithCapacity:[buttonData count]];
    appDelegate.URL = [NSMutableString stringWithFormat:@"http://apify.ifc0nfig.com/tpb/top?/"];
    appDelegate.label = [NSMutableString stringWithFormat:@"Top Torrents"];
    [self changeTheme];
    [self setupSideSwipeView];
    [TestFlight passCheckpoint:@"Finished launch"];
}

- (void)tabView:(JMTabView *)tabView didSelectTabAtIndex:(NSUInteger)itemIndex {
    if (!appDelegate.loadingSomething) {
        [self sortBy:(NSInteger *)itemIndex];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([arrayposts count] < 1) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayposts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"CustomCell";
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (themecolorlight) {
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.seederslabel.textColor = [UIColor colorWithHex:0x903532];
        cell.sizeLabel.textColor = [UIColor colorWithHex:0x903532];
        cell.uploadedLabel.textColor = [UIColor colorWithHex:0x903532];
    } else {
        cell.titleLabel.textColor = [UIColor whiteColor];
        cell.seederslabel.textColor = [UIColor colorWithHex:0x008FF3];
        cell.sizeLabel.textColor = [UIColor colorWithHex:0x008FF3];
        cell.uploadedLabel.textColor = [UIColor colorWithHex:0x008FF3];
    }
    cell.descriptionButton.tag = [indexPath row];
    [cell.descriptionButton addTarget:self action:@selector(buttonCellClicked:) forControlEvents:UIControlEventTouchUpInside];
    if ([arrayposts count] > 0) {
        NSMutableString *svalue = [[NSMutableString alloc] init];
        NSMutableString *lvalue = [[NSMutableString alloc] init];
        if ([[seeders objectAtIndex:indexPath.row] intValue] > 999) {
            unsigned long long value = 1700llu;
            NSUInteger index = 0;
            double dvalue = (double)[[seeders objectAtIndex:indexPath.row] doubleValue];
            NSArray *suffix = @[ @"", @"k", @"M", @"G", @"T", @"P", @"E" ];
            while ((value /= 1000) && ++index) dvalue /= 1000;
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setMaximumFractionDigits:(int)(dvalue < 100.0 && ((unsigned)((dvalue - (unsigned)dvalue) * 10) > 0))];
            svalue = [NSMutableString stringWithFormat:@"%@", [[formatter stringFromNumber:[NSNumber numberWithFloat:dvalue]]
                                                               stringByAppendingString:[suffix objectAtIndex:index]]];
        } else {
            svalue = [seeders objectAtIndex:indexPath.row];
        }
        if ([[leechers objectAtIndex:indexPath.row] intValue] > 999) {
            unsigned long long value = 1700llu;
            NSUInteger index = 0;
            double dvalue = (double)[[leechers objectAtIndex:indexPath.row] doubleValue];
            NSArray *suffix = @[ @"", @"k", @"M", @"G", @"T", @"P", @"E" ];
            while ((value /= 1000) && ++index) dvalue /= 1000;
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setMaximumFractionDigits:(int)(dvalue < 100.0 && ((unsigned)((dvalue - (unsigned)dvalue) * 10) > 0))];
            lvalue = [NSMutableString stringWithFormat:@"%@", [[formatter stringFromNumber:[NSNumber numberWithFloat:dvalue]]
                                                               stringByAppendingString:[suffix objectAtIndex:index]]];
        } else {
            lvalue = [leechers objectAtIndex:indexPath.row];
        }
        cell.titleLabel.text = [arrayposts objectAtIndex:indexPath.row];
        cell.seederslabel.text = [NSString stringWithFormat:@"SE: %@ - LE: %@", svalue, lvalue];
        cell.sizeLabel.text = [NSString stringWithFormat:@"%@", [size objectAtIndex:indexPath.row]];
        cell.uploadedLabel.text = [NSString stringWithFormat:@"Uploaded: %@", [uplo objectAtIndex:indexPath.row]];
    } else {
        [TestFlight passCheckpoint:@"Avoided crash! Woot!!"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 78;
}

- (void)first {
    appDelegate.loadingSomething = YES;
    [self setStatus:@"Loading..."];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor darkGrayColor];
    [theTable setTableFooterView:v];
    [theTable reloadData];
    CGRect sliderFrame = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2, 0, 0);
    JMSlider *slider = [JMSlider sliderWithFrame:sliderFrame centerTitle:@"more" leftTitle:nil rightTitle:nil delegate:self];
    [slider setLoading:YES];
    [self.view addSubview:slider];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *url = [NSString stringWithFormat:@"http://apify.ifc0nfig.com/tpb/top?id=all"];
        appDelegate.QUERY = [NSMutableString stringWithFormat:@"http://apify.ifc0nfig.com/tpb/top?id=all"];
        NSString *search = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url2 = [NSURL URLWithString:search];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *json = [NSString stringWithContentsOfURL:url2 encoding:NSUTF8StringEncoding error:nil];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *loaded = [parser objectWithString:json];
        for (NSDictionary *current in loaded) {
            [arrayposts addObject:[current objectForKey:@"name"]];
            [seeders addObject:[current objectForKey:@"seeders"]];
            [size addObject:[current objectForKey:@"size"]];
            [uplo addObject:[current objectForKey:@"uploaded"]];
            [ids addObject:[current objectForKey:@"id"]];
            [leechers addObject:[current objectForKey:@"leechers"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            appDelegate.loadingSomething = NO;
            [slider setLoading:NO];
            slider.hidden = YES;
            CGRect sliderFrame2 = CGRectMake(0, 0, 320, 78);
            JMSlider *slider2 = [JMSlider sliderWithFrame:sliderFrame2 centerTitle:@"more" leftTitle:nil rightTitle:nil delegate:self];
            if (appDelegate.more) {
                [slider2 setCenterExecuteBlock:^{
                    [slider2 setLoading:YES];
                    [self removeSideSwipeView:YES];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        appDelegate.loadingSomething = YES;
                        appDelegate.page++;
                        NSString *unformat = [NSString stringWithFormat:@"%@%@", appDelegate.URL, appDelegate.QUERY];
                        NSString *search = [unformat stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        NSURL *url = [NSURL URLWithString:search];
                        NSString *json = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                        SBJsonParser *parser = [[SBJsonParser alloc] init];
                        NSDictionary *loaded = [parser objectWithString:json];
                        for (NSDictionary * current in loaded) {
                            [arrayposts addObject:[current objectForKey:@"name"]];
                            [seeders addObject:[current objectForKey:@"seeders"]];
                            [size addObject:[current objectForKey:@"size"]];
                            [uplo addObject:[current objectForKey:@"uploaded"]];
                            [ids addObject:[current objectForKey:@"id"]];
                            [leechers addObject:[current objectForKey:@"leechers"]];
                        }
                        NSArray *copy = [arrayposts copy];
                        NSInteger index = [copy count] - 1;
                        for (id object in [copy reverseObjectEnumerator]) {
                            if ([arrayposts indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
                                [arrayposts removeObjectAtIndex:index];
                                [seeders removeObjectAtIndex:index];
                                [size removeObjectAtIndex:index];
                                [uplo removeObjectAtIndex:index];
                                [leechers removeObjectAtIndex:index];
                                [ids removeObjectAtIndex:index];
                            }
                            index--;
                        }
                        appDelegate.loadingSomething = NO;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [slider2 setLoading:NO];
                            [theTable reloadData];
                        });
                    });
                }];
            }
            if (appDelegate.more) {
                [theTable setTableFooterView:slider2];
                [theTable setCanCancelContentTouches:NO];
            }
            [theTable reloadData];
            [theTable setContentOffset:CGPointMake(0, 44) animated:YES];
        });
    });
    [TestFlight passCheckpoint:@"Loaded Info"];
}

- (void)sortBy:(NSInteger *)index {
    [appDelegate.deckController.leftController.view endEditing:YES];
    [self.view endEditing:YES];
    [self performSelectorOnMainThread:@selector(removeSideSwipeView:) withObject:nil waitUntilDone:YES];
    [self setStatus:@"Loading..."];
    appDelegate.loadingSomething = YES;
    [tabView setSelectedIndex:(int)index];
    [arrayposts removeAllObjects];
    [seeders removeAllObjects];
    [size removeAllObjects];
    [ids removeAllObjects];
    [leechers removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableString *url;
        if ((int)index == 0) {
            url = [NSMutableString stringWithFormat:@"%@%@/0/7/0", appDelegate.URL, appDelegate.QUERY];
        }
        if ((int)index == 1) {
            url = [NSMutableString stringWithFormat:@"%@%@/0/9/0", appDelegate.URL, appDelegate.QUERY];
        }
        if ((int)index == 2) {
            url = [NSMutableString stringWithFormat:@"%@%@/0/13/0", appDelegate.URL, appDelegate.QUERY];
        }
        NSString *search = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url2 = [NSURL URLWithString:search];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *json = [NSString stringWithContentsOfURL:url2 encoding:NSUTF8StringEncoding error:nil];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *loaded = [parser objectWithString:json];
        for (NSDictionary *current in loaded) {
            [arrayposts addObject:[current objectForKey:@"name"]];
            [seeders addObject:[current objectForKey:@"seeders"]];
            [size addObject:[current objectForKey:@"size"]];
            [uplo addObject:[current objectForKey:@"uploaded"]];
            [ids addObject:[current objectForKey:@"id"]];
            [leechers addObject:[current objectForKey:@"leechers"]];
        }
        appDelegate.loadingSomething = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect sliderFrame2 = CGRectMake(0, 0, 320, 78);
            JMSlider *slider2 = [JMSlider sliderWithFrame:sliderFrame2 centerTitle:@"more" leftTitle:nil rightTitle:nil delegate:self];
            if (appDelegate.more) {
                [slider2 setCenterExecuteBlock:^{
                    [slider2 setLoading:YES];
                    [self removeSideSwipeView:YES];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        appDelegate.page++;
                        appDelegate.loadingSomething = YES;
                        NSString *unformat = [NSString stringWithFormat:@"%@%@/%d", appDelegate.URL, appDelegate.QUERY, (int)appDelegate.page];
                        NSString *search = [unformat stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        NSURL *url = [NSURL URLWithString:search];
                        NSString *json = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                        SBJsonParser *parser = [[SBJsonParser alloc] init];
                        NSDictionary *loaded = [parser objectWithString:json];
                        for (NSDictionary * current in loaded) {
                            [arrayposts addObject:[current objectForKey:@"name"]];
                            [seeders addObject:[current objectForKey:@"seeders"]];
                            [size addObject:[current objectForKey:@"size"]];
                            [uplo addObject:[current objectForKey:@"uploaded"]];
                            [ids addObject:[current objectForKey:@"id"]];
                            [leechers addObject:[current objectForKey:@"leechers"]];
                        }
                        NSArray *copy = [arrayposts copy];
                        NSInteger index = [copy count] - 1;
                        for (id object in [copy reverseObjectEnumerator]) {
                            if ([arrayposts indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
                                [arrayposts removeObjectAtIndex:index];
                                [seeders removeObjectAtIndex:index];
                                [size removeObjectAtIndex:index];
                                [uplo removeObjectAtIndex:index];
                                [leechers removeObjectAtIndex:index];
                            }
                            index--;
                        }
                        appDelegate.loadingSomething = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [slider2 setLoading:NO];
                            [theTable reloadData];
                        });
                    });
                }];
            }
            if (appDelegate.more) {
                [theTable setTableFooterView:slider2];
                [theTable setCanCancelContentTouches:NO];
            }
            [self changeTheme];
            [theTable reloadData];
            [theTable setContentOffset:CGPointMake(0, 44) animated:YES];
        });
    });
    [TestFlight passCheckpoint:@"Loaded Info2"];
}

- (void)setupGestureRecognizer {
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(right:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(left:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [theTable addGestureRecognizer:left];
    [theTable addGestureRecognizer:right];
}

- (void)right:(UIGestureRecognizer *)recognizer {
    [self swipe:recognizer direction:UISwipeGestureRecognizerDirectionRight];
}

- (void)left:(UIGestureRecognizer *)recognizer {
    [self swipe:recognizer direction:UISwipeGestureRecognizerDirectionLeft];
}

- (void)swipe:(UIGestureRecognizer *)recognizer direction:(UISwipeGestureRecognizerDirection)direction {
    if (recognizer && recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [recognizer locationInView:theTable];
        NSIndexPath *indexPath = [theTable indexPathForRowAtPoint:location];
        UITableViewCell *cell = [theTable cellForRowAtIndexPath:indexPath];
        if (cell.frame.origin.x != 0 && direction == UISwipeGestureRecognizerDirectionLeft) {
            [self removeSideSwipeView:YES];
            return;
        }
        if (_sideSwipeCell != cell && !_animatingSideSwipeView && direction == UISwipeGestureRecognizerDirectionRight) {
            [self addSwipeViewTo:cell direction:direction];
        }
    }
}

- (void)addSwipeViewTo:(UITableViewCell *)cell direction:(UISwipeGestureRecognizerDirection)direction {
    if (_sideSwipeCell.frame.origin.x != 0) {
        [self performSelectorOnMainThread:@selector(removeSideSwipeView:) withObject:nil waitUntilDone:YES];
    }
    [self setupSideSwipeView];
    _sideSwipeView.frame = cell.frame;
    [theTable insertSubview:_sideSwipeView belowSubview:cell];
    _sideSwipeCell = cell;
    _sideSwipeDirection = &direction;
    CGRect cellFrame = cell.frame;
    _sideSwipeView.frame = CGRectMake(0, cellFrame.origin.y, cellFrame.size.width, cellFrame.size.height);
    _animatingSideSwipeView = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStopAddingSwipeView:finished:context:)];
    cell.frame = CGRectMake(direction = UISwipeGestureRecognizerDirectionRight ? cellFrame.size.width : -cellFrame.size.width, cellFrame.origin.y, cellFrame.size.width, cellFrame.size.height);
    [UIView commitAnimations];
}

- (void)animationDidStopAddingSwipeView:(NSString *)animationID finished:(NSString *)finished context:(void *)context {
    _animatingSideSwipeView = NO;
}

- (void)removeSideSwipeView:(BOOL)animated {
    UITableViewCell *cell = _sideSwipeCell;
    if (!cell) return;
    if (!animated) animated = YES;
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        _animatingSideSwipeView = YES;
        [UIView setAnimationDelegate:self];
        [UIView commitAnimations];
        _animatingSideSwipeView = NO;
    } else {
        [_sideSwipeView removeFromSuperview];
        _sideSwipeCell.frame = CGRectMake(0, _sideSwipeCell.frame.origin.y, _sideSwipeCell.frame.size.width, _sideSwipeCell.frame.size.height);
    }
    usleep(2);
    [_sideSwipeView removeFromSuperview];
    _sideSwipeView = nil;
    _sideSwipeCell = nil;
}

- (void)animationDidStopOne:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    if (_sideSwipeDirection == 0) {
        if (NO) _sideSwipeView.frame = CGRectMake(-_sideSwipeView.frame.size.width + 5.0 * 2, _sideSwipeView.frame.origin.y, _sideSwipeView.frame.size.width, _sideSwipeView.frame.size.height);
        _sideSwipeCell.frame = CGRectMake(5.0 * 2, _sideSwipeCell.frame.origin.y, _sideSwipeCell.frame.size.width, _sideSwipeCell.frame.size.height);
    } else {
        if (NO) _sideSwipeView.frame = CGRectMake(_sideSwipeView.frame.size.width - 5.0 * 2, _sideSwipeView.frame.origin.y, _sideSwipeView.frame.size.width, _sideSwipeView.frame.size.height);
        _sideSwipeCell.frame = CGRectMake(-5.0 * 2, _sideSwipeCell.frame.origin.y, _sideSwipeCell.frame.size.width, _sideSwipeCell.frame.size.height);
    }
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStopTwo:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView commitAnimations];
}

- (void)animationDidStopTwo:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [UIView commitAnimations];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    if (_sideSwipeDirection == 0) {
        if (NO) _sideSwipeView.frame = CGRectMake(-_sideSwipeView.frame.size.width, _sideSwipeView.frame.origin.y, _sideSwipeView.frame.size.width, _sideSwipeView.frame.size.height);
        _sideSwipeCell.frame = CGRectMake(0, _sideSwipeCell.frame.origin.y, _sideSwipeCell.frame.size.width, _sideSwipeCell.frame.size.height);
    } else {
        if (NO) _sideSwipeView.frame = CGRectMake(_sideSwipeView.frame.size.width, _sideSwipeView.frame.origin.y, _sideSwipeView.frame.size.width, _sideSwipeView.frame.size.height);
        _sideSwipeCell.frame = CGRectMake(0, _sideSwipeCell.frame.origin.y, _sideSwipeCell.frame.size.width, _sideSwipeCell.frame.size.height);
    }
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStopThree:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView commitAnimations];
}

- (void)animationDidStopThree:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    _animatingSideSwipeView = NO;
    self.sideSwipeCell = nil;
    [_sideSwipeView removeFromSuperview];
}

- (void)setupSideSwipeView {
    [buttons removeAllObjects];
    self.sideSwipeView = [[UIView alloc] initWithFrame:CGRectMake(theTable.frame.origin.x, 0, theTable.frame.size.width, 78)];
    self.sideSwipeView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted-pattern.png"]];
    UIImage *shadow = [[UIImage imageNamed:@"inner-shadow.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:_sideSwipeView.frame];
    shadowImageView.alpha = .6;
    shadowImageView.image = shadow;
    shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.sideSwipeView addSubview:shadowImageView];
    CGFloat leftEdge = 65;
    for (NSDictionary *button in buttonData) {
        UIButton *buttonPlace = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonPlace.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        UIImage *buttonImage = [UIImage imageNamed:[button objectForKey:@"image"]];
        buttonPlace.frame = CGRectMake(leftEdge, _sideSwipeView.center.y - buttonImage.size.height / 2.0, buttonImage.size.width, buttonImage.size.height);
        UIImage *greyImage = [self imageFilledWith:[UIColor colorWithWhite:0.9 alpha:1.0] using:buttonImage];
        [buttonPlace setImage:greyImage forState:UIControlStateNormal];
        [buttonPlace addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:buttonPlace];
        [self.sideSwipeView addSubview:buttonPlace];
        leftEdge = leftEdge + buttonImage.size.width + 25.0;
    }
}

- (UIImage *)imageFilledWith:(UIColor *)color using:(UIImage *)startImage {
    CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(startImage.CGImage), CGImageGetHeight(startImage.CGImage));
    CGContextRef context = CGBitmapContextCreate(NULL, imageRect.size.width, imageRect.size.height, 8, 0, CGImageGetColorSpace(startImage.CGImage), kCGImageAlphaPremultipliedLast);
    CGContextClipToMask(context, imageRect, startImage.CGImage);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, imageRect);
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newCGImage scale:startImage.scale orientation:startImage.imageOrientation];
    CGContextRelease(context);
    CGImageRelease(newCGImage);
    return newImage;
}

- (IBAction)touchUpInsideAction:(UIButton *)button {
    [TestFlight passCheckpoint:@"Touch on slider"];
    NSIndexPath *indexPath = [theTable indexPathForCell:_sideSwipeCell];
    NSUInteger index = [buttons indexOfObject:button];
    NSDictionary *buttonInfo = [buttonData objectAtIndex:index];
    NSString *badurl = [NSString stringWithFormat:@"http://thepiratebay.se/torrent/%@/%@", [ids objectAtIndex:indexPath.row], [arrayposts objectAtIndex:indexPath.row]];
    NSString *url = [badurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([[buttonInfo objectForKey:@"title"] isEqual:@"action"]) {
        menu = [[UIActionSheet alloc] initWithTitle:@"Share via" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"SMS", nil];
        [menu setTag:indexPath.row];
        [menu showInView:self.view];
    }
    if ([[buttonInfo objectForKey:@"title"] isEqual:@"copy"]) {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = url;
        [self setStatus:@"Copied to Clipboard"];
    }
    if ([[buttonInfo objectForKey:@"title"] isEqual:@"safari"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    if ([[buttonInfo objectForKey:@"title"] isEqual:@"hide"]) {
        NSIndexPath *indexPath = [theTable indexPathForCell:_sideSwipeCell];
        [self performSelectorOnMainThread:@selector(removeSideSwipeView:) withObject:nil waitUntilDone:YES];
        [arrayposts removeObjectAtIndex:indexPath.row];
        [self.theTable beginUpdates];
        NSArray *insertIndexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.theTable deleteRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
        [self.theTable endUpdates];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *badurl = [NSString stringWithFormat:@"http://thepiratebay.se/torrent/%@/%@", [ids objectAtIndex:actionSheet.tag], [arrayposts objectAtIndex:actionSheet.tag]];
    NSString *url = [badurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (buttonIndex == 0) {
        MFMailComposeViewController *email = [[MFMailComposeViewController alloc] init];
        email.mailComposeDelegate = self;
        [email setMessageBody:[NSString stringWithFormat:@"<a href=%@>%@</a>", url, [arrayposts objectAtIndex:actionSheet.tag]] isHTML:YES];
        [self presentViewController:email animated:YES completion:nil];
    }
    if (buttonIndex == 1) {
        MFMessageComposeViewController *sms = [[MFMessageComposeViewController alloc] init];
        sms.messageComposeDelegate = self;
        [sms setBody:url];
        [self presentViewController:sms animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self removeSideSwipeView:YES];
    return indexPath;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeSideSwipeView:YES];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    [self removeSideSwipeView:YES];
    return YES;
}

- (IBAction)showLeft:(id)sender {
    [self.view endEditing:YES];
    [appDelegate.deckController.leftController.view endEditing:YES];
    [appDelegate.deckController toggleLeftView];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    appDelegate.deckController.panningMode = 0;
    if (appDelegate.reload) {
    [self sortBy:0];
    }
    appDelegate.reload = NO;
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    appDelegate.deckController.panningMode = 1;
}

- (void)releaseCell {
    [_sideSwipeView removeFromSuperview];
}

- (void)setStatus:(NSString *)status {
    UINavigationItem *nav = _bar.topItem;
    nav.prompt = status;
    NSTimer *statusNotifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(clearStatus) userInfo:nil repeats:NO];
    [statusNotifyTimer superclass];
}

- (void)clearStatus {
    UINavigationItem *nav = _bar.topItem;
    nav.prompt = nil;
}

- (void)refreshView {
}

- (void)changeTheme {
    if (themecolorlight) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithHex:0x903532];
        label.text = appDelegate.label;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switcharoo)];
        [label addGestureRecognizer:tapGesture];
        self.bar.topItem.titleView = label;
        [label sizeToFit];
        self.theTable.backgroundColor = [UIColor colorWithHex:0xDBDBDB];
        _bar.tintColor = [UIColor colorWithHex:0xd6d6d6];
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switcharoo)];
        [label addGestureRecognizer:tapGesture];
        self.bar.topItem.titleView = label;
        label.text = appDelegate.label;
        [label sizeToFit];
        self.theTable.backgroundColor = [UIColor darkGrayColor];
        _bar.tintColor = [UIColor blackColor];
    }
    [theTable reloadData];
    [self.theTable reloadData];
}

- (void)switcharoo {
    [TestFlight passCheckpoint:@"Theme changed"];
    if (themecolorlight) {
        themecolorlight = FALSE;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"theme"];
    } else {
        themecolorlight = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"theme"];
    }
    [self changeTheme];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getDescription:(NSString*)urlstring {
    NSURL *url = [NSURL URLWithString:urlstring];
    NSData *data = [NSData dataWithContentsOfURL:url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    NSString *path = @"//div[@id='content']/div[@id='main-content']/div/div[@id='detailsouterframe']/div[@id='detailsframe']/div[@id='details']/div[@class='nfo']/pre/text()";
    NSArray *nodes = [parser searchWithXPathQuery:path];
    NSMutableString *text = [[NSMutableString alloc] init];
    for (TFHppleElement *element in nodes) {
        NSString *postid = [element content];
        [text appendString:postid];
    }
    return text;
}

-(IBAction)buttonCellClicked:(id)sender
{
    int h = ((UIButton *) sender).tag;
    NSString *badurl = [NSString stringWithFormat:@"http://thepiratebay.se/torrent/%@/%@", [ids objectAtIndex:(NSInteger)h], [arrayposts objectAtIndex:(NSInteger)h]];
    NSString *url = [badurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    detailsView *next = [self.storyboard instantiateViewControllerWithIdentifier:@"details"];
    [next setURL:url];
    [self presentModalViewController:next animated:YES];
}

@end
