//
//  GameScene.m
//  Sorcery
//
//  Created by Dominique Normand on 1/4/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "GameContext.h"
#import "GameScene.h"
#import "PresentationScene.h"
#import "SpriteHelper.h"
#import "allObjects.h"
#import "SoundManager.h"

#if !TARGET_OS_IPHONE

#include <Carbon/Carbon.h>

#endif

@implementation GameScene
{
	BOOL	_movingAway;
	BOOL	_buttonPressed;
	BOOL	_playEnergySound;
	BOOL	_isDead;
	
#if !TARGET_OS_IPHONE
	BOOL	_firePressed;
	BOOL	_upPressed;
	BOOL	_downPressed;
	BOOL	_leftPressed;
	BOOL	_rightPressed;
#endif
}

-(instancetype)initWithSize:(CGSize)size
{
	self = [super initWithSize:size];
	if (self != nil)
	{
		_movingAway = NO;
		_playEnergySound = NO;
		_buttonPressed = NO;
		_isDead = NO;
		
#if !TARGET_OS_IPHONE
		_firePressed = NO;
		_upPressed   = NO;
		_downPressed = NO;
		_leftPressed = NO;
		_rightPressed= NO;
#endif
		
		self.energySound = nil;
		self.scaleMode = SKSceneScaleModeAspectFit;
		self.physicsWorld.gravity = CGVectorMake(0, 0); // No Gravity
		self.physicsWorld.contactDelegate = self;
		self.backgroundColor = [SKColor blackColor];
	}
	return self;
}

-(instancetype)initWithEngine:(GameEngine*) game
{
	self = [self initWithSize:CGSizeMake(320, 200)];
	
	if (self != nil)
	{
		self.room = game.room.id;
		self.game = game;
	}
	return self;
}

+(instancetype)sceneWithEngine:(GameEngine*) game
{
	return [[GameScene alloc] initWithEngine:game];
}

-(void)willMoveFromView:(SKView *)view
{
	Room* room = [[GameContext sharedContext] getRoom:self.room];

	[room unload];	
}

-(void)createJoypad
{
#if TARGET_OS_IPHONE
	
	//	Add Button and Joystick
	
	if (self.joystick == nil)
	{
		self.joystick = [[JCImageJoystick alloc] initWithJoystickImage:(@"joystick-ball.png") baseImage:@"joystick-base.png"];
		[self.joystick setPosition:CGPointMake(self.size.width - 50, 40)];
		// self.joystick.alpha = 0.50f;
		self.joystick.zPosition = 1000;
	
		[self addChild:self.joystick];
	}
	
	if (self.button == nil)
	{
		self.button = [[JCImageButton alloc] initWithNormalImage:@"button" pressedImage:@"button-pressed" isTurbo:NO];
		[self.button setPosition:CGPointMake(50, 40)];
		// self.button.alpha = 0.50f;
		self.button.zPosition = 1000;
		
		[self addChild:self.button];
	}
	
#endif
}

-(void)didMoveToView:(SKView *)view
{
    [self.game addToScene:self];
	[self createJoypad];
}

-(void)handleInput
{
	if (_movingAway || _isDead)
		return ;
		
	CGFloat	offsetX = 0;
	CGFloat offsetY = 0;
	
	const CGFloat speed = 2;
	
#if TARGET_OS_IPHONE
	
	offsetX = roundf(self.joystick.x * speed);
	offsetY = roundf(self.joystick.y * speed);
	
#else

	if (_upPressed && ! _downPressed)
		offsetY = speed;
	else if (_downPressed && ! _upPressed)
		offsetY = -speed;
	
	if (_leftPressed && ! _rightPressed)
		offsetX = -speed;
	else if (_rightPressed && ! _leftPressed)
		offsetX = speed;
	
#endif
	
	if (offsetY == 0)
		offsetY = -1;
	
	[self.game.wizard moveByX:offsetX andY:offsetY];
}

-(void)gotoEndScene
{
	SKScene* scene = [PresentationScene sceneWithSize:CGSizeMake(320, 200)];
	SKTransition* transition = [SKTransition crossFadeWithDuration:0.5f];
	[self.view presentScene:scene transition:transition];
}

