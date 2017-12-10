
Documentation and samplecode for:
## **Keyboard Events for iOS - Corona SDK Plugin**

* This plugin adds an event listener to the iOS keyboard. Letting your app listen for "willShow", "didShow", willHide", "didHide" event phases. The events contain information about the keyboard height and the duration of the keyboard animation.

* The plugin also have an option to move the entire Corona view up with the keyboard, which is a usefull feature for eg. chat boxes where the textfield is placed at the bottom of the screen.

* As a bonus feature you can use this plugin to turn off autocorrection and spell checking on text boxes created with Coronas API (this is a missing feature in the native.newTextBox implementation).  

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

**event.keyboardHeight** (number) height of the keyboard.

Multiply this number with display.contentScaleY to convert to coronas screen units.

**animationDuration** (number) the duration of the keyboard transition in milliseconds.


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


### **Gotchas**
You need to set spell checking and auto-correction after creating your text boxes. When calling keyboardEvents.setSpellCheckingType or keyboardEvents.setAutocorrectionType the type will be set on all instances of the text boxes in your app.
 
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
