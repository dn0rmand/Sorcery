//
//  enums.h
//  Sorcery
//
//  Created by Dominique Normand on 1/14/15.
//  Copyright (c) 2015 Cegedim. All rights reserved.
//

#import "enums.h"

@implementation EnumHelper

+(DirectionType)defaultDirectionForCharacter:(CharacterType)value;
{
	switch (value)
	{
		case Animal:        return Still;
		case Eye:           return Still;
		case Face:          return Still;
		case Ghost:         return Left;
		case Priest:        return Left;
		case Prisoner:      return Still;
		case Sorcerer:      return UpDown;
			
		default:            return Still;
	}
}

+(AnimatedObjectType)animatedObjectTypeFromString:(NSString*)value
{
	if ([value compare:@"CloseLeftDoor"] == NSOrderedSame)	return CloseLeftDoor;
	if ([value compare:@"CloseRightDoor"] == NSOrderedSame)	return CloseRightDoor;
	if ([value compare:@"Cauldron"] == NSOrderedSame)       return Cauldron;
	if ([value compare:@"Explosion"] == NSOrderedSame)      return Explosion;
	if ([value compare:@"Fire"] == NSOrderedSame)			return Fire;
	if ([value compare:@"OpenLeftDoor"] == NSOrderedSame)	return OpenLeftDoor;
	if ([value compare:@"OpenRightDoor"] == NSOrderedSame)	return OpenRightDoor;
	if ([value compare:@"Plouf"] == NSOrderedSame)			return Plouf;
	if ([value compare:@"SorceryDrowned"] == NSOrderedSame)	return SorceryDrowned;
	if ([value compare:@"Star"] == NSOrderedSame)			return AnimatedStar;
	if ([value compare:@"Water"] == NSOrderedSame)			return Water;
	if ([value compare:@"Waterfall"] == NSOrderedSame)		return Waterfall;
	
	[NSException raise:@"Invalid Animated Object Type" format:@"%@ is not a valid animated object type", value];
	return CloseLeftDoor;
}

+(StaticObjectType)staticObjectTypeFromString:(NSString*)value
{
    if ([value compare:@"Axe"] == NSOrderedSame)        return Axe;
    if ([value compare:@"Badge"] == NSOrderedSame)      return Badge;
    if ([value compare:@"Bag"] == NSOrderedSame)        return Bag;
    if ([value compare:@"Book"] == NSOrderedSame)       return Book;
    if ([value compare:@"Bottle"] == NSOrderedSame)     return Bottle;
    if ([value compare:@"Chalice"] == NSOrderedSame)    return Chalice;
    if ([value compare:@"Crown"] == NSOrderedSame)      return Crown;
    if ([value compare:@"Glass"] == NSOrderedSame)      return Glass;
    if ([value compare:@"GreenDoor"] == NSOrderedSame)  return GreenDoor;
    if ([value compare:@"Hat"] == NSOrderedSame)        return Hat;
    if ([value compare:@"IronBall"] == NSOrderedSame)   return IronBall;
    if ([value compare:@"Key"] == NSOrderedSame)        return Key;
    if ([value compare:@"LeftDoor"] == NSOrderedSame)   return LeftDoor;
    if ([value compare:@"Lyre"] == NSOrderedSame)       return Lyre;
    if ([value compare:@"Lys"] == NSOrderedSame)        return Lys;
    if ([value compare:@"Moon"] == NSOrderedSame)       return Moon;
    if ([value compare:@"Parchment"] == NSOrderedSame)  return Parchment;
    if ([value compare:@"RightDoor"] == NSOrderedSame)  return RightDoor;
    if ([value compare:@"Star"] == NSOrderedSame)       return StaticStar;
    if ([value compare:@"Sword"] == NSOrderedSame)      return Sword;
    if ([value compare:@"TrapDoor"] == NSOrderedSame)   return TrapDoor;
	if ([value compare:@"None"] == NSOrderedSame)		return Nothing;
	
    [NSException raise:@"Invalid Static Object Type" format:@"%@ is not a valid static object type", value];
    return Axe;
}

+(CharacterType)characterTypeFromString:(NSString*)value
{
    if ([value compare:@"Animal"] == NSOrderedSame)     return Animal;
    if ([value compare:@"Eye"] == NSOrderedSame)        return Eye;
    if ([value compare:@"Face"] == NSOrderedSame)       return Face;
    if ([value compare:@"Ghost"] == NSOrderedSame)      return Ghost;
    if ([value compare:@"Priest"] == NSOrderedSame)     return Priest;
    if ([value compare:@"Prisoner"] == NSOrderedSame)   return Prisoner;
    if ([value compare:@"Sorcery"] == NSOrderedSame)    return Sorcerer;
    
    [NSException raise:@"Invalid Character Type" format:@"%@ is not a valid character type", value];
    return Animal;
}

