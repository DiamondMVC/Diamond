[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contrbuting)

<br>

**Diamond** is a full-stack cross-platform  **MVC / Template Framework** written in the **D Programming Language**.

It's inspired by **ASP.NET** and uses **[vibe.d](http://vibed.org/)** for its backend, making **Diamond** a very powerful framework.

## Features

|General Features|Data & Storage|Views & Frontend|Controllers|More|Upcoming|
|---|:---:|:---:|:---:|:---:|---:|
| Low Memory & CPU Consumption | ORM | Compile-time Parsing | Auto-mapping | Authentication | Transactions |
| MVC & HMVC | MySql ORM | Partial Views | View-integration | CSRF Protection | Unittesting |
| RESTful | Caching | Layouts | Mandatory Actions | Cryptography | Logging |
| Advanced Routing | Mongo | Fast & Performant Rendering |  | JSON/BSON | Flash-messages |
| ACL | Redis | Dynamic |  | Asynchronous | Version-control |
| Cross-platform | Request-context | Any D Code Can Be Executed |  | Fibers/Tasks | Localization |
| Website/Webapi Support | Cookies |  |  | Sharding |  |
|  | Sessions |  |  | Network Security & Restrictions |  |

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



## Joining

You can join the development of Diamond at **[Github](https://github.com/DiamondMVC/Diamond/)**
