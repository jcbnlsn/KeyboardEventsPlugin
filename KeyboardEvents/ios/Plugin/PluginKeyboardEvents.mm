//
//  PluginKeyboardEvents.mm
//
//  Copyright (c) 2017 Jacob Nielsen. All rights reserved.
//

#import "PluginKeyboardEvents.h"

#include <CoronaRuntime.h>
#include <CoronaLuaIOS.h>
#import <UIKit/UIKit.h>

// ----------------------------------------------------------------------------

@interface Observer : NSObject //<NSUserNotificationCenterDelegate>
	@property (nonatomic, assign) lua_State *L; // Pointer to the current Lua state
	@property bool moveView;
	- (void) keyboardWillShow:(NSNotification*)notification;
	- (void) keyboardWillHide:(NSNotification*)notification;
	- (void) keyboardDidShow:(NSNotification*)notification;
	- (void) keyboardDidHide:(NSNotification*)notification;
	- (void) tapDetected:(UITapGestureRecognizer*)tap;
@end

// -----------------------------------------------------------------------------

class PluginKeyboardEvents
{
	public:
		typedef PluginKeyboardEvents Self;

	public:
		static const char kName[];
		static const char kEvent[];

	protected:
		PluginKeyboardEvents();

	public:
		bool Initialize( CoronaLuaRef listener );

	public:
		CoronaLuaRef GetListener() const { return fListener; }

	public:
		static int Open( lua_State *L );

	protected:
		static int Finalizer( lua_State *L );

	public:
		static Self *ToLibrary( lua_State *L );

	public:
		static int init( lua_State *L );
		static int setAutocorrectionType( lua_State *L );
		static int setSpellCheckingType( lua_State *L );
		static int setKeyboardTypeASCIICapable( lua_State *L );
		static int setHeader( lua_State *L );
		static int setMoveViewOffsetY( lua_State *L );
		static int setMoveView( lua_State *L );
		static int setKeyboardAppearance( lua_State *L );
		static int addScreenshotListener( lua_State *L );
		static int isPushNotificationsAllowed( lua_State *L );
		static int setTextFieldAutocapitalizationType( lua_State *L );
		static int setTextBoxAutocapitalizationType( lua_State *L );
		static int setActivityIndicator( lua_State *L );

	private:
		CoronaLuaRef fListener;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
const char PluginKeyboardEvents::kName[] = "plugin.keyboardEvents";

// This corresponds to the event name, e.g. [Lua] event.name
const char PluginKeyboardEvents::kEvent[] = "keyboardEvent";

PluginKeyboardEvents::PluginKeyboardEvents()
:	fListener( NULL )
{
}

bool
PluginKeyboardEvents::Initialize( CoronaLuaRef listener )
{
	// Can only initialize listener once
	bool result = ( NULL == fListener );

	if ( result )
	{
		fListener = listener;
	}

	return result;
}

int
PluginKeyboardEvents::Open( lua_State *L )
{
	// Register __gc callback
	const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
	CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );

	// Functions in library
	const luaL_Reg kVTable[] =
	{
		{ "init", init },
		{ "setAutocorrectionType", setAutocorrectionType },
		{ "setSpellCheckingType", setSpellCheckingType },
		{ "setKeyboardTypeASCIICapable", setKeyboardTypeASCIICapable }, 
		{ "setHeader", setHeader }, 
		{ "setMoveViewOffsetY", setMoveViewOffsetY },
		{ "setMoveView", setMoveView },
		{ "setKeyboardAppearance", setKeyboardAppearance },
		{ "addScreenshotListener", addScreenshotListener },
		{ "isPushNotificationsAllowed", isPushNotificationsAllowed },
		{ "setTextFieldAutocapitalizationType", setTextFieldAutocapitalizationType },
		{ "setTextBoxAutocapitalizationType", setTextBoxAutocapitalizationType },
		{ "setActivityIndicator", setActivityIndicator },
		
		{ NULL, NULL }
	};

	// Set library as upvalue for each library function
	Self *library = new Self;
	CoronaLuaPushUserdata( L, library, kMetatableName );

	luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack

	return 1;
}

int
PluginKeyboardEvents::Finalizer( lua_State *L )
{
	Self *library = (Self *)CoronaLuaToUserdata( L, 1 );

	CoronaLuaDeleteRef( L, library->GetListener() );

	delete library;

	return 0;
}

PluginKeyboardEvents *
PluginKeyboardEvents::ToLibrary( lua_State *L )
{
	// library is pushed as part of the closure
	Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
	return library;
}

