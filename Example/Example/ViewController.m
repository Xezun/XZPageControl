//
//  ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "ViewController.h"
@import XZPageControl;
@import XZPageView;
@import SDWebImage;

@interface ViewController () <XZPageViewDelegate, XZPageViewDataSource>
@property (weak, nonatomic) IBOutlet XZPageView *pageView;
@property (weak, nonatomic) IBOutlet XZPageControl *pageControl;

@property (nonatomic, copy) NSArray *imageURLs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageURLs = @[
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/df38e2b4-31bb-447f-9987-ce04368696c5.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/3b1ef5df-f143-44dd-9d36-c93867b2529c.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/108363a8-ff04-4784-9640-981183e81066.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/4677eadf-99bf-4112-8bc6-68a487a427eb.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/dd138b93-a114-4c27-b96d-e9853319907f.jpg"]
    ];
    
    self.pageView.isLoopable = YES;
    self.pageView.autoPagingInterval = 5.0;
    
    self.pageControl.indicatorFillColor = UIColor.whiteColor;
    self.pageControl.indicatorStrokeColor = UIColor.whiteColor;
    self.pageControl.currentIndicatorFillColor = [UIColor colorWithRed:0xbf/255.0 green:0x0f/255.0 blue:0x1f/255.0 alpha:1.0];
    self.pageControl.currentIndicatorStrokeColor = [UIColor colorWithRed:0xbf/255.0 green:0x0f/255.0 blue:0x1f/255.0 alpha:1.0];
    self.pageControl.currentIndicatorShape = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(8, 12.0, 14.0, 6.0) cornerRadius:3.0];
    
    self.pageView.delegate = self;
    self.pageView.dataSource = self;
    
    self.pageControl.numberOfPages = self.imageURLs.count;
    [self.pageControl addTarget:self action:@selector(pageControlDidChangeValue:) forControlEvents:(UIControlEventValueChanged)];
}

- (IBAction)navBarAlignButton:(UIBarButtonItem *)sender {
    switch (self.pageControl.contentMode) {
        case UIViewContentModeLeft:
            self.pageControl.contentMode = UIViewContentModeRight;
            [sender setImage:[UIImage systemImageNamed:@"align.horizontal.right"]];
            break;
        case UIViewContentModeRight:
            self.pageControl.contentMode = UIViewContentModeCenter;
            [sender setImage:[UIImage systemImageNamed:@"align.horizontal.center"]];
            break;
        default:
            self.pageControl.contentMode = UIViewContentModeLeft;
            [sender setImage:[UIImage systemImageNamed:@"align.horizontal.left"]];
            break;
    }
}

- (NSInteger)numberOfPagesInPageView:(XZPageView *)pageView {
    return self.imageURLs.count;
}

- (UIView *)pageView:(XZPageView *)pageView viewForPageAtIndex:(NSInteger)index reusingView:(UIImageView *)reusingView {
    if (reusingView == nil) {
        reusingView = [[UIImageView alloc] initWithFrame:pageView.bounds];
    }
    [reusingView sd_setImageWithURL:self.imageURLs[index]];
    return reusingView;
}

- (nullable UIView *)pageView:(XZPageView *)pageView prepareForReusingView:(UIImageView *)reusingView {
    reusingView.image = nil;
    return reusingView;
}

- (void)pageView:(XZPageView *)pageView didPageToIndex:(NSInteger)index {
    NSLog(@"didPageToIndex: %ld", index);
    self.pageControl.currentPage = index;
}

- (void)pageControlDidChangeValue:(XZPageControl *)pageControl {
    [self.pageView setCurrentPage:pageControl.currentPage animated:YES];
}

@end
