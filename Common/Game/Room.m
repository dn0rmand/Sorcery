//
//  GameContext.m
//  Sorcery
//
//  Created by Dominique Normand on 1/12/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "SpriteHelper.h"
#import "allObjects.h"

@implementation Room

-(instancetype)initWithId:(int)id andName:(NSString *)name
{
    self = [super init];
    
    self.id					= id;
    self.name				= name;
    self.sprites			= nil;
    self.staticObjects		= [NSMutableArray array];
    self.doors				= [NSMutableArray array];
    self.animatedObjects	= [NSMutableArray array];
	self.characters			= [NSMutableArray array];
	self.hitmap				= [NSMutableArray arrayWithCapacity:40*18];
	self.tiles				= [NSMutableArray arrayWithCapacity:40*18];
	
	for(int i = 0 ; i < 18*40 ; i++)
	{
		[self.tiles setObject:[NSNumber numberWithUnsignedShort:0] atIndexedSubscript:i];
		[self.hitmap setObject:[NSNumber numberWithUnsignedShort:0] atIndexedSubscript:i];
	}
	
    return self;
}

-(CollisionType)hitmapAtRow:(int)row andColumn:(int)col
{
	if (col < 0 || col >= 40 || row < 0 || row >= 18)
		return 0;
	
	NSNumber* number = (NSNumber*)[self.hitmap objectAtIndex:col + (row * 40)];
	
	return (CollisionType)[number unsignedShortValue];
}

+(instancetype)createWithId:(int)id andName:(NSString *)name
{
    return [[Room alloc] initWithId:id andName:name];
}

-(void)addToScene:(SKScene*)scene withGame:(GameEngine*)game
{
    if (self.sprites == nil)
    {
		self.sprites = [NSMutableArray array];
		
		for (int y = 0 ; y < 18 ; y++)
		{
			for (int x = 0 ; x < 40 ; x++)
			{
				NSNumber*		tile  = (NSNumber*)[self.tiles objectAtIndex:(y*40)+x];
				unsigned short	iTile = [tile unsignedShortValue];
				
				if (iTile != 0)
				{
					SKTexture*		texture = [[GameContext sharedContext] getTile:iTile];
					SKSpriteNode*	sprite	= [SKSpriteNode spriteNodeWithTexture:texture];
					
					if (iTile == 176)
						sprite.zPosition = Tile176Layer;
					else
						sprite.zPosition = RoomLayer;
					sprite.position	 = CGPointMake((x*8)+4, 200-(y*8)-4);
					
					if ([self hitmapAtRow:y andColumn:x] == CollideWithObstacle)
						[sprite setPhysicsBodyForCategory:CategoryRoom];
					
					[self.sprites addObject:sprite];
					[scene addChild:sprite];
					
					sprite.name = [NSString stringWithFormat:@"tile%d", iTile];
				}
			}
		}
		
        for (StaticObject* object in self.staticObjects)
        {
            [object addToScene:scene withGame:game];
        }
        
        for (Door* door in self.doors)
        {
            [door addToScene:scene withGame:game];
        }
        
        for (AnimatedObject* obj in self.animatedObjects)
        {
            [obj addToScene:scene withGame:game];
        }
		
		for (Character* obj in self.characters)
		{
			[obj addToScene:scene withGame:game];
		}
    }
}

-(void)removeFromScene:(SKScene*)scene
{
	if (self.sprites != nil)
	{
		for(SKSpriteNode* sprite in self.sprites)
		{
			if (scene == nil)
				scene = sprite.scene;
			[sprite removeFromParent];
		}
		[self.sprites removeAllObjects];
		self.sprites = nil;
		
		for (StaticObject* obj in self.staticObjects)
			[obj removeFromScene:scene];
		
		for (Door* obj in self.doors)
			[obj removeFromScene:scene];
		
		for (AnimatedObject* obj in self.animatedObjects)
			[obj removeFromScene:scene];
		
		for (Character* obj in self.characters)
			[obj removeFromScene:scene];
	}
}