// Event observer
Observer *observer;

// [Lua] keyboardEvents.init()
int
PluginKeyboardEvents::init( lua_State *L )
{	
	if ( !observer) {
	
		id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );

		observer = [[Observer alloc] init];
		observer.L = L;
		
		// Move main view with keyboard?
		observer.moveView = lua_toboolean( L, 1 );
		if ( ! observer.moveView )
		{
			observer.moveView = FALSE;
		}
		
		SEL selectorShow = NSSelectorFromString(@"keyboardWillShow:");
		if ([observer respondsToSelector:selectorShow])
						[[NSNotificationCenter defaultCenter] addObserver:observer 
						selector:selectorShow 
						name:UIKeyboardWillChangeFrameNotification //UIKeyboardWillChangeFrameNotification
						object:nil];
						
		SEL selectorHide = NSSelectorFromString(@"keyboardWillHide:");
		if ([observer respondsToSelector:selectorHide])
						[[NSNotificationCenter defaultCenter] addObserver:observer 
						selector:selectorHide 
						name:UIKeyboardWillHideNotification //UIKeyboardWillChangeFrameNotification
						object:nil];
						
		SEL selectorDidShow = NSSelectorFromString(@"keyboardDidShow:");
		if ([observer respondsToSelector:selectorDidShow])
						[[NSNotificationCenter defaultCenter] addObserver:observer 
						selector:selectorDidShow 
						name:UIKeyboardDidShowNotification //UIKeyboardWillChangeFrameNotification
						object:nil];
						
		SEL selectorDidHide = NSSelectorFromString(@"keyboardDidHide:");
		if ([observer respondsToSelector:selectorDidHide])
						[[NSNotificationCenter defaultCenter] addObserver:observer 
						selector:selectorDidHide 
						name:UIKeyboardDidHideNotification //UIKeyboardWillChangeFrameNotification
						object:nil];
						
	
		CGRect r = runtime.appViewController.view.frame;
		r.origin.y = 0.0f;
		[runtime.appViewController.view setFrame:r];
	}

	return 0;
}

// [Lua] keyboardEvents.setMoveView()
int
PluginKeyboardEvents::setMoveView( lua_State *L )
{	
	if (observer) {
		bool moveView = lua_toboolean( L, 1 );
		if (!moveView) { 
			moveView = FALSE;
		}
		observer.moveView = moveView;
	}
	return 0;
}

// [Lua] keyboardEvents.setMoveViewOffsetY()
CGFloat viewPositionOffsetY = 0;

int
PluginKeyboardEvents::setMoveViewOffsetY( lua_State *L )
{	
	viewPositionOffsetY = lua_tonumber( L, 1 );
	if (!viewPositionOffsetY) {
		viewPositionOffsetY = 0;
	}
	return 0;
}

// [Lua] keyboardEvents.setHeader()
UIImageView *headerView; 

int
PluginKeyboardEvents::setHeader( lua_State *L )
{
	// Instantiate view for header image
	if (!headerView) {
	
		id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );
	
		headerView = [[UIImageView alloc] init];
		headerView.contentMode = UIViewContentModeScaleToFill;
		[runtime.appViewController.view.superview addSubview:headerView];
		
		// Add touch listener
		UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:observer action:@selector(tapDetected:)];
		singleTap.numberOfTapsRequired = 1;
		[headerView setUserInteractionEnabled:YES];
		[headerView addGestureRecognizer:singleTap];
	}
	headerView.image = nil;
	headerView.hidden = YES;
	
	const char *path = lua_tostring( L, 1 );
	
	// If image path load screenshot
	if (path) {
		
		// Load image
		NSString *imagePath = [NSString stringWithUTF8String:path];
		NSURL *url = [NSURL fileURLWithPath:imagePath];
		NSData *data = [NSData dataWithContentsOfURL:url];
		//NSLog(@"%@", imagePath);
		
		UIImage *image = [UIImage imageWithData:data];
		headerView.image = image;
		
		// Scale image 
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		CGFloat screenWidth = screenRect.size.width;
		CGFloat scale = screenWidth/image.size.width;
		
		CGRect frame = {0,0, screenWidth, static_cast<CGFloat>(((image.size.height*scale)+0.5))}; 
		headerView.frame = frame;
		[UIView commitAnimations];
		headerView.hidden = NO;
	}
	
	return 0;
}

