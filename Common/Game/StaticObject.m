//
//  GameContext.m
//  Sorcery
//
//  Created by Dominique Normand on 1/12/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "SpriteHelper.h"
#import "allObjects.h"

@implementation StaticObject
{
	StaticObjectType	_type;
	CGPoint				_position;
}

-(StaticObjectType)type
{
	return _type;
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

-(void)setType:(StaticObjectType)type
{
	if (_type == type)
		return;
	
	_type = type;
	if (self.sprite != nil)
	{
		SKScene* scene = self.sprite.scene;
		
		[self.sprite removeFromParent];
		self.sprite = nil;
		[self addToScene:scene withGame:nil];
	}
}

-(instancetype)initWithType:(StaticObjectType)type andPosition:(CGPoint)position
{
	self = [super init];
	
	self.type       = type;
	self.position   = position;
	self.sprite     = nil;
	self.id			= 0;
	self.value		= 50;
	return self;
}

+(instancetype)createWithType:(NSString*)type andPosition:(CGPoint)position
{
    return [[StaticObject alloc] initWithType:[EnumHelper staticObjectTypeFromString:type] andPosition:position];
}

-(void)addToScene:(SKScene*)scene withGame:(GameEngine*)game
{
    if (self.sprite == nil && self.type != Nothing)
    {
		NSString*		name	= [EnumHelper staticObjectTypeToString:self.type];
        SKTexture*      texture = [SKTexture textureWithName:name andAtlas:@"StaticObjects"];
		
        self.sprite  = [SKSpriteNode spriteNodeWithTexture:texture];
        self.sprite.zPosition = StaticObjectLayer;
		self.sprite.name = [NSString stringWithFormat:@"static-%d", self.id];
		
		self.sprite.position = self.position;
		
		CGPoint center;
		CGSize	size;
		
		switch (self.type)
		{
			case IronBall:
				size = CGSizeMake(24, 16);
				center= CGPointMake(0, -4);
				[self.sprite setPhysicsBodyForCategory:CategoryStaticObject withSize:size andCenter:center];
				break;
			default:
				[self.sprite setPhysicsBodyForCategory:CategoryStaticObject];
				break;
		}
		
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
	[dict setValue:[NSNumber numberWithInteger:self.value]		forKey:@"value"];
	
	return dict;
}

+(instancetype)deserialize:(NSDictionary*)dict
{
	NSNumber* x			= (NSNumber*)[dict objectForKey:@"x"];
	NSNumber* y			= (NSNumber*)[dict objectForKey:@"y"];
	NSNumber* type		= (NSNumber*)[dict objectForKey:@"type"];
	NSNumber* value		= (NSNumber*)[dict objectForKey:@"value"];
	
	CGPoint				position = [self pointWithX:x andY:y];
	StaticObjectType	iType	 = (StaticObjectType)[type integerValue];
	
	StaticObject* obj = [[StaticObject alloc] initWithType:iType andPosition:position];
	
	if (value != nil)
		obj.value = [value intValue];
	
	return obj;
}

@end
