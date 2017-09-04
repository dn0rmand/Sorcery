//
//  GameContext.m
//  Sorcery
//
//  Created by Dominique Normand on 1/12/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "SpriteHelper.h"
#import "allObjects.h"

@implementation Door
{
	CGPoint	_position;
}

-(instancetype)initWithType:(StaticObjectType)type andPosition:(CGPoint)position
{
    self = [super init];
    
    self.position   = position;
    self.type       = type;
    self.key        = Nothing;
    self.nextDoor   = 0;
    self.nextRoom   = 0;
    self.opened     = NO;
    self.sprite     = nil;
	self.id			= 0;
    return self;
}

+(instancetype)createWithType:(NSString*)type andPosition:(CGPoint)position
{
    return [[Door alloc] initWithType:[EnumHelper staticObjectTypeFromString:type] andPosition:position];
}

-(CGPoint)position
{
	return _position;
}

-(void)setPosition:(CGPoint)position
{
	_position = position;
	if (self.sprite != nil)
		self.sprite.position = position;
}

-(SKTexture*)defaultTexture
{
	SKTexture* texture = [SKTexture textureWithName:[EnumHelper staticObjectTypeToString:self.type] andAtlas:@"StaticObjects"];

	return texture;
}

-(void)addToScene:(SKScene*)scene withGame:(GameEngine*)game
{
	if (self.type == GreenDoor || self.type == TrapDoor)
	{
		if (self.opened)
			return; // Don't create anymore
	}
	
    if (self.sprite == nil)
    {
        self.sprite = [SKSpriteNode spriteNodeWithTexture:[self defaultTexture]];
        self.sprite.zPosition = DoorLayer;
		self.sprite.name = [NSString stringWithFormat:@"door-%d", self.id];
		self.sprite.position = self.position;
		if (self.type == TrapDoor)
		{
			CGSize size = CGSizeMake(24, 8);
			CGPoint center = CGPointMake(0, -8);
			
			[self.sprite setPhysicsBodyForCategory:CategoryDoor withSize:size andCenter:center];
		}
		else if (self.type == GreenDoor)
		{
			CGSize	size = CGSizeMake(12, 24);
			CGPoint	center= CGPointMake(0, 0);
			
			[self.sprite setPhysicsBodyForCategory:CategoryDoor withSize:size andCenter:center];
		}
		else
			[self.sprite setPhysicsBodyForCategory:CategoryDoor];
		
        [scene addChild:self.sprite];
		
		[self CloseAndMoveWizard:game.wizard];
    }
}

-(void)removeFromScene:(SKScene*)scene
{
	if (self.sprite != nil)
	{
		[self.sprite removeFromParent];
		self.sprite = nil;
		self.animate = NO;
	}
}

-(void)unload
{
	self.sprite = nil;
	self.animate= NO;
}

-(SKAction*)moveWizardIntoDoor:(Wizard*)wizard
{
	if (wizard == nil || wizard.sprite == nil)
		return nil;
	
	CGPoint			position    = self.position;
	DirectionType	direction;
	
	if (self.type == LeftDoor)
	{
		position.x += 24;
		direction = Left;
	}
	else if (self.type == RightDoor)
	{
		position.x -= 24;
		direction = Right;
	}
	else
		return nil;
	
	wizard.direction = direction;
	wizard.position	 = position;
	
	return [SKAction moveTo:self.position duration:0.2f];
}

-(SKAction*)moveWizardOutOfDoor:(Wizard*)wizard
{
	if (wizard == nil || wizard.sprite == nil)
		return nil;
	
	CGPoint			position	= self.position;
	DirectionType	direction;
	
	if (self.type == LeftDoor)
	{
		position.x += 24;
		direction = Right;
	}
	else if (self.type == RightDoor)
	{
		position.x -= 24;
		direction = Left;
	}
	else
		return nil;
	
	wizard.position  = self.position;
	wizard.direction = direction;
	
	return [SKAction moveTo:position duration:0.2f];
}

