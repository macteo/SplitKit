//
//  ViewController.m
//  SplitKit Example
//
//  Created by Matteo Gavagnin on 03/09/2017.
//  Copyright © 2017 Dolomate.
//  See LICENSE file for more details.
//

#import "ViewController.h"
#import "SplitKit_Example-Swift.h"

@import SplitKit;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SPKSplitViewController *splitController = [[SPKSplitViewController alloc] init];
    [self addChildViewController:splitController];
    splitController.view.frame = self.view.bounds;
    splitController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:splitController.view];
    [splitController didMoveToParentViewController:self];
    splitController.arrangement = SPKArrangementHorizontal;
    
    SPKSplitViewController *secondSplitController = [[SPKSplitViewController alloc] init];
    splitController.secondChild = secondSplitController;
    secondSplitController.arrangement = SPKArrangementVertical;
    
    SPKSplitViewController *thirdSplitController = [[SPKSplitViewController alloc] init];
    secondSplitController.firstChild = thirdSplitController;
    thirdSplitController.arrangement = SPKArrangementHorizontal;
    
    splitController.firstChild = [[ImageViewController alloc] init];
    thirdSplitController.firstChild = [[ImageViewController alloc] init];
    thirdSplitController.secondChild = [[ImageViewController alloc] init];
    secondSplitController.secondChild = [[ImageViewController alloc] init];
}

@end
