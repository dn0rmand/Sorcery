//
//  GameContext.m
//  Sorcery
//
//  Created by Dominique Normand on 1/12/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#include <stdlib.h>

#import "SpriteHelper.h"
#import "allObjects.h"

@implementation AnimatedObject
{
	CGPoint				_position;
}

-(instancetype)initWithType:(AnimatedObjectType)type andPosition:(CGPoint)position
{
    self = [super init];
    
    self.position   = position;
	self.type       = type;
    self.sprite     = nil;
    self.evil       = NO;
	self.id			= 0;
    return self;
}

+(instancetype)createWithType:(NSString*)type andPosition:(CGPoint)position
{
    return [[AnimatedObject alloc] initWithType:[EnumHelper animatedObjectTypeFromString:type] andPosition:position];
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

-(void)addToScene:(SKScene*)scene withGame:(GameEngine*)game
{
    if (self.sprite == nil)
    {
		NSString* type = [EnumHelper animatedObjectTypeToString:self.type];
        self.sprite = [SKSpriteNode createAnimatedSprite:type withAtlas:@"Animations" andKey:@"default"];
        if (self.type == Waterfall || self.type == Water)
			self.sprite.zPosition = MovingWaterLayer;
		else
			self.sprite.zPosition = AnimatedObjectLayer;
		
		self.sprite.name = [NSString stringWithFormat:@"animated-%d", self.id];
		self.sprite.position = self.position;
		
		if (self.type == Cauldron)
		{
			CGSize	size   = self.sprite.size;
			CGPoint center = CGPointMake(0, -4);
			size.height -= 4;
			
			[self.sprite setPhysicsBodyForCategory:(CategoryAnimatedObject | CategoryObstable) withSize:size andCenter:center];
		}
		else
			[self.sprite setPhysicsBodyForCategory:CategoryAnimatedObject];
		
        [scene addChild:self.sprite];
    }
}

-(void)removeFromScene:(SKScene*)scene
{
	if (self.sprite != nil)
	{
		[self.sprite removeFromParent];
		self.sprite = nil;
	}
}

-(void)unload
{
	self.sprite = nil;
}

+(CGSize)sizeForType:(AnimatedObjectType)type
{
	if (type == Fire || type == Water || type == Waterfall) // 16x8
		return CGSizeMake(16, 8);
	else if (type == SorceryDrowned) // 16x16
		return CGSizeMake(16, 16);
	else
		return CGSizeMake(24, 24);
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
	[dict setValue:[NSNumber numberWithBool:self.evil]			forKey:@"evil"];
	
	return dict;
}

+(instancetype)deserialize:(NSDictionary*)dict
{
	NSNumber* x			= (NSNumber*)[dict objectForKey:@"x"];
	NSNumber* y			= (NSNumber*)[dict objectForKey:@"y"];
	NSNumber* type		= (NSNumber*)[dict objectForKey:@"type"];
	NSNumber* evil		= (NSNumber*)[dict objectForKey:@"evil"];
	
	AnimatedObjectType	iType	 = (AnimatedObjectType)[type integerValue];
	CGPoint				position = [self pointWithX:x andY:y];
	
	AnimatedObject* obj = [[AnimatedObject alloc] initWithType:iType andPosition:position];
	
	if (evil && obj.type == Cauldron)
		obj.evil = arc4random_uniform(4) == 0;
	
	return obj;
}


@end
