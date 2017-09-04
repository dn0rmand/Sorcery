//
//  AppDelegate.m
//  Sorcery
//
//  Created by Dominique Normand on 1/4/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "SoundManager.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
{
	BOOL _wasPlayingMusic;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[Fabric with:@[CrashlyticsKit]];
	_wasPlayingMusic = NO;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	SoundManager* sound = [SoundManager sharedManager];
	
	_wasPlayingMusic = sound.isPlayingMusic;
	
	[[SoundManager sharedManager] stopAllSounds:YES];
	[[SoundManager sharedManager] pauseMusic];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	if (_wasPlayingMusic)
	{
		_wasPlayingMusic = NO;
		[[SoundManager sharedManager] resumeMusic];
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
