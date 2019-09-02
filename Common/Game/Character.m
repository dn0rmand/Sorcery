//
//  GameContext.m
//  Sorcery
//
//  Created by Dominique Normand on 1/12/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "SpriteHelper.h"
#import "allObjects.h"

@implementation Character
{
	DirectionType	_direction;
	CGPoint			_position;
	BOOL			_changingDirection;
}

-(instancetype)initWithType:(CharacterType)type position:(CGPoint)position andStartPosition:(CGPoint)startPosition
{
    self = [super init];
	
	_changingDirection  = NO;
    self.position		= position;
	self.defaultPosition= position;
	self.startPosition	= startPosition;
	self.type			= type;
	self.direction		= [EnumHelper defaultDirectionForCharacter:self.type];
    self.sprite			= nil;
	self.moveable		= CGPointEqualToPoint(self.defaultPosition, self.startPosition);
	self.speed			= 0;
	self.killed			= NO;
	self.id				= 0;
    return self;
}

+(instancetype)createWithType:(NSString*)type position:(CGPoint)position andStartPosition:(CGPoint)startPosition
{
    return [[Character alloc] initWithType:[EnumHelper characterTypeFromString:type] position:position andStartPosition:startPosition];
}

-(CGPoint)position
{
	// Update localed position field
	if (self.sprite != nil)
		_position = self.sprite.position;
	
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
    if (self.sprite == nil && ! self.killed)
    {
		CGPoint			position	= self.position; // Need to do that before creating the sprite
		
		NSString*		type		= [EnumHelper characterTypeToString:self.type];
		NSString*		direction	= [EnumHelper directionTypeToString:self.direction forCharacter:self.type];
		NSString*		animation	= [NSString stringWithFormat:@"%@%@", type, direction];
		
		self.sprite  = [SKSpriteNode createAnimatedSprite:animation withAtlas:@"Characters" andKey:@"default" andSpeed:0.2f];
		self.sprite.name = [NSString stringWithFormat:@"character-%d", self.id];
		
		if (/*self.type == Prisoner ||*/ !self.moveable)
			self.sprite.zPosition = RoomLayer-1;
        else
			self.sprite.zPosition = CharacterLayer;
		
		self.sprite.position = position;
		
		if (self.type == Ghost || self.type == Prisoner) // Ghost go through wall. Prisoner doesn't move
			[self.sprite setPhysicsBodyForCategory:CategoryCharacter];
		else
			[self.sprite setPhysicsBodyForCategory:CategoryCharacter contactMask:0 andCollisionMask:CategoryWall];
		
		if (self.type != Prisoner && self.moveable)
		{
			self.sprite.physicsBody.dynamic = YES;
			[self.sprite setRoomConstraint:self.type == Priest];
		}
        [scene addChild:self.sprite];
    }
}

-(DirectionType)direction
{
	return _direction;
}

-(void)setDirection:(DirectionType)direction
{
	if (_changingDirection)
		return ; // Cannot do it now
	
	if (self.sprite != nil)
	{
		if (direction != _direction)
		{
			DirectionType oldDirection = _direction;
			
			NSString* oldAnimation = [EnumHelper directionTypeToString:_direction forCharacter:self.type];
			NSString* newAnimation = [EnumHelper directionTypeToString:direction forCharacter:self.type];

			_direction = direction;
			
			if ([oldAnimation compare:newAnimation] == NSOrderedSame)
				return;
			
            void (^finalizeDirection)(void) = ^void() {
				NSString*		type		= [EnumHelper characterTypeToString:self.type];
				NSString*		animation	= [NSString stringWithFormat:@"%@%@", type, newAnimation];
			
				[self.sprite animateSprite:animation withAtlas:@"Characters" andKey:@"default" andSpeed:0.2f];
			};
			
			if (self.type == Ghost || self.type == Priest)
			{
				if (oldDirection == Left && direction == Right)
				{
					_changingDirection = YES;
					
					NSString*		tmpAnimation= [EnumHelper directionTypeToString:LeftToRight forCharacter:self.type];
					NSString*		type		= [EnumHelper characterTypeToString:self.type];
					NSString*		animation	= [NSString stringWithFormat:@"%@%@", type, tmpAnimation];

					SKAction* anim1 = [SKSpriteNode getAnimation:animation withAtlas:@"Characters" speed:0.2f andRestore:NO];
					SKAction* end   = [SKAction runBlock:^{
                        self->_changingDirection = NO;
						finalizeDirection();
					}];
					
					SKAction* action = [SKAction sequence:@[anim1, end]];
					[self.sprite runAction:action withKey:@"redirect"];
				}
				else if (oldDirection == Right && direction == Left)
				{
					_changingDirection = YES;
					
					NSString*		tmpAnimation = [EnumHelper directionTypeToString:RightToLeft forCharacter:self.type];
					NSString*		type		 = [EnumHelper characterTypeToString:self.type];
					NSString*		animation	 = [NSString stringWithFormat:@"%@%@", type, tmpAnimation];
					
					SKAction* anim1 = [SKSpriteNode getAnimation:animation withAtlas:@"Characters" speed:0.2f andRestore:NO];
					SKAction* end   = [SKAction runBlock:^{
                        self->_changingDirection = NO;
						finalizeDirection();
					}];
					
					SKAction* action = [SKAction sequence:@[anim1, end]];
					[self.sprite runAction:action withKey:@"redirect"];
				}
				else
				{
					finalizeDirection();
				}
			}
			else
			{
				finalizeDirection();
			}
		}
	}
	else
		_direction = direction;
}

