//
//  GameViewController.m
//  Sorcery
//
//  Created by Dominique Normand on 1/4/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "GameViewController.h"
#import "PresentationScene.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = [[NSUserDefaults standardUserDefaults] boolForKey:@"fps_preference"];
    skView.showsNodeCount = [[NSUserDefaults standardUserDefaults] boolForKey:@"nodecount_preference"];
	skView.showsPhysics = [[NSUserDefaults standardUserDefaults] boolForKey:@"physics_preference"];

    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    // Create and configure the scene.
    
    PresentationScene *scene = [PresentationScene sceneWithSize:CGSizeMake(320, 200)];
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
