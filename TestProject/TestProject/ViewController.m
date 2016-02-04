//
//  ViewController.m
//  TestProject
//
//  Created by Rogelio Gudino on 2/3/16.
//  Copyright © 2016 Rogelio Gudino. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringWithDefaultValue(@"main-title", nil, [NSBundle mainBundle], @"Main", @"Main’s title.");
}

@end
