//
//  ViewController.m
//  SplitKit Example
//
//  Created by Matteo Gavagnin on 03/09/2017.
//  Copyright © 2017 Dolomate. All rights reserved.
//

#import "ViewController.h"

@import SplitKit;

@interface ViewController ()
@property(nonatomic, retain) DOLSplitKitViewController *splitController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _splitController = [[DOLSplitKitViewController alloc] init];
    [self addChildViewController:_splitController];
    _splitController.view.frame = self.view.bounds;
    _splitController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_splitController.view];
    [_splitController didMoveToParentViewController:self];
    _splitController.splitDisposition = DOLSplitKitDispositionHorizontal;
    
    DOLSplitKitViewController *secondSplitController = [[DOLSplitKitViewController alloc] init];
    _splitController.secondChild = secondSplitController;
    secondSplitController.splitDisposition = DOLSplitKitDispositionVertical;
    
    DOLSplitKitViewController *thirdSplitController = [[DOLSplitKitViewController alloc] init];
    secondSplitController.firstChild = thirdSplitController;
    thirdSplitController.splitDisposition = DOLSplitKitDispositionHorizontal;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
