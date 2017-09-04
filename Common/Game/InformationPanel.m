//
//  GameContext.m
//  Sorcery
//
//  Created by Dominique Normand on 1/12/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "SpriteHelper.h"
#import "allObjects.h"

@interface InformationPanel()
	@property	SKSpriteNode*		sprite;
	@property	SKNode*				carryingNode;
	@property	SKNode*				energyNode;
	@property	SKNode*				scoreNode;
	@property	SKNode*				energyLabel;
	@property	SKNode*				roomText;
	@property	SKNode*				bigBook;
@end

@implementation InformationPanel
{
	StaticObjectType	_carrying;
	int					_energy;
	float				_score;
	NSString*			_roomName;
	int					_roomId;
}

-(instancetype)init
{
	self = [super init];
	
	self.carrying = Nothing;
	self.roomName = @"Not Set";
	return self;
}

+(instancetype)create
{
    return [[InformationPanel alloc] init];
}

-(void)addRoomName:(NSString*)name id:(int)roomId toScene:(SKScene*)scene
{
	if (self.roomText != nil)
		[self.roomText removeFromParent];
	
	NSString* roomName = [NSString stringWithFormat:@"%@ %d", name, roomId];
	self.roomText = [SKNode createLabel:roomName];
	self.roomText.zPosition = InformationPanelLayer+1;
	self.roomText.position = CGPointMake(5, 36);
	[scene addChild:self.roomText];
}

-(void)addCarryingText:(StaticObjectType)carrying toScene:(SKScene*)scene
{
	if (self.carryingNode != nil)
		[self.carryingNode removeFromParent];
		
	NSString* carryingText = [EnumHelper staticObjectTypeToCarryingText:self.carrying];
	
	self.carryingNode = [SKNode createLabel:carryingText];
	self.carryingNode.zPosition = InformationPanelLayer+1;
	self.carryingNode.position = CGPointMake(5, 22);
	[scene addChild:self.carryingNode];
}

-(void)addEnergyText:(int)energy toScene:(SKScene*)scene
{
	if (self.energyNode != nil)
		[self.energyNode removeFromParent];

	NSString* s = [NSString stringWithFormat:@"^Y%d", energy];
	self.energyNode = [SKNode createLabel:s];
	self.energyNode.zPosition = InformationPanelLayer+2;
	self.energyNode.position = CGPointMake(101, 9);
	// Fix calculation error.
	
	CGPoint position = self.energyNode.position;
	position.y = self.energyLabel.position.y;
	self.energyNode.position = position;
	
	[scene addChild:self.energyNode];
}

-(void)addScoreText:(int)score toScene:(SKScene*)scene
{
	if (self.scoreNode != nil)
		[self.scoreNode removeFromParent];
	
	NSString* s = [NSString stringWithFormat:@"^R%06d", score];
	self.scoreNode = [SKNode createLabel:s];
	self.scoreNode.zPosition = InformationPanelLayer+2;
	
	CGRect rect = [self.energyLabel calculateAccumulatedFrame];
	
	float x  = CGRectGetMaxX(rect)+4;
	
	self.scoreNode.position = CGPointMake(x, 8);
	
	[scene addChild:self.scoreNode];
}

-(float)energy
{
	return (float)_energy;
}

-(void)setEnergy:(float)value
{
	int energy = (int)round(value);
	if (energy == _energy)
		return;
	
	_energy = energy;
	if (self.energyNode != nil)
		[self addEnergyText:energy toScene:self.energyNode.scene];
}

-(int)score
{
	return _score;
}

-(void)setScore:(int)score
{
	if (score == _score)
		return;
	
	_score = score;
	if (self.energyNode != nil)
		[self addScoreText:score toScene:self.scoreNode.scene];
}

-(NSString*)roomName
{
	return _roomName;
}

-(void)setRoomName:(NSString *)roomName
{
	if ([roomName compare:self.roomName] == NSOrderedSame)
		return;

	_roomName = roomName;
	if (self.roomText != nil)
		[self addRoomName:roomName id:self.roomId toScene:self.roomText.scene];
}

-(int)roomId
{
	return _roomId;
}

-(void)setRoomId:(int)roomId
{
	if (roomId == self.roomId)
		return;
	
	_roomId = roomId;
	if (self.roomText != nil)
		[self addRoomName:self.roomName id:_roomId toScene:self.roomText.scene];
}

-(StaticObjectType)carrying
{
	return _carrying;
}

-(void)setCarrying:(StaticObjectType)carrying
{
	if (_carrying == carrying)
		return ;
	
	_carrying = carrying;
	
	if (self.carryingNode != nil)
		[self addCarryingText:self.carrying toScene:self.carryingNode.scene];
}

-(void)addToScene:(SKScene*)scene withGame:(GameEngine*)game
{
    if (self.sprite == nil)
    {
		self.sprite = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(320.0f, 56.0f)];
		self.sprite.zPosition = InformationPanelLayer;
		self.sprite.position = CGPointMake(160, 28);
		[scene addChild:self.sprite];
		
		[self addRoomName:self.roomName id:self.roomId toScene:scene];
		[self addCarryingText:self.carrying toScene:scene];
		
		self.energyLabel = [SKNode createLabel:@"energy......  %   Score:"];
		self.energyLabel.zPosition = InformationPanelLayer+1;
		self.energyLabel.position = CGPointMake(5, 8);
		[scene addChild:self.energyLabel];
		
		[self addEnergyText:self.energy toScene:scene];
		[self addScoreText:self.score toScene:scene];
		
		self.bigBook = [SKSpriteNode spriteNodeWithImageNamed:@"Big-Book"];
		self.bigBook.position = CGPointMake(320 - 34, 30);
		self.bigBook.zPosition = InformationPanelLayer+1;
		[scene addChild:self.bigBook];
    }
}


@end