-(void)update:(CFTimeInterval)currentTime
{
	[self.game update:currentTime];
	
	_playEnergySound = NO;
	_buttonPressed   = NO;
	
#if TARGET_OS_IPHONE
	_buttonPressed = self.button.wasPressed;
#else
	_buttonPressed = _firePressed;
	_firePressed = NO; // Not a repeat button
#endif
	
	if (! _movingAway && ! _isDead)
	{
		// First the static objects

		if (_buttonPressed)
		{
			// Pickup object has priority on enemies
			
			for (SKPhysicsBody* body in self.game.wizard.sprite.physicsBody.allContactedBodies)
			{
				[self handleStaticObjectCollision:body];
				if (! _buttonPressed) // Button was used ... no need to continue the loop
					break;
			}
		}
		
		// Do other Contacts
		
		for (SKPhysicsBody* body in self.game.wizard.sprite.physicsBody.allContactedBodies)
		{
			[self handleCollision:body];
			if (_movingAway || _isDead)
				break;
		}
		
		if (! _isDead)
		{
			if (self.game.energy == 0)
			{
				_isDead = YES;
				[self.game.wizard die:^{ [self gotoEndScene]; }];
			}
		}
	}
	
	if (_movingAway || _isDead)
		_playEnergySound = NO;
	
	if (_playEnergySound)
	{
		if (self.energySound == nil)
		{
			self.energySound = [Sound soundNamed:@"Tic.wav"];
			self.energySound.volume = 0.5f;
			[self.energySound play];
		}
		if (! self.energySound.isPlaying)
			[self.energySound play];
	}
	else if (self.energySound != nil)
	{
		[self.energySound stop];
	}
	
	[self handleInput];
}

-(void)handleStaticObjectCollision:(SKPhysicsBody*)bodyB
{
	if (! _buttonPressed)
		return;
	
	if (bodyB.categoryBitMask == CategoryStaticObject)
	{
		StaticObject* object = (StaticObject*)[self.game.room objectForNode:bodyB.node];
		if (object == nil)
			return;

		//CGRect rect = CGRectMake(object.position.x-4, object.position.y-4, 8, 8);
		
		//if (CGRectContainsPoint(rect, self.game.wizard.position))
		{
			[self.game pick:object];
			_buttonPressed = NO; // reset button state ... Button can't be used to do 2 things
		}
	}
}

-(void)handleCollision:(SKPhysicsBody*)bodyB
{
	if (bodyB.categoryBitMask & CategoryAnimatedObject)
	{
		AnimatedObject* object = (AnimatedObject*)[self.game.room objectForNode:bodyB.node];
		switch (object.type)
		{
			case Water:
			{
				// Plouf ... Dead
				_isDead = YES;
				self.game.carrying = DrownedInTheRiver;
				[self.game.wizard doPlouf:^{ [self gotoEndScene]; }];
				break;
			}
				
			case Fire:
				// Decrement energy
				self.game.energy -= 0.05;
				_playEnergySound = YES;
				break;
				
			case Cauldron:
				// Increment energy except for evil cauldron
				if (self.game.wizard.position.y > object.position.y &&
					self.game.wizard.position.x >= object.position.x - 12 &&
					self.game.wizard.position.x <= object.position.x + 12)
				{
					if (object.evil)
					{
						_playEnergySound = YES;
						self.game.energy -= 0.2;
					}
					else
					{
						_playEnergySound = YES;
						self.game.energy += 0.2;
					}
				}
				break;
				
			default:
				break;
		}
	}
	else if (bodyB.categoryBitMask & CategoryCharacter)
	{
		Character* character = (Character*)[self.game.room objectForNode:bodyB.node];
		if (character == nil || character.killed)
			return;
		
		if (_buttonPressed && (character.killer == Nothing || character.killer == self.game.carrying))
		{
			[character killWithScore:1000];
			self.game.carrying = Nothing;
			self.game.score += 1000;
			_buttonPressed = NO; // Handle it ... Button can't be used to kill 2 Characters at once
		}
		else
		{
			// Touching enemy ... Decrement energy
			self.game.energy -= 0.1;
			_playEnergySound = YES;
		}
	}
	else if (bodyB.categoryBitMask & CategoryDoor)
	{
		Door* door = (Door*)[self.game.room objectForNode:bodyB.node];
		
		if (door == nil)
			return;
		
		if (! [self.game.wizard canGoThroughDoor:door])
			return;
		
		_movingAway = YES;
		
		SKPhysicsBody* sorcerer = self.game.wizard.sprite.physicsBody;
		
		int old = sorcerer.collisionBitMask;
		sorcerer.collisionBitMask = 0;
		//sorcerer.affectedByGravity = NO;
		[self.game goThroughDoor:door withScene:self andCallback:^{
			sorcerer.collisionBitMask = old;
			//sorcerer.affectedByGravity = YES;
			_movingAway = NO;
		}];
	}
}

