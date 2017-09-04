//
//  GameContext.m
//  Sorcery
//
//  Created by Dominique Normand on 1/12/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "allObjects.h"
#import <Foundation/NSPathUtilities.h>

@interface GameContext()
	@property NSMutableArray*			rooms;
	@property NSMutableDictionary*		tiles;
@end

@implementation GameContext
{
	Room*	_currentRoom;
	int		_roomIndex;
}

static GameContext* _sharedContext = nil;

+(void)preLoad
{
	GameContext* context = [GameContext sharedContext];
	
	if (! context.ready)
		[NSThread detachNewThreadSelector:@selector(preloadContext) toTarget:context withObject:nil];
}

+(instancetype)sharedContext
{
    if (_sharedContext == nil)
        _sharedContext = [[GameContext alloc] init];
    
    return _sharedContext;
}

-(id)init
{
	self = [super init];
	self.rooms = [NSMutableArray arrayWithCapacity:48];
	self.tiles = [NSMutableDictionary dictionary];

	_ready = NO;
	
	return self;
}

-(void)loadFromPList
{
	NSBundle*       bundle = [NSBundle mainBundle];
	NSString*       path   = [bundle pathForResource:@"map" ofType:@"plist"];
	NSDictionary*	dict   = [NSDictionary dictionaryWithContentsOfFile:path];
	NSArray*		rooms  = (NSArray*)[dict objectForKey:@"rooms"];
	
	int index = 0;
	
	for (NSDictionary* room in rooms)
	{
		[self.rooms addObject:[Room deserialize:index from:room]];
		index++;
	}
}

-(void)preloadContext
{
	[self loadFromPList];
	
	NSDate* start = [NSDate date];
	for(int i = 1; i < 240; i++)
	{
		[self getTile:i];
	}
	
	NSTimeInterval part2 = [start timeIntervalSinceNow];
	NSLog(@"preloaded all the tiles in %lf", part2 );
	
	_ready = YES;
}

-(SKTexture*)getTile:(int)index
{
	NSNumber* key = [NSNumber numberWithInt:index];
	
	SKTexture*	texture = (SKTexture*)[self.tiles objectForKey:key];
	
	if (texture == nil)
	{
		NSString* imageName = [NSString stringWithFormat:@"tile%d", index];
		
		texture = [SKTexture textureWithName:imageName andAtlas:@"Tiles"];
		[self.tiles setObject:texture forKey:key];
	}
	
	return texture;
}

-(Room*)getRoom:(int)id
{
	Room* room = (Room *)[self.rooms objectAtIndex:id];

	return room;
}

@end
