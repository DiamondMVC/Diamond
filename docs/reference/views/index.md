[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Syntax Reference

## Code Block

```
@{
	// Any piece of D code will fit here
	// You can declare functions, classes, variables etc.
}
```

### Example

```
@{
	auto getFoo()
	{
		return "bar";
	}
}
```

## Escaping Text

```
@(Text or symbols to escape, this can even be D code or Diamond expressions)
```

### Example

```
@(<span>The tags are escaped</span>)
```

## Escaping Variables/Expressions

```
@$=variable_to_escape;
@$=(expression_to_escape);
```

### Example

```
@:auto foo = "<span>Bar</span>";
@$=foo;
```

## Unescaped Variable/Expression

```
@=variable_to_not_escape;
@=(expression_to_not_escape);
```

### Example

```
@:auto foo = "<span>Bar</span>";
@=foo;
```

## Linear expressions

```
@:linear_code

@:linear_code {
	Html or Diamond expressions here
}

// Linear code will work with nested {}, [] or ()
```

### Example

```
@:foreach (person; persons) {
	<span>Person: @=person.name;</span>
}
```

## Comments

```
@* Comment here *

@*
	Comment here
*
```

Alternative using linear expressions

```
@:// Comment here
```

### Example

```
@*
   Hello World!
*
```

## Metadata Block

```
@[
	// Metadata here
]
```

### Example

```
@[
    layout:
        layout
---
    route:
        home
]
```

## Placeholders

```
@<placeholder_here>
```

### Example

```
@<title>
```

## Sections

```
@!sectionName:

// This will create a default section
@!:
```

### Example

view1:
```
@!phone:
<div class="phone">
    <p>Hello Phone!</p>
</div>

@!desktop:
<div class="desktop">
    <p>Hello Desktop!</p>
</div>
```

view2:
```
@:render("view1", "phone"); // Will render view1 with the phone section
@:render("view1", "desktop"); // Will render view1 with the desktop section
```

# Example View

### Layout

```
@<doctype>
<html>
<head>
  <title>@<title></title>
</head>
<body>
  @<view>
</body>
</html>
```

### View

```
@[
  layout:
    layout
---
  controller:
    HomeController
---
  model:
    Home
---
  route:
    home
---
  placeHolders:
    [
      "title": "Home"
    ]
]

The time is: <b>@=Clock.currTime();</b>

@:if (model) {
  <span>Passed a model with: @=model.foo;</span>
}
@:else {
  <span>Passed no model.</span>
}
```

# Comparison With ASP.NET Razor

Based on: [http://haacked.com/archive/2011/01/06/razor-syntax-quick-reference.aspx/](http://haacked.com/archive/2011/01/06/razor-syntax-quick-reference.aspx/)

## Code Block

### Razor

```
     @{
          int x = 123; 
          string y = "because.";
     }
```

### Diamond

```
    @{
         int x = 123; 
         string y = "because.";
    }
```

## Expression (Html Encoded)

### Razor

```
    <span>@model.Message</span>
```

### Diamond

```
    @(Text to encode)

    @$=model.message;
```

## Expression (Unencoded)

### Razor

```
    <span>
      @Html.Raw(model.Message)
    </span>
```

### Diamond

```
    <span>
      @=model.message;
    </span>
```

## Combining Text and markup

### Razor

```
    @foreach(var item in items) {
      <span>@item.Prop</span>
    }
```

### Diamond

```
    @:foreach(item; items) {
      <span>@=item.prop;</span>
    }
```

## Mixin code and Plain text

### Razor

```
    @if (foo) {
      <text>Plain Text</text>
    }
```

### Diamond

```
    @:if (foo) {
      <text>Plain Text</text>
    }
```

## Mixin code and plain text (alternate)

### Razor

```
    @if (foo) {
      @:Plain Text is @bar
    }
```

### Diamond

```
    @:if (foo) {
      Plain Text is @@bar;
    }
```

## Email addresses

### Razor

```
    Hi philha@example.com
```

### Diamond

```
    Hi philha@example.com
```

## Explicit Expression

### Razor

```
    <span>ISBN@(isbnNumber)</span>
```

### Diamond

```
    <span>ISBN@=isbnNumber;</span>
```

## Escaping the @ sign

### Razor

```
    <span>In Razor, you use the @@foo to display the value of foo</span>
```

### Diamond

*Some cases might let you write @ and not @@*

```
    <span>In Diamond, you use the @@foo to display the value of foo</span>
```

## Server side Comment

### Razor

```
    @*
      This is a server side
      multiline comment
    *@
```

### Diamond

```
    @*
      This is a server side
      multiline comment
    *
```

## Calling generic method

### Razor

```
    @(MyClass.MyMethod<AType>())
```

### Diamond

```
    @:MyClass.myMethod!AType();
```

## Creating a Razor Delegate

### Razor

```
    @{
      Func<dynamic, object> b =
        @<strong>@item</strong>;
    }
    @b("Bold this");
```

### Diamond

*In Diamond it isn't necessary to create delegates. Diamond let's you integrate any D code and thus you can create normal functions

```
    @:void b(T)(T item) {
        <strong>@=item;</strong>
    }
    @:b("Bold this");
```

## Mixing expression and text

### Razor

```
    Hello @title. @name.
```

### Diamond

```
    Hello @=title;. @=name;.
```