#if ! TARGET_OS_IPHONE

-(void)keyDown:(NSEvent *)theEvent
{
	switch (theEvent.keyCode)
	{
		case kVK_Space:
			_firePressed  = YES;
			break;
		case kVK_ANSI_Q:
			_upPressed    = YES;
			break;
		case kVK_ANSI_A:
			_downPressed  = YES;
			break;
		case kVK_ANSI_O:
			_leftPressed  = YES;
			break;
		case kVK_ANSI_P:
			_rightPressed = YES;
			break;
	}
}

-(void)keyUp:(NSEvent *)theEvent
{
	switch (theEvent.keyCode)
	{
		case kVK_Space:
			_firePressed  = NO;
			break;
		case kVK_ANSI_Q:
			_upPressed	  = NO;
			break;
		case kVK_ANSI_A:
			_downPressed  = NO;
			break;
		case kVK_ANSI_O:
			_leftPressed  = NO;
			break;
		case kVK_ANSI_P:
			_rightPressed = NO;
			break;
	}
}

#endif

// ---------- DEBUG STUFF ---------------

-(id)getRoomObject:(NSString*)name forPrefix:(NSString*)prefix
{
	if ([name hasPrefix:prefix])
	{
		NSString*	sid  = [name substringFromIndex:prefix.length];
		NSInteger	id   = [sid integerValue];
		Room*		room = self.game.room;
		
		NSArray*	array;
		
		if ([prefix compare:@"door-"] == NSOrderedSame)
			array = room.doors;
		else if ([prefix compare:@"static-"] == NSOrderedSame)
			array = room.staticObjects;
		else if ([prefix compare:@"character-"] == NSOrderedSame)
			array = room.characters;
		else if ([prefix compare:@"animated-"] == NSOrderedSame)
			array = room.animatedObjects;
		else
			return nil;
		
		return [array objectAtIndex:id];
	}
	else
		return nil;
}

#if TARGET_OS_IPHONE

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	/*
	UITouch*	touch	 = [touches anyObject];
	CGPoint		location = [touch locationInNode:self];
	SKNode*		node	 = [self nodeAtPoint:location];

	if (node != nil && node != self)
	{
		NSLog(@"Tile name = %@", node.name);
		return;
	}
	
	int next = self.game.room.id + 1;
	
	if (next == 48)
	{
		_movingAway = YES;
		SKScene* scene = [PresentationScene sceneWithSize:CGSizeMake(320, 200)];
		SKTransition* transition = [SKTransition crossFadeWithDuration:0.5f];
		[self.view presentScene:scene transition:transition];
	}
	else
	{
		// Remove Old Room
		[self.game.room removeFromScene:self];

		// Get new Room
		self.game.room = [[GameContext sharedContext] getRoom:next];
	
		// Add new Room to scene
		[self.game.room addToScene:self withGame:self.game];
	
		// Update room information
		self.game.informationPanel.roomId   = next;
		self.game.informationPanel.roomName = self.game.room.name;
	}
	*/
	if (_movingAway)
		return;

	UITouch*	touch	 = [touches anyObject];
	CGPoint		location = [touch locationInNode:self];
	SKNode*		node	 = [self nodeAtPoint:location];
	
	if (node != nil)
	{
		id obj = nil;

		if (node == self || [node.name hasPrefix:@"room-"])
		{
			//[self.game.wizard moveTo:location];
		}
		else if ((obj = [self getRoomObject:node.name forPrefix:@"door-"]) != nil)
		{
			_movingAway = YES;
			[self.game goThroughDoor:(Door*)obj withScene:self andCallback:^{
				_movingAway = NO;
			}];
		}
		else if ((obj = [self getRoomObject:node.name forPrefix:@"static-"]) != nil)
		{
			[self.game pick:(StaticObject*)obj];
		}
		else if ((obj = [self getRoomObject:node.name forPrefix:@"character-"]) != nil)
		{
			[self.game kill:(Character*)obj withScore:500];
		}
	}
	
	if (self.room == 47)
	{
		_movingAway = YES;
		SKScene* scene = [PresentationScene sceneWithSize:CGSizeMake(320, 200)];
		SKTransition* transition = [SKTransition crossFadeWithDuration:0.5f];
		[self.view presentScene:scene transition:transition];
	}
}

#endif

@end