+(NSString*)animatedObjectTypeToString:(AnimatedObjectType)value
{
	switch (value)
	{
		case CloseLeftDoor:		return @"CloseLeftDoor";
		case CloseRightDoor:	return @"CloseRightDoor";
		case Cauldron:			return @"Cauldron";
		case Explosion:			return @"Explosion";
		case Fire:				return @"Fire";
		case OpenLeftDoor:		return @"OpenLeftDoor";
		case OpenRightDoor:		return @"OpenRightDoor";
		case Plouf:				return @"Plouf";
		case SorceryDrowned:	return @"SorceryDrowned";
		case AnimatedStar:		return @"Star";
		case Water:				return @"Water";
		case Waterfall:			return @"Waterfall";
			
		default:				return @"Unknown";
	}
}

+(NSString*)staticObjectTypeToString:(StaticObjectType)value
{
    switch (value)
    {
        case Axe:           return @"Axe";
        case Badge:         return @"Badge";
        case Bag:           return @"Bag";
        case Book:          return @"Book";
        case Bottle:        return @"Bottle";
        case Chalice:       return @"Chalice";
        case Crown:         return @"Crown";
        case Glass:         return @"Glass";
        case GreenDoor:     return @"GreenDoor";
        case Hat:           return @"Hat";
        case IronBall:      return @"IronBall";
        case Key:           return @"Key";
        case LeftDoor:      return @"LeftDoor";
        case Lyre:          return @"Lyre";
        case Lys:           return @"Lys";
        case Moon:          return @"Moon";
        case Parchment:     return @"Parchment";
        case RightDoor:     return @"RightDoor";
        case StaticStar:    return @"Star";
        case Sword:         return @"Sword";
        case TrapDoor:      return @"TrapDoor";
            
        default:            return @"Unknown";
    }
}

+(NSString*)characterTypeToString:(CharacterType)value
{
    switch (value)
    {
        case Animal:        return @"Animal";
        case Eye:           return @"Eye";
        case Face:          return @"Face";
        case Ghost:         return @"Ghost";
        case Priest:        return @"Priest";
        case Prisoner:      return @"Prisoner";
        case Sorcerer:       return @"Sorcery";
            
        default:            return @"Unknown";
    }
}

+(NSString*)directionTypeToString:(DirectionType)value forCharacter:(CharacterType)character
{
	switch (character)
	{
		case Animal:
		case Eye:
		case Face:
		case Prisoner:
			return @""; // Direction doesn't apply
			
		case Ghost:
		case Priest:
		case Sorcerer:
			break;
			
		default:
			return @""; // Direction doesn't apply
	}
	
	switch (value)
	{
		case Left:
			return @"-Left";
		case Right:
			return @"-Right";
		case LeftToRight:
			if (character == Sorcerer)
				return @"-Left";
			else
				return @"-LeftToRight";
		case RightToLeft:
			if (character == Sorcerer)
				return @"-Right";
			else
				return @"-RightToLeft";
		case UpDown:
			return @"-UpDown";
			
		default:
			return @"";
	}
}

+(NSString*)staticObjectTypeToCarryingText:(StaticObjectType)value
{
	switch (value)
	{
		case Axe:			return @"carrying a sharp axe.";
		case Badge:			return @"carrying a coat of arms.";
		case Bag:			return @"carrying a sack of spells.";
		case Book:			return @"with a spell book.";
		case Bottle:		return @"with a large bottle.";
		case Chalice:		return @"carrying a golden chalice.";
		case Crown:			return @"carrying a jewelled crown.";
		case Glass:			return @"with a goblet of wine.";
		case Hat:			return @"carrying a magic wand.";
		case IronBall:		return @"with a ball and chain.";
		case Key:			return @"carrying a door key.";
		case Lyre:			return @"with a little lyre.";
		case Lys:			return @"with a fleur de lys.";
		case Moon:			return @"carrying a sorcerer's moon.";
		case Parchment:		return @"with a scroll";
		case StaticStar:	return @"carrying a shooting start.";
		case Sword:			return @"carrying a string sword.";
			
		case DrownedInTheRiver:
							return @"you drowned in the river.";
		default:			return @"carrying nothing.";
	}
}

@end