// [Lua] keyboardEvents.setKeyboardTypeASCIICapable()
int
PluginKeyboardEvents::setKeyboardTypeASCIICapable( lua_State *L )
{	
	bool isASCII = lua_toboolean( L, 1 );
	lua_pop( L, 1 );
	
	id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );

	for (UIView *view in runtime.appViewController.view.subviews) {
	
		if ([view isKindOfClass:[UITextView class]]) {
			UITextView *textfield = (UITextView *)view;
			if (isASCII) {
				[textfield setKeyboardType:UIKeyboardTypeASCIICapable];
			} else {
				[textfield setKeyboardType:UIKeyboardTypeDefault];
			}
		}
	}
	return 0;
}

// [Lua] keyboardEvents.setMoveView()
int
PluginKeyboardEvents::setKeyboardAppearance( lua_State *L )
{	
	const char *type = lua_tostring( L, 1 );
	
	UIKeyboardAppearance appearance;
	
	if (!type || (strcmp(type, "default") == 0) ) { 
		appearance = UIKeyboardAppearanceDefault; 
	} else if (strcmp(type, "dark") == 0) {
		appearance = UIKeyboardAppearanceDark;
	}  else if (strcmp(type, "light") == 0) {
		appearance = UIKeyboardAppearanceLight;
	} else {
		appearance = UIKeyboardAppearanceDefault;
		luaL_error( L, "Invalid keyboard appearance key passed!" );
	}

	//NSLog(@"appearance %ld", (long)appearance);
	[[UITextField appearance] setKeyboardAppearance:appearance];

	id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );
	
	for (UIView *view in runtime.appViewController.view.subviews) {
		if ([view isKindOfClass:[UITextView class]]) {
			UITextView *textView = (UITextView *)view;
			[textView setKeyboardAppearance:appearance];
		}
	}

	return 0;
}

// [Lua] keyboardEvents.setAutocorrectionType()
int
PluginKeyboardEvents::setAutocorrectionType( lua_State *L )
{	

	const char *type = lua_tostring( L, 1 );
	if (!type) { type = "UITextAutocorrectionTypeDefault"; }

	id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );

	for (UIView *view in runtime.appViewController.view.subviews) {
		
		if ([view isKindOfClass:[UITextView class]]) {
			//NSLog(@"%@", view);
			UITextView *textfield = (UITextView *)view;
			
			if (strcmp(type, "UITextAutocorrectionTypeNo") == 0) {
				[textfield setAutocorrectionType: UITextAutocorrectionTypeNo];
			} else if (strcmp(type, "UITextAutocorrectionTypeYes") == 0) {
				[textfield setAutocorrectionType: UITextAutocorrectionTypeYes];
			} else if (strcmp(type, "UITextAutocorrectionTypeDefault") == 0) {
				[textfield setAutocorrectionType: UITextAutocorrectionTypeDefault];
			} else {
				luaL_error( L, "Invalid autocorrection key passed!" );
			}
		}
	}
	
	return 0;
}

// [Lua] keyboardEvents.setAutocorrectionType()
int
PluginKeyboardEvents::setSpellCheckingType( lua_State *L )
{	
	const char *type = lua_tostring( L, 1 );
	if (!type) { type = "UITextSpellCheckingTypeDefault"; }

	id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );

	for (UIView *view in runtime.appViewController.view.subviews) {
		
		if ([view isKindOfClass:[UITextView class]]) {
			//NSLog(@"%@", view);
			UITextView *textfield = (UITextView *)view;
			if (strcmp(type, "UITextSpellCheckingTypeNo") == 0) {
				[textfield setSpellCheckingType: UITextSpellCheckingTypeNo];
			} else if (strcmp(type, "UITextSpellCheckingTypeYes") == 0) {
				[textfield setSpellCheckingType: UITextSpellCheckingTypeYes];
			} else if (strcmp(type, "UITextSpellCheckingTypeDefault") == 0) {
				[textfield setSpellCheckingType: UITextSpellCheckingTypeDefault];
			} else {
				luaL_error( L, "Invalid spell checking key passed!" );
			}
		}
	}
	
	return 0;
}

// [Lua] keyboardEvents.addScreenshotListener()
int
PluginKeyboardEvents::addScreenshotListener( lua_State *L )
{	

	NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification
		object:nil
		queue:mainQueue
		usingBlock:^(NSNotification *note) {
			// executes after screenshot
			lua_newtable( L );
			
			lua_pushstring( L, "onUserDidTakeScreenshot" );   
			lua_setfield( L, -2, "name" );   
			
			Corona::Lua::DispatchRuntimeEvent( L, -1 );
		}
	];
	
	return 0;
}

