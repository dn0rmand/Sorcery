//
//  enums.h
//  Sorcery
//
//  Created by Dominique Normand on 1/14/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	CategoryRoom				= 1,
	CategoryCharacter			= 2,
	CategoryAnimatedObject		= 8,
	CategoryStaticObject		= 16,
	CategoryDoor				= 32,
	CategorySorcerer			= 64,
	CategoryObstable			= 128, // Special object. We need to "sit" on it
	
	CategoryWall				= CategoryRoom | CategoryDoor | CategoryObstable,
	CategoryObjects				= CategoryCharacter | CategoryAnimatedObject | CategoryStaticObject | CategoryDoor
} CategoryMask;

typedef enum
{
	CollideWithNothing		= 0,
	CollideWithFire			= 1,
	CollideWithUnknown		= 2,
	CollideWithCauldron		= 3,
	CollideWithTrapDoor		= 4,
	CollideWithLeftDoor		= 5,
	CollideWithRightDoor	= 6,
	CollideWithGreenDoor	= 7,
	CollideWithObstacle		= 8,
	CollideWithWater		= 9,
	CollideWithStaticObject	= 10,
	CollideWithSpace		= 11,
	CollideWithCharacter	= 12
} CollisionType;

typedef enum
{
	RoomLayer				= 1,

	StaticObjectLayer		= 2,
	DoorLayer				= 2,
	AnimatedObjectLayer		= 3,
	CharacterLayer			= 4,
	SorcererLayer			= 5,
	MovingWaterLayer		= 6,
	
	Tile176Layer			= 80,
	InformationPanelLayer	= 100
} ObjectLayer;

typedef enum
{
	Still,
	Left,
	LeftToRight,
	Right,
	RightToLeft,
	UpDown
} DirectionType ;

typedef enum
{
	CloseLeftDoor,
	CloseRightDoor,
	Cauldron,
	Explosion,
	Fire,
	OpenLeftDoor,
	OpenRightDoor,
	Plouf,
	SorceryDrowned,
	AnimatedStar,
	Water,
	Waterfall
} AnimatedObjectType;

typedef enum
{
    Axe,
    Badge,
    Bag,
    Book,
    Bottle,
    Chalice,
    Crown,
    Glass,
    GreenDoor,
    Hat,
    IronBall,
    Key,
    LeftDoor,
    Lyre,
    Lys,
    Moon,
    Parchment,
    RightDoor,
    StaticStar,
    Sword,
    TrapDoor,
	Nothing,
	DrownedInTheRiver
} StaticObjectType;

typedef enum
{
    Animal,
    Eye,
    Face,
    Ghost,
    Priest,
    Prisoner,
    Sorcerer
} CharacterType;

@interface EnumHelper : NSObject

+(AnimatedObjectType)animatedObjectTypeFromString:(NSString*)value;
+(StaticObjectType)staticObjectTypeFromString:(NSString*)value;
+(CharacterType)characterTypeFromString:(NSString*)value;
+(DirectionType)defaultDirectionForCharacter:(CharacterType)value;

+(NSString*)animatedObjectTypeToString:(AnimatedObjectType)value;
+(NSString*)staticObjectTypeToString:(StaticObjectType)value;
+(NSString*)characterTypeToString:(CharacterType)value;
+(NSString*)directionTypeToString:(DirectionType)value forCharacter:(CharacterType)character;
+(NSString*)staticObjectTypeToCarryingText:(StaticObjectType)value;

@end

