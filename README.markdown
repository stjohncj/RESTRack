# RESTRack
- serving JSON and XML with REST and pleasure.

## Description:
RESTRack is a [Rack](http://rack.rubyforge.org/)-based [MVC](http://en.wikipedia.org/wiki/Model%E2%80%93View%E2%80%93Controller)
framework that makes it extremely easy to develop [REST](http://en.wikipedia.org/wiki/Representational_State_Transfer)ful
data services. It is inspired by [Rails](http://rubyonrails.org), and follows a few of its conventions.  But it has no routes
file, routing relationships are done through supplying custom code blocks to class methods such as "has\_relationship\_to" or
"has\_mapped\_relationships\_to".

RESTRack aims at being lightweight and easy to use.  It will automatically render [JSON](http://www.json.org/) and
[XML](http://www.w3.org/XML/) for the data structures you return in your actions \(any structure parsable by the
"[json](http://flori.github.com/json/)" and "[xml-simple](https://github.com/maik/xml-simple)" gems, respectively\).

If you supply a view for a controller action, you do that using a builder file.  Builder files are stored in the
view directory grouped by controller name subdirectories \(`view/<controller>/<action>.xml.builder`\).  XML format
requests will then render the view template with the builder gem, rather than generating XML with XmlSimple.


## Installation:
### Using [RubyGems](http://rubygems.org):
    <sudo> gem install restrack


## Why RESTRack when there is Rails?
[Rails](http://rubyonrails.org/) is a powerful tool for full web applications.  RESTRack is targeted at making
development of lightweight data services as easy as possible, while still giving you a performant and extensible
framework.  The primary goal of of the development of RESTRack was to add as little as possible to the framework to give
the web developer a good application space for developing JSON and XML services.

Rails 3 instantiates approximately 80K more objects than RESTRack to do a hello world or nothing type response with
the default setup.  Trimming Rails down by eliminating ActiveRecord, ActionMailer, and ActiveResource, it still
instantiates over 47K more objects than RESTRack.

## OK, so why RESTRack when there is Sinatra?
RESTRack provides a full, albeit small, framework for developing RESTful MVC applications.


## CLI Usage:
### Generate a new service \(FooBar::WebService\)
  - restrack generate service foo\_bar
  - restrack gen serv foo\_bar
  - restrack g s foo\_bar

### Generate a new controller \(FooBar::BazController\)
  - restrack generate controller baz
  - restrack gen cont baz
  - restrack g c baz

### Generate a new controller that descends from another \(FooBar::NewController < FooBar::BazController\)
  - restrack generate controller new descendant\_from baz
  - restrack g controller new parent baz

### Start up a server on default rackup port 9292
  - restrack server

### Start up a server on port 3456
  - restrack server 3456
  - restrack s 3456


## REST action method names
All default RESTful controller method names align with their Rails counterparts, with two additional actions being
supported\(\*\).

                         HTTP Verb: |   GET   |   PUT    |   POST   |   DELETE
        Collection URI (/widgets/): |  index  |  replace |  create  |  *drop
        Element URI  (/widgets/42): |  show   |  update  |  *add    |  destroy


## Automatic response data serialization
### JSON
Objects returned from resource controller methods will have the "to\_json" method called to serialize response output.
Controllers should return objects that respond to "to\_json".  RESTRack includes the JSON gem, which implements this method
on Ruby's standard lib simple data types (Array, Hash, String etc).

    # GET /widgets/42.json
    def show(id) # id will be 42
        widget = Widget.find(id)
        return widget
        # The widget.to_json will be called and the resultant JSON sent as response body.
    end

    # GET /widgets/42
    def show(id) # id will be 42
        widget = Widget.find(id)
        return widget
        # The widget.to_json will be called unless the default response type is set to :XML in config/constants.yaml,
        # in which case the widget.to_xml method will be called.
    end

### XML
RESTRack will convert the data structures that your actions return to JSON by default.  You can change the default
by setting :DEFAULT_FORMAT to :XML in `config/constants.yml`.

#### With Builder
Custom XML serialization can be done by providing [Builder](http://builder.rubyforge.org/) gem templates in `views/<controller>/<action>.xml.builder`.

#### Custom Serialization Method
When XML is requested, objects returned from resource controller methods will have the "to_xml" method called to serialize
response output if an XML builder template file is not provided.  If the response object does not respond to "to_xml", then
the object will be sent to XmlSimple for serialization.

#### With XmlSimple
RESTRack will attempt to serialize the data structures that your action methods return automatically using the
xml-simple gem.  Complex objects may not serialize correctly, or you may want to define a particular structure for your
XML, in which case a builder template should be defined.

    # GET /widgets/42.xml
    def show(id) # id will be 42
        widget = Widget.find(id)
        return widget
        # Template file views/widgets/show.xml.builder will be used to render the XML if it exists.
        # If not, the widget.to_xml method will be called and the resultant XML sent as response body,
        # or, if widget does not respond to "to_xml", then XmlSimple will be used to serialize the data object.
    end


## Accepting parameters and generating a response
Input parameters are accessible through the @params object.  This is a merged hash containing the POST and GET parameters,
which can be accessed separately through @post_params and @get_params.

    # GET /widgets/list.xml?offset=100&limit=50
    def list
        widget_list = Widget.limit( @params['limit'], @params['offset'] )
        return widget_list
    end


## URLs and Controller relationships
RESTRack enforces a strict URL pattern through the construct of controller relationships, rather than a routing file.
Defining a controller for a resource means that you plan to expose that resource to requests to your service.
Defining a controller relationship means that you plan to expose a path from this resource to another.

### "pass\_through\_to"
An open, or pass-through, path can be defined via the "pass\_through\_to" class method for resource controllers.  This
exposes URL patterns like the following:

    GET /foo/123/bar/234        <= simple pass-through from Foo 123 to show Bar 234
    GET /foo/123/bar            <= simple pass-through from Foo 123 to Bar index

### "has\_relationship\_to"
A direct path to a single related resource's controller can be defined with the "has\_relationship\_to" method.  This
allows you to define a one-to-one relationship from this resource to a related resource, which means that the id of
the related resource is implied through the id of the caller.  The caller has one relation through a custom code block
passed to "has\_relationship\_to".  The code block takes the caller resource's id and evaluates to the relation
resource's id, for example a PeopleController might define a one-to-one relationship like so:

        has_relationship_to( :people, :as spouse ) do |id|
          People.find(id).spouse.id
        end

This exposes URL patterns like the following:

    GET /people/Sally/spouse    <= direct route to show Sally's spouse
    PUT /people/Henry/spouse    <= direct route to update Henry's spouse
    POST /people/Jane/spouse    <= direct route to add Jane's spouse

### "has\_relationships\_to" and "has\_defined\_relationships\_to"
A direct path to many related resources' controller can be defined with the "has\_relationships\_to" and
"has\_defined\_relationships\_to" methods.  These allows you to define one-to-many relationships.  They work similar to
"has\_relationship\_to", except that they accept code blocks which evaluate to arrays of related child ids.  Each
resource in the parent's relation list is then accessed through its array index (zero-based) in the URL.  An example
of exposing the list of a People resource's children in this manner follows:

      has_relationships_to( :people, :as => children ) do |id|
        People.find(id).children.collect {|child| child.id}
      end

Which exposes URLs similar to:

    GET /people/Nancy/children/0          <= direct route to show child 0
    DELETE /people/Robert/children/100    <= direct route to destroy child 100

An example of "has\_defined\_relationships\_to":

        has_defined_relationships_to( :people, :as => children ) do |id|
          People.find(id).children.collect {|child| child.id}
        end

exposes URL patterns:

    GET /people/Nancy/children/George     <= route to show child George
    DELETE /people/Robert/children/Jerry  <= route to destroy child Jerry

### "has\_mapped\_relationships\_to"
Multiple named one-to-many relationships can be exposed with the "has\_mapped\_relationships\_to" method.  This allows
you to define many named or keyword paths to related resources.  The method's code block should accepts the parent id
and return a hash where the keys are your relationship names and the values are the child resource ids.  For example,
within a PeopleController the following definition:

        has_mapped_relationships_to( :people ) do |id|
          {
            'father'    => People.find(id).father.id,
            'mother'    => People.find(id).mother.id,
            'boss'      => People.find(id).boss.id,
            'assistant' => People.find(id).assistant.id
          }
        end

This would expose the following URL patterns:

    GET /people/Fred/people/father      => show the father of Fred
    PUT /people/Fred/people/assistant   => update Fred's assistant
    POST /people/Fred/people/boss       => add Fred's boss
    DELETE /people/Luke/people/mother   => destroy Luke's father

### Setting the data type of the id - "keyed\_with\_type"
Resource id data types can be defined with the "keyed\_with\_type" class method within resource controllers.  The
default data type of String is used if a different type is not specified.


## Logging/Logging Level
RESTRack outputs to two logs, the standard log (or error log) and the request log.  Paths and logging levels for these
can be configured in `config/constants.yaml`.  RESTRack uses Logger from Ruby-stdlib.


## Inputs

### Query string parameters
Available to controllers in the `@params` instance variable.

### POST data
Available to controllers in the `@input` instance variable.


## Constant Definition \(`config/constants.yaml`\)

### Required Configuration Settings
#### :LOG
Sets the location of the error log.

#### :REQUEST\_LOG
Sets the location of the request log.

#### :LOG\_LEVEL
Sets the the logging level of the error log, based on the Ruby Logger object.  Supply these as a symbol, with valid
values being :DEBUG, :INFO, :WARN, etc.

#### :REQUEST\_LOG\_LEVEL
Sets the the logging level of the request log, similar to :LOG\_LEVEL.

### Optional Configuration Settings
#### :DEFAULT\_FORMAT
Sets the default format for the response.  This is the format that the response will take if no extension is appended to
the request string \(i.e. `/foo/123` rather than `/foo/123.xml`\).  Services will have a default format of JSON if this
configuration option is not defined.

#### :DEFAULT\_RESOURCE
Set this option in config/constants.yaml to use an implied root resource controller.  To make `/foo/123` also be accessible
at `/123`:

    :DEFAULT_RESOURCE: foo


#### :ROOT\_RESOURCE\_ACCEPT
This defines an array of resources that can be accessed as the first resource in the URL chain, without being proxied
through another relation.

    :ROOT_RESOURCE_ACCEPT: [ 'foo', 'bar' ]


#### :ROOT\_RESOURCE\_DENY
This defines an array of resources that cannot be accessed without proxying though another controller.

    :ROOT_RESOURCE_DENY: [ 'baz' ]


#### :SHOW\_STACK
If defined, server error messages will contain the stack trace.  This is not recommended when these errors could possibly
be delivered to the client.

    :SHOW_STACK: true


## License

Copyright (c) 2010 Chris St. John

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