// [Lua] library.isPushNotificationsAllowed( word )
int
PluginKeyboardEvents::isPushNotificationsAllowed( lua_State *L )
{
	float isEnabled = 0;
	
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){
		UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];

		if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
			isEnabled = 0;
		} else {
			isEnabled = 1;
		}
	}
	
	lua_newtable( L );
	lua_pushboolean(L, isEnabled); 

	return 1;
}

// [Lua] library.setTextFieldAutocapitalizationType( word )
int
PluginKeyboardEvents::setTextFieldAutocapitalizationType( lua_State *L )
{
	const char *type = lua_tostring( L, 1 );
	if (!type) { type = "Sentences"; }
	
	id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );

	for (UIView *view in runtime.appViewController.view.subviews) {
		
		if ([view isKindOfClass:[UITextField class]]) {
			//NSLog(@"%@", view);
			UITextField *textfield = (UITextField *)view;
			if (strcmp(type, "None") == 0) {
				[textfield setAutocapitalizationType: UITextAutocapitalizationTypeNone];
			} else if (strcmp(type, "Words") == 0) {
				[textfield setAutocapitalizationType: UITextAutocapitalizationTypeWords];
			} else if (strcmp(type, "Sentences") == 0) {
				[textfield setAutocapitalizationType: UITextAutocapitalizationTypeSentences];
			} else if (strcmp(type, "AllCharacters") == 0) {
				[textfield setAutocapitalizationType: UITextAutocapitalizationTypeAllCharacters];
			} else {
				luaL_error( L, "Invalid spell checking key passed!" );
			}
		}
	}
	
	return 0;
}

// [Lua] library.setTextBoxAutocapitalizationType( word )
int
PluginKeyboardEvents::setTextBoxAutocapitalizationType( lua_State *L )
{
	const char *type = lua_tostring( L, 1 );
	if (!type) { type = "Sentences"; }
	
	id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );

	for (UIView *view in runtime.appViewController.view.subviews) {
		
		if ([view isKindOfClass:[UITextView class]]) {
			//NSLog(@"%@", view);
			UITextView *textfield = (UITextView *)view;
			if (strcmp(type, "None") == 0) {
				[textfield setAutocapitalizationType: UITextAutocapitalizationTypeNone];
			} else if (strcmp(type, "Words") == 0) {
				[textfield setAutocapitalizationType: UITextAutocapitalizationTypeWords];
			} else if (strcmp(type, "Sentences") == 0) {
				[textfield setAutocapitalizationType: UITextAutocapitalizationTypeSentences];
			} else if (strcmp(type, "AllCharacters") == 0) {
				[textfield setAutocapitalizationType: UITextAutocapitalizationTypeAllCharacters];
			} else {
				luaL_error( L, "Invalid spell checking key passed!" );
			}
		}
	}
	
	return 0;
}

// [Lua] library.setActivityIndicator()
UIActivityIndicatorView *activityIndicator;

int
PluginKeyboardEvents::setActivityIndicator( lua_State *L )
{
	id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );
	bool show = lua_toboolean( L, 1 );
	
	if (!activityIndicator) {
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicator.hidesWhenStopped = TRUE;
		activityIndicator.center = runtime.appViewController.view.center;
		[runtime.appViewController.view addSubview: activityIndicator];
	}
	
	if (show) {
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[activityIndicator startAnimating];
	} else {
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		[activityIndicator stopAnimating];
	}

	return 0;
}

