//
//  JCButton.m
//  TestSpriteKit01
//
//  Created by Juan Carlos Sedano Salas on 18/09/13.
//  Copyright (c) 2013 Juan Carlos Sedano Salas. All rights reserved.
//

#import "JCButton.h"
#import "Math.h"

@interface JCImageButton()

@property (nonatomic,strong) UITouch *onlyTouch;
@property SKTexture*	normal;
@property SKTexture*	pressed;

@property BOOL wasRead;
@property BOOL isOn;
@property BOOL isTurbo;

@end

@implementation JCImageButton

-(id)initWithNormalImage:(NSString*)name pressedImage:(NSString *)pressedImage isTurbo:(BOOL)isTurbo
{
	SKTexture* normal = [SKTexture textureWithImageNamed:name];
	SKTexture* pressed= nil;
	
	if (pressedImage != nil)
		pressed = [SKTexture textureWithImageNamed:pressedImage];
	
	if (pressed == nil)
		pressed = normal;
	
	self = [super initWithTexture:normal];
	
	if (self != nil)
	{
		self.normal		= normal;
		self.pressed	= pressed;
		self.onlyTouch	= nil;
		self.isTurbo	= isTurbo;
		self.isOn		= NO;
		self.wasRead	= NO;
		[self setUserInteractionEnabled:YES];
		
		[SKSpriteNode spriteNodeWithImageNamed:name];
		self.alpha = 0.50f;
	}
	return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	if (!self.onlyTouch)
	{
		self.onlyTouch = [touches anyObject];
		self.isOn = YES;
		self.wasRead = NO;
		self.texture = self.pressed;
	}
	
	self.alpha = 0.75f;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	
	if(!self.onlyTouch)
		return;
	
	CGPoint location = [self.onlyTouch locationInNode:[self parent]];
	
	if (![self containsPoint:location])
	{
		self.onlyTouch = nil;
		if (self.isTurbo && self.wasRead)
			self.isOn = NO;
		self.texture = self.normal;
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
	if ([[touches allObjects] containsObject:self.onlyTouch])
	{
		if (self.wasRead)
			self.isOn = NO;
		self.texture = self.normal;
		self.onlyTouch = nil;
	}
	
	self.alpha = 0.50f;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	
	if ([[touches allObjects] containsObject:self.onlyTouch])
	{
		self.texture = self.normal;
		self.onlyTouch = nil;
		self.isOn = NO;
		self.wasRead = YES;
	}
	
	self.alpha = 0.50f;
}


-(BOOL)wasPressed
{
	self.wasRead = YES;
	if (self.isOn)
	{
		if (! self.isTurbo)
			self.isOn = NO;
		return YES;
	}
	return NO;
}

@end
