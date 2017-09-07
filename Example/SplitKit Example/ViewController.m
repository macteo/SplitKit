//
//  ViewController.m
//  SplitKit Example
//
//  Created by Matteo Gavagnin on 03/09/2017.
//  Copyright © 2017 Dolomate. All rights reserved.
//

#import "ViewController.h"
#import "SplitKit_Example-Swift.h"

@import SplitKit;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DOLSplitKitViewController *splitController = [[DOLSplitKitViewController alloc] init];
    [self addChildViewController:splitController];
    splitController.view.frame = self.view.bounds;
    splitController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:splitController.view];
    [splitController didMoveToParentViewController:self];
    splitController.splitDisposition = DOLSplitKitDispositionHorizontal;
    
    DOLSplitKitViewController *secondSplitController = [[DOLSplitKitViewController alloc] init];
    splitController.secondChild = secondSplitController;
    secondSplitController.splitDisposition = DOLSplitKitDispositionVertical;
    
    DOLSplitKitViewController *thirdSplitController = [[DOLSplitKitViewController alloc] init];
    secondSplitController.firstChild = thirdSplitController;
    thirdSplitController.splitDisposition = DOLSplitKitDispositionHorizontal;
    
    splitController.firstChild = [[ImageViewController alloc] init];
    thirdSplitController.firstChild = [[ImageViewController alloc] init];
    thirdSplitController.secondChild = [[ImageViewController alloc] init];
    secondSplitController.secondChild = [[ImageViewController alloc] init];
}

@end