// Observer ----------------------------------------------------------------------
@implementation Observer

	-(void)tapDetected:(UITapGestureRecognizer*)tap {
		CGPoint location = [tap locationInView:headerView];
		if (headerView.image) {
		
			//NSLog(@"Point: %@", NSStringFromCGPoint(location));
			
			// Dispatch tap position event
			lua_State *L = self.L;
			lua_newtable( L );
		
			lua_pushstring( L, "headerEvent" );
			lua_setfield( L, -2, "name" );
			lua_pushstring( L, "tap" );
			lua_setfield( L, -2, "phase" );
			lua_pushnumber( L, location.x);
			lua_setfield( L, -2, "x" );
			lua_pushnumber( L, location.y);
			lua_setfield( L, -2, "y" );
		
			Corona::Lua::DispatchRuntimeEvent( L, -1 );
		}
	}

	- (void)keyboardWillShow:(NSNotification*)notification
	{
		CGFloat screenScale = [[UIScreen mainScreen] scale];
		double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]*1000;
		double keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
	
		lua_State *L = self.L;
		id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );

		if (self.moveView) { 
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
			[UIView setAnimationCurve:(UIViewAnimationCurve)[[[notification userInfo] objectForKey: UIKeyboardAnimationCurveUserInfoKey] integerValue]];
			[UIView setAnimationBeginsFromCurrentState:YES];
			
			//NSLog(@"view y position %f", runtime.appViewController.view.frame.origin.y );
			CGFloat viewPosY = runtime.appViewController.view.frame.origin.y;
			
			runtime.appViewController.view.frame = CGRectOffset(runtime.appViewController.view.frame, 0.0, -keyboardHeight+viewPositionOffsetY-viewPosY);
			[UIView commitAnimations];
		}
		
		// Dispatch keyboard event
		lua_newtable( L );
		
		const char phaseValue[] = "willShow";
		double height = screenScale*keyboardHeight;
		
		lua_pushstring( L, "keyboardEvent" );   
		lua_setfield( L, -2, "name" );   
		lua_pushstring( L, phaseValue );
		lua_setfield( L, -2, "phase" );
		lua_pushnumber( L, height);
		lua_setfield( L, -2, "keyboardHeight" );
		lua_pushnumber( L, duration);
		lua_setfield( L, -2, "animationDuration" );
		
		Corona::Lua::DispatchRuntimeEvent( L, -1 );
	}
	
	- (void)keyboardWillHide:(NSNotification*)notification
	{
		CGFloat screenScale = [[UIScreen mainScreen] scale];
		double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]*1000;
		double keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
	
		lua_State *L = self.L;
		id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );

		if (self.moveView) { 
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
			[UIView setAnimationCurve:(UIViewAnimationCurve)[[[notification userInfo] objectForKey: UIKeyboardAnimationCurveUserInfoKey] integerValue]];
			[UIView setAnimationBeginsFromCurrentState:YES];
			runtime.appViewController.view.frame = CGRectOffset(runtime.appViewController.view.frame, 0.0, keyboardHeight-viewPositionOffsetY);
			[UIView commitAnimations];
		}

		lua_newtable( L );
		
		const char phaseValue[] = "willHide";
		double height = screenScale*keyboardHeight;
		
		lua_pushstring( L, "keyboardEvent" );
		lua_setfield( L, -2, "name" );
		lua_pushstring( L, phaseValue );
		lua_setfield( L, -2, "phase" );
		lua_pushnumber( L, height);
		lua_setfield( L, -2, "keyboardHeight" );
		lua_pushnumber( L, duration);
		lua_setfield( L, -2, "animationDuration" );
		
		Corona::Lua::DispatchRuntimeEvent( L, -1 );
	}
	
	- (void)keyboardDidShow:(NSNotification*)notification
	{
		CGFloat screenScale = [[UIScreen mainScreen] scale];
		double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]*1000;
		double keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
	
		lua_State *L = self.L;
		lua_newtable( L );
		
		const char phaseValue[] = "didShow";
		double height = screenScale*keyboardHeight;
		lua_pushstring( L, "keyboardEvent" );
		lua_setfield( L, -2, "name" );
		lua_pushstring( L, phaseValue );
		lua_setfield( L, -2, "phase" );
		lua_pushnumber( L, height);
		lua_setfield( L, -2, "keyboardHeight" );
		lua_pushnumber( L, duration);
		lua_setfield( L, -2, "animationDuration" );
		
		Corona::Lua::DispatchRuntimeEvent( L, -1 );
	}
	
	- (void)keyboardDidHide:(NSNotification*)notification
	{
		CGFloat screenScale = [[UIScreen mainScreen] scale];
		double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]*1000;
		double keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
	
		lua_State *L = self.L;
		id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );

		if (self.moveView) { 
			CGRect r = runtime.appViewController.view.frame;
			r.origin.y = 0.0f;
			[runtime.appViewController.view setFrame:r];
		}
        
		lua_newtable( L );
		
		const char phaseValue[] = "didHide";
		double height = screenScale*keyboardHeight;
		
		lua_pushstring( L, "keyboardEvent" );
		lua_setfield( L, -2, "name" );
		lua_pushstring( L, phaseValue );
		lua_setfield( L, -2, "phase" );
		lua_pushnumber( L, height);
		lua_setfield( L, -2, "keyboardHeight" );
		lua_pushnumber( L, duration);
		lua_setfield( L, -2, "animationDuration" );
		
		Corona::Lua::DispatchRuntimeEvent( L, -1 );
	}
@end

// Export ----------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_keyboardEvents( lua_State *L )
{
	return PluginKeyboardEvents::Open( L );
}
