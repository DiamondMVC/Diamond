[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contrbuting)

<br>

**Diamond** is a full-stack cross-platform  **MVC / Template Framework** written in the **D Programming Language**.

It's inspired by **ASP.NET** and uses **[vibe.d](http://vibed.org/)** for its backend, making **Diamond** a very powerful framework.

## Feature Overview

|General Features|Data & Storage|Views & Frontend|Controllers|More|Upcoming|
|:---:|:---:|:---:|:---:|:---:|:---:|
| [Low Memory & CPU Consumption](#low-memory--cpu-consumption) | [ORM](#orm) | [Compile-time Parsing](#compile-time-parsing) | [Auto-mapping](#auto-mapping) | [Authentication](#authentication) | [Transactions](#transactions) |
| [MVC & HMVC](#mvc--hmvc) | [MySql ORM](#mysql-orm) | [Partial Views](#partial-views) | [View-integration](#view-integration) | [CSRF Protection](#csrf-protection) | [Unittesting](#unittesting) |
| [RESTful](#restful) | [Caching](#caching) | [Layouts](#layouts) | [Mandatory Actions](#mandatory-actions) | [Cryptography](#cryptography) | [Logging](#logging) |
| [Advanced Routing](#advanced-routing) | [Mongo](#mongo) | [Fast & Performant Rendering](#fast--performant-rendering) | | [JSON/BSON](#jsonbson) | [Flash-messages](#flash-messages) |
| [ACL](#acl) | [Redis](#redis) | [Dynamic](#dynamic) | | [Asynchronous](#asynchronous) | [Version-control](#version-control) |
| [Cross-platform](#cross-platform) | [Request-context](#request-context) | [Any D Code Can Be Executed](#any-d-code-can-be-executed) | | [Fibers/Tasks](#fiberstasks) | [Localization](#localization) |
| [Website/Webapi Support](#websitewebapi-support) | [Cookies](#cookies) | | | [Sharding](#sharding) |
| | [Sessions](#sessions) | | | [Network Security & Restrictions](#network-security--restrictions) | |

## General Features

### Low Memory & CPU Consumption

Diamond uses vibe.d as backend for processing requests, which currently processes more requests than any other frameworks. At the same time Diamond is written in D and utilizes D's compile-time facilities and thus keeps as little overhead at run-time as possible. The memory consumption is low, because Diamond doesn't store much more data in memory than requested, except for minimal session/cookie/request data. The CPU consumption is kept to a minimum, because of how vibe.d works with its asynchronous fiber model.

### MVC & HMVC

Diamond has a full integrated Model-view-controller implementation which is based on a similar design to ASP.NET. Implementing views, controllers and models is a striaghtforward concept in Diamond and made to feel as natural as possible.

### RESTful

Diamond can be RESTful if necessary. REST integration becomes very powerful & secure with the combination of ACL.

### Advanced Routing

Diamond allows for advanced routing with controller actions, which can be type-secure.

### ACL (Access Control List)

Diamond has a full-fletched build-in ACL implementation. It allows for custom creation of roles and permission control of resources. ACL can be combined with the build-in authentication too.

### Cross-platform

Diamond supports all platforms that both vibe.d & D supports, which includes Windows, Linux, macOS/OSX and more.

### Website/Webapi Support

Diamond has support for both writing websites and/or webapis.

## Data & Storage

### ORM

Diamond has a build-in ORM (Diamond-db) which can be used to map customized data ex. other database-engines.

### MySql ORM

By default Diamond has a build-in ORM for Mysql. It's very powerful since it's based on the native mysql library.

### Caching

Diamond implements a lot of caching techniques behind the scenes. It also allows for custom caching of ex. expensive views.

### Mongo

Diamond has a full integration to Mongo through vibe.d

### Redis

Diamond has a full integration to Redis through vibe.d

### Request-contexts

Diamond supports request contexts which allows for each request to have any type of data carried with them anywhere in the application.

### Cookies

Diamond has a very user-friendly cookie API directly bound to the request's http client.

### Sessions

Diamond supports sessions, which can share data and cached views between multiple requests from the same user/browser.

## Views & Frontend

### Compile-time Parsing

Views are parsed at compile-time and gets compiled into D classes that are executed at run-time. This makes them very powerful, because they don't have to be parsed on each requests, giving them minimal processing only.

### Partial Views

Partial views can easily be implemented by creating normal views and simply calling he render functions from a view to render other vies.

### Layouts

Views can use layout views, which allows for advanced layout techniques and view mixins.

### Fast & Performant Rendering

Views are rendered fast, because most of their rendering is done at compile-time.

### Dynamic

All views are dynamic and thus can render dynamic data.

### Any D Code Can Be Executed

Views allows for any type of D code to be executed with no limits. This includes class generation, templates, functions, and expressions directly in the view. It's very useful to generate powerful and fast dynamic data, since D is natively compiled, so will the code execution for the view be and thus execution times for the code is very fast (On pair with C/C++.)

## Controllers

### Auto-mapping

Controller actions are auto-mapped by their function definitions that are declared with special attributes.

### View-integration

Controllers have access directly to the view that's calling them. They can be shared between multiple views too.

### Mandatory Actions

Controllers allows for mandatory actions, which are actions that are executed and must succeed on every request done to a controller.

## More

### Authentication

Diamond has a full integrated authentication API that can be combined with the ACL to create a strong and secure authentication implementation.

### CSRF Protection

CSRF Protection is build-in to Diamond and cann easily be integrated to forms, as well validated in an application's backend.

### Cryptography

Cryptography is supported through the vibe.d integration.

### JSON/BSON

JSON & BSON is supported through the vibe.d integration, but some high-level json support is done to integrate better with it.

### Asynchronous

Diamond requests are processed asynchrnously through vibe.d, making request processing fast and powerful. Actions etc. can also be executed asynchronously using the API provided by vibe.d.

### Fibers/Tasks

Fibers and tasks are supported through vibe.d allowing for very powerful and performant multi-threading.

### Sharding

Diamond supports multiple database systems such as MySql, Mongo and Redis and integration with them can be done easily without any complexity put into code.

### Network Security & Restrictions

Network security and restrictions can easily be done per controller actions/route or globally for the whole application. This allows to restrict certain areas of the application to ex. a local network; very useful for intern administration websites that are hosted on the same server as a public website.

## Upcoming

### Transactions

Transactions allows for transactional memory management, as well transactional database integration. It's useful to perform secure data transactions where invalid/incomplete data cannot be afforded.

### Unittesting

Unittesting is a must for enterprise development and must be implemented for an application to make sure everything works how it's suppsed to be. Unittesting in Diamond will allow for you to create specialized requests that can target certain areas of your application.

### Logging

Logging is useful to have information available about ex. requests processed with errors, application crash logs etc.

### Flash-messages

Flash-messages are useful to create notification messages in a website.

### Version-control

When building webapis and building a new version you might want to versionate the project, allowing for both an old and a new api to be used. This is useful when you're trying to migrate an application from an old api to a new api, when the new api hasn't yet implemented all the features the old api has.

### Localization

Localization is useful for applications that must be availble in multiple languages. It's a must for international applications.


## Join Diamond

You can join the development of Diamond at **[Github](https://github.com/DiamondMVC/Diamond/)**

You can also join the Diamond discussion at **[Discord](https://discord.gg/UTysCSH)**
