
Documentation and samplecode for:
https://marketplace.coronalabs.com/plugin/keyboard-events
## **Keyboard Events for iOS - Corona SDK Plugin**

* This plugin adds an event listener to the iOS keyboard. Letting your app listen for "willShow", "didShow", willHide", "didHide" event phases. The events contain information about the keyboard height and the duration of the keyboard animation.

* The plugin also have an option to move the entire Corona view up with the keyboard, which is a usefull feature for eg. chat boxes where the textfield is placed at the bottom of the screen.

* Bonus features: **1.** turn off autocorrection and spell checking on text boxes created with Coronas API (this is a missing feature in the native.newTextBox implementation). **2.** Set keyboard appearance (color) on the native keyboard.

### **Syntax**
Initialize the plugin with:


```lua
local keyboardEvents = require "plugin.keyboardEvents"
keyboardEvents.init ( [moveView] )
```

**moveView** 
(boolean) Set this to true if you want the view (stage) to slide up with the keyboard. Default is false.  

### **Keyboard event listener**

To recieve keyboard events add a runtime listener:

```lua
local function keyboardEventListener( event )
    
    if ( event.phase == "willShow" ) then
    elseif ( event.phase == "didShow" ) then
    elseif ( event.phase == "willHide" ) then
    elseif ( event.phase == "didHide" ) then
    end
end

Runtime:addEventListener( "keyboardEvents", keyboardEventListener )
```

### Event Data
A keyboard event returns a table of information which you can use to re-arrange you apps layout. This table includes the following:

**event.phase** (string) phases of the keyboard visibility.

Possible values are: "willShow", "didShow", "willHide", "didHide"

**event.keyboardHeight** (number) height of the keyboard.

Multiply this number with display.contentScaleY to convert to coronas screen units.

**event.animationDuration** (number) the duration of the keyboard transition in milliseconds.


### Move Corona View

Turn the option to move the Corona view on/off on the fly.

```lua
keyboardEvents.setMoveView(bool)
```
**bool** (bool) Turn the option to move the view with the keyboard on/off.

```lua
keyboardEvents.setMoveViewOffsetY(offset)
```
**offset** (number) Sets an offset factor on the number off pixels the view moves.


### Auto-correction and spell checking

```lua
keyboardEvents.setAutocorrectionType ( type )
```
**type** (string) Controls the type of auto-correction performed on text boxes. Possible values are:

"UITextAutocorrectionTypeDefault", "UITextAutocorrectionTypeYes", "UITextAutocorrectionTypeNo"




```lua
keyboardEvents.setSpellCheckingType ( type )
```
**type** (string) Controls the type of spell checking performed on text boxes. Possible values are:

"UITextAutocorrectionTypeDefault", "UITextAutocorrectionTypeYes", "UITextAutocorrectionTypeNo"


### Keyboard Appearance

```lua
keyboardEvents.setKeyboardAppearance ( type )
```
**type** (string) Controls the appearance (color) of the keyboard. You need to call keyboardEvents.setKeyboardAppearance after creating your textFields and textBoxes. Possible values are:

"default", "light", "dark"


### **Gotchas**
* When using the moveView feature you need to dismiss the keyboard when suspending the application.

* When calling keyboardEvents.setSpellCheckingType or keyboardEvents.setAutocorrectionType the type will be set on all instances of the text boxes in your app.

* You need to set spell checking, auto-correction and setKeyboardAppearance **AFTER** creating your text boxes. 
 
### **Project Settings**
To use this plugin, add an entry into the plugins table of build.settings. When added, the build server will integrate the plugin during the build phase.
```lua
settings =
{
    plugins =
    {
        ["plugin.keyboardEvents"] = { publisherId = "net.shakebrowser" }
    },      
}
```

### **Examples**

Find examples in the samplecode folder in this repository