-(void)unload
{
	if (self.sprites != nil)
	{
		for (SKSpriteNode* sprite in self.sprites)
			[sprite removeFromParent];
		[self.sprites removeAllObjects];
		self.sprites = nil;
	}
	
	for (StaticObject* obj in self.staticObjects)
		[obj unload];
	
	for (Door* obj in self.doors)
		[obj unload];
	
	for (AnimatedObject* obj in self.animatedObjects)
		[obj unload];
	
	for (Character* obj in self.characters)
		[obj unload];
}

-(id)objectForNode:(SKNode*)node
{
	if (node == nil || node.physicsBody == nil)
		return nil;
	
	if (node.physicsBody.categoryBitMask & CategoryAnimatedObject)
	{
		for (AnimatedObject* obj in self.animatedObjects)
			if (obj.sprite == node)
				return obj;
	}
	else if (node.physicsBody.categoryBitMask & CategoryCharacter)
	{
		for (Character* obj in self.characters)
			if (obj.sprite == node)
				return obj;
	}
	else if (node.physicsBody.categoryBitMask & CategoryDoor)
	{
		for (Door* obj in self.doors)
			if (obj.sprite == node)
				return obj;
	}
	else if (node.physicsBody.categoryBitMask & CategoryStaticObject)
	{
		for (StaticObject* obj in self.staticObjects)
			if (obj.sprite == node)
				return obj;
	}
	
	return nil;
}

-(NSArray*)serializeList:(NSArray*)items serialization:(id (^)(id))block
{
	NSMutableArray* array = [NSMutableArray array];
	
	for(id item in items)
	{
		id x = block(item);
		
		[array addObject:x];
	}
	
	return array;
}

-(NSDictionary*)serialize
{
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];

	[dict setValue:self.name   forKey:@"name"];
	[dict setValue:self.hitmap forKey:@"hitmap"];
	[dict setValue:self.tiles  forKey:@"tiles"];
	
	[dict setValue:[self serializeList:self.staticObjects serialization:^id(id item) {
		return [(StaticObject*)item serialize];
	}] forKey:@"staticObjects"];
	
	[dict setValue:[self serializeList:self.doors serialization:^id(id item) {
		return [(Door*)item serialize];
	}] forKey:@"doors"];
	
	[dict setValue:[self serializeList:self.animatedObjects serialization:^id(id item) {
		return [(AnimatedObject*)item serialize];
	}] forKey:@"animatedObjects"];
	[dict setValue:[self serializeList:self.characters serialization:^id(id item) {
		return [(Character*)item serialize];
	}] forKey:@"characters"];
	
	return dict;
}

+(instancetype)deserialize:(int)id from:(NSDictionary*)dict
{
	NSString* name = [dict objectForKey:@"name"];
	
	Room* room = [Room createWithId:id andName:(NSString *)name];
	
	room.hitmap = (NSMutableArray*)[dict objectForKey:@"hitmap"];
	room.tiles  = (NSMutableArray*)[dict objectForKey:@"tiles"];
	
	int index;
 
	index = 0;
	for(NSDictionary* entry in (NSArray*)[dict objectForKey:@"staticObjects"])
	{
		StaticObject* obj = [StaticObject deserialize:entry];
		
		obj.id = index++;
		[room.staticObjects addObject:obj];
	}

	index = 0;
	for(NSDictionary* entry in (NSArray*)[dict objectForKey:@"doors"])
	{
		Door* obj = [Door deserialize:entry];
		
		obj.id = index++;
		[room.doors addObject:obj];
	}
	
	index = 0;
	for(NSDictionary* entry in (NSArray*)[dict objectForKey:@"animatedObjects"])
	{
		AnimatedObject* obj = [AnimatedObject deserialize:entry];
		
		obj.id = index++;
		[room.animatedObjects addObject:obj];
	}
	
	index = 0;
	for(NSDictionary* entry in (NSArray*)[dict objectForKey:@"characters"])
	{
		Character* obj = [Character deserialize:entry];
		
		obj.id = index++;
		[room.characters addObject:obj];
	}
	
	return room;
}

@end