-(void)InnerClose:(SKAction*)moveWizard forWizard:(Wizard*)wizard
{
	NSString*	name ;
	
	if (self.type == LeftDoor)
		name = @"CloseLeftDoor";
	else if (self.type == RightDoor)
		name = @"CloseRightDoor";
	else
		name = nil;
	
	if (name != nil)
	{
		NSArray* textures = [SKSpriteNode getTextures:name withAtlas:@"Animations"];
		
		self.sprite.texture = [textures firstObject] ;
		
		SKAction* animation = [SKAction animateWithTextures:textures timePerFrame:0.45f/4 resize:NO restore:NO];
		SKAction* sound		= [SKAction playSoundFileNamed:@"CloseDoor.mp3" waitForCompletion:YES];
		SKAction* doorAction= [SKAction group:@[animation, sound]];
		
		if (moveWizard != nil && wizard != nil && wizard.sprite != nil)
		{
			[wizard.sprite runAction:moveWizard completion:^{
				[self.sprite runAction:doorAction];
			}];
		}
		else
		{
			[self.sprite runAction:doorAction completion:^{ self.sprite.texture = [self defaultTexture]; }];
		}
	}
}

-(void)CloseDoor
{
	[self InnerClose:nil forWizard:nil];
}

-(void)CloseAndMoveWizard:(Wizard*)wizard
{
	if (self.animate)
	{
		self.animate = NO;
		
		SKAction*	moveWizard = [self moveWizardOutOfDoor:wizard];

		[self InnerClose:moveWizard forWizard:wizard];
	}
}

-(void)OpenAndMoveWizard:(Wizard*)wizard completion:(void (^)())block
{
	if (self.sprite == nil)
		return;

	SKAction*	moveWizard = [self moveWizardIntoDoor:wizard];
	NSString*	name ;
	
	if (self.type == LeftDoor)
		name = @"OpenLeftDoor";
	else if (self.type == RightDoor)
		name = @"OpenRightDoor";
	else if (self.type == GreenDoor || self.type == TrapDoor)
	{
		[self.sprite removeFromParent];
		self.sprite = nil;
		self.opened = YES;
		if (block != nil)
			block();
		return;
	}

	SKAction* animation = [SKSpriteNode getAnimation:name withAtlas:@"Animations" speed:0.45f/4 andRestore:NO];
	SKAction* sound		= [SKAction playSoundFileNamed:@"OpenDoor.mp3" waitForCompletion:YES];
	SKAction* action	= [SKAction group:@[animation, sound]];

	void (^completed)();
	
	if (moveWizard != nil && wizard != nil && wizard.sprite != nil)
		completed = ^{ [wizard.sprite runAction:moveWizard completion:block]; };
	else
		completed = block;
	
	[self.sprite runAction:action completion:completed];
}

+(CGPoint)pointWithX:(NSNumber*)x andY:(NSNumber*)y
{
	CGPoint pos = CGPointMake([x floatValue], [y floatValue]);
	return pos;
}

-(NSDictionary*)serialize
{
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	
	[dict setValue:[NSNumber numberWithFloat:self.position.x]	forKey:@"x"];
	[dict setValue:[NSNumber numberWithFloat:self.position.y]	forKey:@"y"];
	[dict setValue:[NSNumber numberWithInteger:self.type]		forKey:@"type"];
	[dict setValue:[NSNumber numberWithInteger:self.key]		forKey:@"key"];
	[dict setValue:[NSNumber numberWithInteger:self.nextRoom]	forKey:@"next-room"];
	[dict setValue:[NSNumber numberWithInteger:self.nextDoor]	forKey:@"next-door"];
	[dict setValue:[NSNumber numberWithBool:self.opened]		forKey:@"opened"];
	
	return dict;
}

+(instancetype)deserialize:(NSDictionary*)dict
{
	NSNumber* x			= (NSNumber*)[dict objectForKey:@"x"];
	NSNumber* y			= (NSNumber*)[dict objectForKey:@"y"];
	NSNumber* type		= (NSNumber*)[dict objectForKey:@"type"];
	NSNumber* key		= (NSNumber*)[dict objectForKey:@"key"];
	NSNumber* nextRoom	= (NSNumber*)[dict objectForKey:@"next-room"];
	NSNumber* nextDoor	= (NSNumber*)[dict objectForKey:@"next-door"];
	NSNumber* opened	= (NSNumber*)[dict objectForKey:@"opened"];
	
	Door* door = [[Door alloc] initWithType:(StaticObjectType)[type integerValue] andPosition:[self pointWithX:x andY:y]];
	
	door.key		= (StaticObjectType)[key integerValue];
	door.nextRoom	= [nextRoom integerValue];
	door.nextDoor	= [nextDoor integerValue];
	door.opened		= [opened boolValue];
	
	if (door.type == GreenDoor)
	{
		CGPoint position = door.position;
		position.x -= 6;
		door.position = position;
	}
	else if (door.type == TrapDoor)
	{
		CGPoint position = door.position;
		position.y += 4;
		door.position = position;
	}
	return door;
}

@end
