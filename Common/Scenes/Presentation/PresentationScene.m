//
//  GameScene.m
//  Sorcery
//
//  Created by Dominique Normand on 1/4/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#include <stdlib.h>

#import "GameContext.h"
#import "PresentationScene.h"
#import "GameScene.h"
#import "HiScoresScene.h"
#import "SpriteHelper.h"
#import "SoundManager.h"

#if !TARGET_OS_IPHONE

#include <Carbon/Carbon.h>

#endif

@implementation PresentationScene

-(instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.backgroundColor = [SKColor blackColor];
    return self;
}

-(void)didMoveToView:(SKView *)view
{
	[GameContext preLoad];
	
    int width  = (int)CGRectGetWidth(self.frame);
    
	SKSpriteNode*	sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Presentation"];
	
    sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    [self addChild:sprite];
    
	SKSpriteNode* fire1 = [SKSpriteNode createAnimatedSprite:@"Fire" withAtlas:@"Animations" andKey:@"default"];
    SKSpriteNode* fire2 = [fire1 copy];
    SKSpriteNode* fire3 = [fire1 copy];
	
	fire1.position = CGPointMake(31, 156);
	fire2.position = CGPointMake(160, 140);
	fire3.position = CGPointMake(288, 156);
	
    [self addChild:fire1];
    [self addChild:fire2];
    [self addChild:fire3];
    
    NSString* text = @"^YSORCERY     COPYRIGHT 1985 VIRGIN GAMES LTD.                    PROGRAMMED BY THE GANG OF FIVE.                 CAN YOU RESCUE ALL OF YOUR FELLOW SORCERERS FROM CERTAIN DOOM AT THE HANDS OF THE EVIL FORCES !                 TAP THE SCREEN TO PLAY.";

    SKNode*  myLabel = [SKNode createLabel:text];
    CGRect   rect = myLabel.calculateAccumulatedFrame;
    
	myLabel.position = CGPointMake(330, 27);
    [self addChild:myLabel];
    
    float targetX = -CGRectGetWidth(rect) - 10;
    
    NSArray* actions = [NSArray arrayWithObjects:
                [SKAction moveToX:targetX duration:15],
                [SKAction moveToX:width+10 duration:0],
                nil];

	SKAction* scroll = /*[SKAction repeatActionForever:*/[SKAction sequence:actions]; //];
	
    [myLabel runAction:scroll completion:^{ [self showHighScores]; }];
    
    if (! [[SoundManager sharedManager] isPlayingMusic])
        [[SoundManager sharedManager] playMusic:@"Musique.mp3" looping:YES fadeIn:NO];
}

-(int)getStartRoom
{
	int value = arc4random_uniform(7);
	switch (value)
	{
		case 0:
		case 1:
		case 2:
		case 3:
			return 4;
		case 4:
			return 0;
		case 5:
			return 16;
		default:
			return 33;
	}
}

-(void)startGame
{
	GameContext* context = [GameContext sharedContext];
	
	if (context.ready)
	{
		[[SoundManager sharedManager] stopMusic:NO];
		
		GameEngine* engine = [GameEngine createWithRoom:[self getStartRoom]];
		GameScene*	scene  = [GameScene sceneWithEngine:engine];
		
		SKTransition* transition = [SKTransition crossFadeWithDuration:0.5f];
		[self.view presentScene:scene transition:transition];
		[self.view presentScene:scene];
	}
}

#if TARGET_OS_IPHONE

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self startGame];
}

#else

-(void)keyDown:(NSEvent *)theEvent
{
	if (theEvent.keyCode == kVK_Space)
		[self startGame];
}

#endif

-(void)showHighScores
{
    HiScoresScene *scene = [HiScoresScene sceneWithSize:CGSizeMake(320, 200)];
    
	SKTransition* transition = [SKTransition crossFadeWithDuration:0.5f];
    [self.view presentScene:scene transition:transition];
}

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}
@end
