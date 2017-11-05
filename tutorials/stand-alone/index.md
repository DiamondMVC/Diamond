[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Using Diamond stand-alone

## Project Structure

Create a new folder for your project.
Ex. diamondproject

Create the following folders and files within it.
(Don't worry about content right now.)

* /diamondproject
    * /config
        * views.config
    * /src
        * main.d
    * /models
        * package.d
    * /views
        * test.dd
    * dub.json

Below is all the content for the files.
Just copy-paste it into the files.
Explanations of them are right below.

## dub.json
```
	{
		"name": "diamondproject",
		"description": "A diamond stand-alone project",
		"authors": ["Jacob Jensen"],
		"homepage": "http://mydiamondwebsiteproject.com/",
		"license": "http://mydiamondwebsiteproject.com/license",
		"dependencies": {
			"diamond": "~>2.4.5"
		},
		"sourcePaths": ["src", "models"],
		"stringImportPaths": ["views", "config"],
		"targetType": "executable"
	}
```

*name* is the name of the project.

*description* is the description of the project.

*authors* are the authors of the project.

*homepage* is the homepage of the project.

*license* is the license of the project.

*dependencies* are the dependencies of the project. Diamond as stand-alone has no dependencies.

*sourcePaths* are all paths that dub will look for code. By defualt Diamond only uses core, models and controllers.

*stringImportPaths* are all paths dub will look for string imports. By default Diamond only uses config.

*targetType* are the type of the output. For a Diamond project, it'll typically be executable.


## config/views.config

```
test|test.dd
```

Views should be separated per line with the following format:

```
{name}|{file}
```

The file must be located in a path specified in *stringImportPaths*. By default the folder used is *views*

## models/package.d

```
	module models;

	public
	{
		// TODO: Import models here ...
	}
```

Just like a Diamond webserver, models must be declared within the models package. Otherwise Diamond can't tie views and their models together.

## views/home.dd

```
	@*The test view*
	<p> Hello World!</p>
```

### Notice for views

The first block you encounter is the metadata block.
The metadata block is used to declare metadata configurations for the view.
It's entirely optional to have a metadata block and usually not declared for partial views. Unless they need static place holders. All members of the metadata block are optional.
Each member must be separated by a line of "---"

*layout* is the name of the view to use as a layout page.

*model* is the name of the model to use for the view.

*placeHolders* is an associative array of place-holders. It supports the full associative array syntax in D as it translates it directly as such.

Please view the website guide for an example on metadata implementation.
## src/main.d

```
    module main;

    import diamondapp : getView;

    void main()
    {
      import std.stdio;

      auto view = getView("test");

      writeln(view.generate());
      readln();
    }
```

## Building

To compile the project simply use the following dub command

```
    dub build
```
