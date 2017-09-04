//
//  GameScene.m
//  Sorcery
//
//  Created by Dominique Normand on 1/4/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "GameContext.h"
#import "HiScoresScene.h"
#import "PresentationScene.h"
#import "SpriteHelper.h"

#if !TARGET_OS_IPHONE

#include <Carbon/Carbon.h>

#endif

@implementation HiScoresScene

-(void)addText:(NSString*)text atLine:(int)y
{
	SKNode* node = [SKNode createLabel:text];
	
	CGRect  nodeFrame	= node.calculateAccumulatedFrame;
	CGFloat py			= CGRectGetHeight(self.frame) - CGRectGetHeight(nodeFrame) - (y*16);
	CGFloat px			= (CGRectGetWidth(self.frame) - CGRectGetWidth(nodeFrame)) / 2;

	node.position = CGPointMake(px, py);
	[self addChild:node];
}

-(instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.backgroundColor = [SKColor blackColor];

	[self addText:@"^Ptoday's greatest sorcerers"  atLine:1];
	
	[self addText:@"dave.................^C010000" atLine:3];
	[self addText:@"andy.................^C009000" atLine:4];
	[self addText:@"ian..................^C008000" atLine:5];
	[self addText:@"steve................^C007000" atLine:6];
	[self addText:@"tricia...............^C006000" atLine:7];
	[self addText:@"simon................^C005000" atLine:8];
	[self addText:@"charles..............^C004000" atLine:9];
	
    return self;
}

-(void)didMoveToView:(SKView *)view
{
}

-(void)gotoPresentation
{
	PresentationScene*	scene = [PresentationScene sceneWithSize:CGSizeMake(320, 200)];
	SKTransition*		transition = [SKTransition crossFadeWithDuration:0.5f];
	
	[self.view presentScene:scene transition:transition];
}

#if TARGET_OS_IPHONE

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self gotoPresentation];
}

#else

-(void)keyDown:(NSEvent *)theEvent
{
	if (theEvent.keyCode == kVK_Space)
		[self gotoPresentation];
}

#endif

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end
