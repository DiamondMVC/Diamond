[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# i18n

Sometimes you want your application to target multiple languages and cultures.

Diamond implements an easy-to-use i18n API which can be used to localize your application.

i18n is implemented in the module **diamond.data.i18n*.

## Creating a language or culture

### Translations

Translations for a language/culture can be loaded using the function **loadLanguageFile()**.

```
loadLanguageFile("en_us", "localization/en_us.lang"); // Loads an American English translation.
loadLanguageFile("esp", "localization/esp.lang"); // Loads a Spanish translation.
```

The file must use the following format.

**Single-line entries:**

```
MESSAGE_KEY=MESSAGE_VALUE
```

Example:

```
HELLO_WORLD=Hell World!
```

**Multi-line entries:**

```
MESSAGE_KEY:
MESSAGE_VALUE_LINE1
MESSAGE_VALUE_LINE2
;
```

Example:

```
MULTILINE:
This message expands
over multiple
lines
;
```

You can set a default language for the application, but it isn't necessary.

The default language is selected if a session doesn't have a specific language attached.

When messages aren't found for a session's language, the default language is selected.

When no messages for both the specified or the default language can be found, then an empty string is returned.

```
setDefaultLanguage("en_us");
```

To retrieve translations you must call the function **getMessage()*

When you're in a view you don't need to import **diamond.data.i18n**.

That's because all functionality from the module is already available through the view's alias import: **i18n**.

Outside of a view:

```
import diamond.data.i18n; // Or just diamond.data

auto message = getMessage(client, "someMessage"); // Gets message from client ...
auto specificMessage = getMessage("en_us", "someMessage"); // Gets message from a specific language ...
```

Inside of a view:

```
<p>@=i18n.getMessage(client, "someMessage");</p>
<p>@=i18n.getMessage("en_us", "someMessage");</p>
```

## Resources

Certain resources of your application such as images etc. may be different per culture or language.

You can easily control this using the client's language property, which also can be used to set the language of a client and its session.

```
@* Will show the flag depending on the client's language. *
<img src="@../public/images/flags/@=client.language;.png">
```

For ex. **en_us** it will expand to:

```
<img src="@../public/images/flags/en_us.png">
```

For ex. **esp** it will expand to:

```
<img src="@../public/images/flags/esp.png">
```
