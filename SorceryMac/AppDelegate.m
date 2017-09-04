//
//  AppDelegate.m
//  SorceryMac
//
//  Created by Dominique Normand on 2/27/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "AppDelegate.h"
#import "PresentationScene.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Configure the view.
	SKView * skView = self.skView;
//	skView.showsFPS = [[NSUserDefaults standardUserDefaults] boolForKey:@"fps_preference"];
//	skView.showsNodeCount = [[NSUserDefaults standardUserDefaults] boolForKey:@"nodecount_preference"];
//	skView.showsPhysics = [[NSUserDefaults standardUserDefaults] boolForKey:@"physics_preference"];
	
	/* Sprite Kit applies additional optimizations to improve rendering performance */
	skView.ignoresSiblingOrder = YES;
	// Create and configure the scene.
	
	PresentationScene *scene = [PresentationScene sceneWithSize:CGSizeMake(320, 200)];
	
	[skView presentScene:scene];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