-(float)change:(float)value ref:(float)ref speed:(int)speed updateDirection:(BOOL)updateDirection
{
	DirectionType	dir = Still;
	
	if (value < ref)
	{
		value += speed;
		if (value > ref)
			value = ref;
		if (updateDirection)
			dir = RightToLeft;
	}
	else if (value > ref)
	{
		value -= speed;
		if (value < ref)
			value = ref;
		if (updateDirection)
			dir = RightToLeft;
	}

	if (updateDirection)
	{
		if (dir == Still)
		{
			if (self.direction == LeftToRight)
				self.direction = Left;
			else if (self.direction == RightToLeft)
				self.direction = Right;
			else
				self.direction = [EnumHelper defaultDirectionForCharacter:self.type];
		}
		else
			self.direction = RightToLeft;
	}
	return value;
}

-(void)update:(CFTimeInterval)currentTime withGame:(GameEngine*)game
{
	if (self.sprite == nil || self.killed)
		return;
	
	if (! self.moveable && self.type != Prisoner)
	{
		CGPoint pt = self.position;
		
		pt.x = [self change:pt.x ref:self.startPosition.x speed:2 updateDirection:YES];
		pt.y = [self change:pt.y ref:self.startPosition.y speed:2 updateDirection:NO];
		
		self.position = pt;
		
		self.moveable = CGPointEqualToPoint(pt, self.startPosition);
		if (self.moveable)
		{
			self.sprite.zPosition = CharacterLayer;
			self.sprite.physicsBody.dynamic = YES;
			[self.sprite setRoomConstraint:self.type == Priest];
		}
	}
	else if (self.moveable && self.type != Prisoner)
	{
		if (game.energy > 0) // Dead already, no need to insist more
		{
			float	speed  = self.speed * 0.75f;
			
			CGPoint source = self.position;
			CGPoint destin = game.wizard.position;

			if (source.x > destin.x)
			{
				if (! _changingDirection)
				{
					source.x -= speed;
					if (source.x < destin.x)
						source.x = destin.x;
					self.direction = Left;
				}
			}
			else if (source.x < destin.x)
			{
				if (! _changingDirection)
				{
					source.x += speed;
					if (source.x > destin.x)
						source.x = destin.x;
					self.direction = Right;
				}
			}
			
			if (self.type != Priest) // Priest don't move up & down
			{
				if (source.y > destin.y)
				{
					source.y -= speed;
					if (source.y < destin.y)
						source.y = destin.y;
				}
				else if (source.y < destin.y)
				{
					source.y += speed;
					if (source.y > destin.y)
						source.y = destin.y;
				}
			}
			
			self.position = source;
		}
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

-(void)killWithScore:(int)score
{
	self.killed = YES;
	
	if (self.sprite != nil)
	{
		if (self.type == Prisoner)
		{
			CGFloat	offsetY = self.position.y + self.sprite.size.height;

			SKAction* animation = [SKSpriteNode getAnimation:@"Star" withAtlas:@"Animations" speed:0.1f andRestore:NO];
			SKAction* sound		= [SKAction playSoundFileNamed:@"Fire.mp3" waitForCompletion:YES];
			SKAction* move		= [SKAction moveByX:0.0f y:offsetY duration:offsetY / 100];
			SKAction* effect	= [SKAction sequence:@[[SKAction group:@[sound, move]], [SKAction removeFromParent]]];
			
			animation = [SKAction repeatActionForever:animation];
			SKAction* action	= [SKAction group:@[animation, effect]];
			
			[self.sprite runAction:action withKey:@"default"];
		}
		else
		{
			SKTexture*		texture		= [SKTexture textureWithName:[NSString stringWithFormat:@"Score-%d", score] andAtlas:@"StaticObjects"];			
			SKAction*		showScore	= [SKAction animateWithTextures:@[texture] timePerFrame:1.0f resize:NO restore:NO];
			SKAction*		remove		= [SKAction removeFromParent];
			SKAction*		explosion	= [SKSpriteNode getAnimation:@"Explosion" withAtlas:@"Animations" speed:1.1f/4 andRestore:NO];
			
			SKAction* animation = [SKAction sequence:@[explosion, showScore, remove]];
			SKAction* sound		= [SKAction playSoundFileNamed:@"Fire.mp3" waitForCompletion:YES];
			SKAction* action	= [SKAction group:@[animation, sound]];
			
			[self.sprite runAction:action withKey:@"default"];
		}
	}
}

-(NSDictionary*)serialize
{
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	
	[dict setValue:[NSNumber numberWithFloat:self.position.x]			forKey:@"x"];
	[dict setValue:[NSNumber numberWithFloat:self.position.y]			forKey:@"y"];
	[dict setValue:[NSNumber numberWithInteger:self.type]				forKey:@"type"];
	
	[dict setValue:[NSNumber numberWithFloat:self.startPosition.x]		forKey:@"start-x"];
	[dict setValue:[NSNumber numberWithFloat:self.startPosition.y]		forKey:@"start-y"];
	[dict setValue:[NSNumber numberWithFloat:self.defaultPosition.x]	forKey:@"default-x"];
	[dict setValue:[NSNumber numberWithFloat:self.defaultPosition.y]	forKey:@"default-y"];
	[dict setValue:[NSNumber numberWithInteger:self.speed]				forKey:@"speed"];
	[dict setValue:[NSNumber numberWithBool:self.moveable]				forKey:@"moveable"];
	[dict setValue:[NSNumber numberWithInteger:self.killer]				forKey:@"killer"];
	[dict setValue:[NSNumber numberWithBool:self.killed]				forKey:@"killed"];
	
	return dict;
}

+(CGPoint)pointWithX:(NSNumber*)x andY:(NSNumber*)y offset:(int)offset
{
	CGPoint pos = CGPointMake([x floatValue] + offset, [y floatValue] + offset);
	return pos;
}

+(instancetype)deserialize:(NSDictionary*)dict
{
	NSNumber* x			= (NSNumber*)[dict objectForKey:@"x"];
	NSNumber* y			= (NSNumber*)[dict objectForKey:@"y"];
	NSNumber* type		= (NSNumber*)[dict objectForKey:@"type"];
	
	NSNumber* startX	= (NSNumber*)[dict objectForKey:@"start-x"];
	NSNumber* startY	= (NSNumber*)[dict objectForKey:@"start-y"];
	NSNumber* defaultX	= (NSNumber*)[dict objectForKey:@"default-x"];
	NSNumber* defaultY	= (NSNumber*)[dict objectForKey:@"default-y"];
	
	NSNumber* speed		= (NSNumber*)[dict objectForKey:@"speed"];
	NSNumber* moveable	= (NSNumber*)[dict objectForKey:@"moveable"];
	NSNumber* killer	= (NSNumber*)[dict objectForKey:@"killer"];
	NSNumber* killed	= (NSNumber*)[dict objectForKey:@"killed"];
	
	Character* obj = [[Character alloc] initWithType:(CharacterType)[type integerValue]
											position:[self pointWithX:defaultX andY:defaultY offset:12]
									andStartPosition:[self pointWithX:startX andY:startY offset:12]];
	
	
	obj.position = [self pointWithX:x andY:y offset:0];
	obj.speed	 = (int)[speed integerValue];
	obj.moveable = [moveable boolValue];
	obj.killer	 = (StaticObjectType)[killer integerValue];
	obj.killed	 = [killed boolValue];
	
	return obj;
}


@end
