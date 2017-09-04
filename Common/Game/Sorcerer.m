//
//  GameContext.m
//  Sorcery
//
//  Created by Dominique Normand on 1/12/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "SpriteHelper.h"
#import "allObjects.h"

const float CENTER = 12;

const float MAXY = 200-CENTER;
const float MINY = 200-144+CENTER;
const float MAXX = 320-CENTER;
const float MINX = CENTER;

@implementation Wizard
{
	DirectionType	_direction;
	CGPoint			_position;
}

-(CGPoint)position
{
	// Update position
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

-(instancetype)initWithPosition:(CGPoint)position
{
    self = [super init];
    
    self.position		= position;
	self.direction		= UpDown;
    self.sprite			= nil;
	self.energy			= 99.0f;
	self.carrying		= Nothing;
    return self;
}

+(instancetype)createWithPosition:(CGPoint)position
{
    return [[Wizard alloc] initWithPosition:position];
}

-(NSString*)animationNameForDirection:(DirectionType)directionType
{
	NSString*		type		= [EnumHelper characterTypeToString:Sorcerer];
	NSString*		direction	= [EnumHelper directionTypeToString:directionType forCharacter:Sorcerer];
	NSString*		animation	= [NSString stringWithFormat:@"%@%@", type, direction];
	
	return animation;
}

-(void)addToScene:(SKScene*)scene withGame:(GameEngine*)game
{
    if (self.sprite == nil)
    {
		// WARNING! Need to do this before creating the sprite or we will lose the position value
		CGPoint position = self.position;
		
		NSString* animation	= [self animationNameForDirection:self.direction];
		
		self.sprite  = [SKSpriteNode createAnimatedSprite:animation withAtlas:@"Characters" andKey:@"default" andSpeed:0.2f];
		self.sprite.zPosition = SorcererLayer;
		self.sprite.name = @"sorcerer";
		self.sprite.position = position;
		
		[self createBody];
		[self.sprite setRoomConstraint:NO];
		
        [scene addChild:self.sprite];
    }
}

-(void)createBody
{
	CGSize	size = self.sprite.size;
	CGPoint center;
	
	size.width -= 4;
	
	switch (self.direction)
	{
		case Left:
			center = CGPointMake(-2, 0);
			break;
		case Right:
			center = CGPointMake(+2, 0);
			break;
		default:
			center = CGPointMake(0, 0);
			break;
	}
	[self.sprite setPhysicsBodyForCategory:CategorySorcerer withSize:size andCenter:center];
	
	self.sprite.physicsBody.dynamic = YES;
	self.sprite.physicsBody.restitution = 0;
	self.sprite.physicsBody.contactTestBitMask = CategoryObjects;
	self.sprite.physicsBody.collisionBitMask = CategoryWall;
}

-(void)reset
{
	self.sprite = nil;
}

-(DirectionType)direction
{
	return _direction;
}

-(void)setDirection:(DirectionType)direction
{
	if (direction != _direction)
	{
		_direction = direction;
		
		if (self.sprite != nil)
		{
			NSString* animation	= [self animationNameForDirection:_direction];
			
			[self.sprite animateSprite:animation withAtlas:@"Characters" andKey:@"default" andSpeed:0.2f];
			[self createBody];
		}
	}
}

-(float)distanceOf:(CGPoint)pt1 to:(CGPoint)pt2
{
	float x = (pt1.x - pt2.x);
	float y = (pt1.y - pt2.y);
	
	return sqrtf(x*x + y*y);
}

-(void)moveTo:(CGPoint)location
{
	if (self.sprite == nil)
		return;
	
	CGPoint		position = self.position;
	float		distance = [self distanceOf:position to:location];
	float		time	 = distance / 160.0f;
	
	if (location.x < position.x)
		self.direction = Left;
	else if (location.x > position.x)
		self.direction = Right;
	else
		self.direction = UpDown;

	SKAction*	move		= [SKAction moveTo:location duration:time];
	SKAction*	completion	= [SKAction runBlock:^{ self.direction = UpDown; }];
	SKAction*	action		= [SKAction sequence:@[move, completion]];
	
	[self.sprite runAction:action withKey:@"MoveWizard"];
}

-(void)moveByX:(CGFloat)x andY:(CGFloat)y
{
	if (x == 0 && y == 0)
	{
		self.direction = UpDown;
		return; // Nothing else to do
	}
	
	if (self.sprite == nil)
		return;
	
	if (x < 0)
		self.direction = Left;
	else if (x > 0)
		self.direction = Right;
	else
		self.direction = UpDown;
	
	CGPoint p = self.position;
	
	p.x += x;
	p.y += y;
	
	p.x = MIN(MAX(p.x, MINX), MAXX);
	p.y = MIN(MAX(p.y, MINY), MAXY);
	
	self.position = p;
}

-(BOOL)canGoThroughDoor:(Door*)door;
{
	if (door.key != Nothing && self.carrying != door.key)
		return NO; // Door locked.
	
	CGPoint pt1 = self.position;
	CGPoint pt2 = door.position;
	CGPoint pt3 = CGPointZero;
	
	switch (door.type)
	{
		case LeftDoor:
			pt2.x += (CENTER+CENTER); // 12+12 = (Width of Wizard + Width of Door)/2
			if (self.direction != Left)
				return NO;
			break;
		case RightDoor:
			pt2.x -= (CENTER+CENTER); // 12+12 = (Width of Wizard + Width of Door)/2
			if (self.direction != Right)
				return NO;
			break;
		case GreenDoor:
			pt3 = pt2;
			pt2.x -= (CENTER+6); // (Width of wizard + width of Door)/2
			pt3.x += (CENTER+6);
			break;
		case TrapDoor:
			pt2.y -= 8; // Set new center.
			pt3 = pt2;
			pt2.y += CENTER + 4; // (height of Wizard + height of Door)/2
			pt3.y -= CENTER + 4;
			break;
		default:
			return NO;
	}
	
	CGRect rect = CGRectMake(pt2.x-3, pt2.y-3, 6, 6); // Give a bit of error

	if (CGRectContainsPoint(rect, pt1))
		return YES;
	
	if (pt3.x == 0 && pt3.y == 0)
		return NO;
	
	rect = CGRectMake(pt3.x-3, pt3.y-3, 6, 6);

	if (CGRectContainsPoint(rect, pt1))
		return YES;
	
	return NO;
}

-(void)doPlouf:(void (^)())block
{
	CGPoint p = self.position;
	
	p.y -= 4;
	
	self.position = p;
	
	SKAction*	sound   = [SKAction playSoundFileNamed:@"Water.mp3" waitForCompletion:YES];
	SKAction*	plouf   = [SKSpriteNode getAnimation:@"Plouf" withAtlas:@"Animations" speed:1.0f/6 andRestore:NO];
				plouf	= [SKAction group:@[sound, plouf]];
	
	SKAction*	drowned	= [SKSpriteNode getAnimation:@"SorceryDrowned" withAtlas:@"Animations" speed:0.2f andRestore:NO];
				drowned	= [SKAction repeatAction:drowned count:20];
	SKAction*	actions = [SKAction sequence:@[plouf, drowned]] ;
	
	[self.sprite runAction:actions completion:block];
}

-(void)die:(void (^)())block
{
	SKAction*	animation	= [SKSpriteNode getAnimation:@"Explosion" withAtlas:@"Animations" speed:1.1f/4 andRestore:NO];
				animation	= [SKAction sequence:@[animation, [SKAction hide]]];
	SKAction*	sound		= [SKAction playSoundFileNamed:@"Fire.mp3" waitForCompletion:YES];
	SKAction*	delay		= [SKAction waitForDuration:2.0f];
	
	SKAction*	actions		= [SKAction group:@[animation, sound]];
				actions		= [SKAction sequence:@[actions, delay]];
	
	[self.sprite runAction:actions completion:block];
}

-(void)update:(CFTimeInterval)currentTime withGame:(GameEngine*)game
{
//	if (self.sprite == nil)
//		return ;
//	if (self.sprite.physicsBody.velocity.dx > 0)
//		self.direction = Right;
//	else if (self.sprite.physicsBody.velocity.dx < 0)
//		self.direction = Left;
//	else
//		self.direction = UpDown;
}
@end
