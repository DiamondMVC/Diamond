[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Flash messages

Flash messages are useful to create certain type of notification messages or temporary messages.

To create a flash message simply call the view function: *flashMessage()*.

Function definition:

```
void flashMessage(string identifier, string message, FlashMessageType type, size_t displayTime = 0)
```

### identifier

The identifier for the flash message. This will be the id of the dom element created.

### message

The message to display. This can be plain-text or html. You can combine the call to **flashMessage** with a call to **retrieve()** to render a view inside it.

### type

The type of the flash message.

There are 4 types of flash messages.

* always
  * The message will always be displayed.
* showOnce
  * The message will only be shown once per session.
* showOnceGuest
  * The message will only be shown once for a "guest" user. It's never displayed for users logged in.
* custom
  * The message html is rendered, but nothing is done to it. The control over the flash message is entirely up to yourself.
  
### displayTime

The time the message should be displayed. If the value is 0, then it will show forever.

Example:

```
@:flashMessage("message1", "This message stays forever.", FlashMessageType.always);
@:flashMessage("message2", "This message dissappers after 10 seconds.", FlashMessageType.always, 10000);
@:flashMessage("message3", "This message is gone after your next refresh.", FlashMessageType.showOnce);
@:flashMessage("message4", "This message is gone after your next refresh and shows for 20 seconds.", FlashMessageType.showOnce, 20000);
```
