//
//  GameContext.h
//  Sorcery
//
//  Created by Dominique Normand on 1/12/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Room.h"

@interface GameContext : NSObject

@property (readonly)	BOOL	ready;

-(id)init;
-(Room*)getRoom:(int)id;
-(SKTexture*)getTile:(int)index;

+(instancetype)sharedContext;
+(void)preLoad;

@end
