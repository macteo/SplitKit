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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
