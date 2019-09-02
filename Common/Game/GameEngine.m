//
//  GameContext.m
//  Sorcery
//
//  Created by Dominique Normand on 1/12/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "SpriteHelper.h"
#import "allObjects.h"
#import "GameScene.h"

@implementation GameEngine

static GameEngine*	_sharedEngine = nil;

+(instancetype)sharedEngine
{
	return _sharedEngine;
}

+(void)setSharedEngine:(GameEngine*)engine
{
	_sharedEngine = engine;
}

-(instancetype)initWithRoom:(int)roomIndex
{
    self = [super init];
	
	self.room				= [[GameContext sharedContext] getRoom:roomIndex];
	self.wizard				= [Wizard createWithPosition:CGPointMake(172, 138)];	
	self.informationPanel	= [InformationPanel create];
	
	self.informationPanel.roomName	= self.room.name;
	self.informationPanel.roomId	= self.room.id;
	self.informationPanel.score		= 0 ;

	self.energy = 99.0f;
	
    return self;
}

+(instancetype)createWithRoom:(int)roomIndex
{
	return [[GameEngine alloc] initWithRoom:roomIndex];
}

-(int)score
{
	return self.informationPanel.score;
}

-(void)setScore:(int)score
{
	self.informationPanel.score = score;
}

-(float)energy
{
	return self.wizard.energy;
}

-(void)setEnergy:(float)energy
{
	if (energy > 99.0f)
		energy = 99.0f;
	else if (energy < 0.0f)
		energy = 0.0f;
	
	self.wizard.energy = energy;
	self.informationPanel.energy = energy;
}

-(StaticObjectType)carrying
{
	return self.wizard.carrying;
}

-(void)setCarrying:(StaticObjectType)carrying
{
	self.wizard.carrying = carrying;
	self.informationPanel.carrying = carrying;
}

-(void)goThroughDoor:(Door*)door withScene:(SKScene*)scene andCallback:(void (^)(void))block;
{
	GameScene* gameScene = (GameScene*)scene;
	
	StaticObjectType key = self.carrying;
	
	if (door.key != Nothing && key == door.key)
	{
		door.key = Nothing; // Mark as not locked
		self.carrying = Nothing;
	}
	
	if (door.key != Nothing) // Door is Locked ?
	{
		if (block != nil)
			block();
	}
	else
	{
		[door OpenAndMoveWizard:self.wizard completion:^{
			if (door.type == GreenDoor || door.type == TrapDoor)
			{
				if (block != nil)
					block();
			}
			else if (door.nextRoom != self.room.id)
			{
				// Remove Old Room
				[self.room removeFromScene:scene];
				// Get new Room
				self.room = [[GameContext sharedContext] getRoom:(int)door.nextRoom];
				
				// Mark next door as animated - needs to be done before adding room to the scene
				Door* nextDoor = [self.room.doors objectAtIndex:(int)door.nextDoor];
				nextDoor.animate = YES;
				
				// Add new Room to scene
				[self.room addToScene:scene withGame:gameScene.game];
				
				// Update room information
				self.informationPanel.roomId   = self.room.id;
				self.informationPanel.roomName = self.room.name;
				
				if (nextDoor.key != Nothing && nextDoor.key == key)
					nextDoor.key = Nothing;
				
				if (block != nil)
					block();
			}
			else
			{
				Door* nextDoor = [self.room.doors objectAtIndex:(int)door.nextDoor];
				nextDoor.animate = YES;
				
				[nextDoor CloseAndMoveWizard:self.wizard];
				[door CloseDoor];
				
				if (nextDoor.key != Nothing && nextDoor.key == key)
					nextDoor.key = Nothing;
				
				if (block != nil)
					block();
			}
		}];
	}
}


-(void)addToScene:(SKScene*)scene
{
	[self.informationPanel addToScene:scene withGame:self];
	[self.wizard addToScene:scene withGame:self];	
	[self.room addToScene:scene withGame:self];
}

-(void)removeFromScene:(SKScene *)scene
{
	[self.room removeFromScene:scene];
}

-(void)update:(CFTimeInterval)currentTime
{
	for (Character* obj in self.room.characters)
	{
		[obj update:currentTime withGame:self];
	}
	
	self.informationPanel.energy	= self.wizard.energy;
	self.informationPanel.carrying	= self.wizard.carrying;
	
	[self.wizard update:currentTime withGame:self];
}

-(void)pick:(StaticObject*)object
{
	StaticObjectType newType = object.type;
	StaticObjectType oldType = self.carrying;
	
	if (object.value > 0)
	{
		self.score += object.value;
		object.value = 0;
	}
	
	if (newType == oldType)
		return;

	self.carrying = newType;
	object.type = oldType;
	
}

-(void)kill:(Character*)character withScore:(int)score
{
	if (character.killer == Nothing)
	{
		[character killWithScore:score];
	}
	else if (self.carrying == character.killer)
	{
		self.carrying = Nothing;
		[character killWithScore:score];
	}
}

@end
