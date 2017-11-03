[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Cookies

Cookies can easily be managed through the *HttpClient*'s *cookies* properties.

Views and controllers have access to the current client by either the *view.client* or *client* property.

Ther are 3 types of cookies in Diamond.

## Regular Cookies

Regular cookies are plain-old cookies that are presented exactly like how they are in the browser.

To add a regular cookie you must call *create()* which creates a regular cookie.
To get a regular cookie you must call *get()* which will get a regular cookie.
To check if a regular cookie exists you must call *has()* which will check for existence of a cookie in the current request.
To remove a regular cookie you must call *remove()* which will remove a regular cookie.

Example:

```
client.cookies.create("myCookie", "Hello World!", 60); // The cookie is alive in the browser for 60 seconds

...

string myCookie = client.cookies.get("myCookie"); // Gets the cookie "myCookie"

...

if (client.cookies.has("myCookie"))
{
    // Do stuff when "myCookie" is present.
}
```

## Buffered Cookies

Buffered cookies are cookies stored as byte buffers.

The buffers are encoded with *SENC* (Simple Encoding) which is a simple encoding algorithm implemented in Diamond.

To add a buffered cookie you must call *createBuffered()* which creates a buffered cookie.
To get a buffered cookie you must call *getBuffered()* which will get a buffered cookie.
To check if a buffered cookie exists you must call *has()* which will check for existence of a cookie in the current request.
To remove a buffered cookie you must call *remove()* which will remove a buffered cookie.

Example:

```
ubyte[] myBufferedCookie = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

client.cookies.createBuffered("myBufferedCookie", buffer, 60); // The cookie is alive in the browser for 60 seconds

...

ubyte[] myBufferedCookie = client.cookies.getBuffered("myBufferedCookie"); // Gets the cookie "myCookie"

...

if (client.cookies.has("myBufferedCookie"))
{
    // Do stuff when "myBufferedCookie" is present.
}
```

## The Auth Cookie

The last type of cookie in Diamond is the auth cookie.

The auth cookie cannot be modified directly as it's an internal cookie used by the authentication in Diamond.

To get the auth cookie you must call *getAuthCookie()* which will get the auth cookie.
To check if the auth cookie exists you must call *hasAuthCookie()* which will check for existence of the auth cookie in the current request.

The auth cookie is always the given token for the authentication.

Example:
```
string authToken = client.cookies.getAuthCookie();

...

if (client.cookies.hasAuthCookie())
{
    // Do stuff when the auth cookie is present.
}
```

# Sessions

A session may be shared between multiple requests in the same browser.

Sessions can be used to store temporary data on the server-side that may be used by the same user over multiple requests.

sessions can easily be managed through the *HttpClient*'s *session* properties.

Views and controllers have access to the current client by either the *view.client* or *client* property.

Session values can be of any data-type ranging from strings to classes.

To set a value in the session you must call *setValue()*.
To get a value in the session you must call *getValue()*.
To check if a value is present in the session you must call *hasValue()*.
To remove a value from the session you must call *removeValue()*.
To clear all values you must call *clearValues()*

Example:

```
client.session.setValue("mySessionValue", "Hello World!");

...

string mySessionValue = client.session.getValue("mySessionValue");

...

string mySessionValue = client.session.getValue("mySessionValue", "A default value when mySessionValue isn't present.");

...

if (client.session.hasValue("mySessionValue"))
{
    // Do stuff when "mySessionValue" is present in the session.
}

...

client.session.removeValue("mySessionValue");

...

client.session.clearValues();
```


