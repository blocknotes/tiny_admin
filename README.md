# Tiny Admin

[![Gem Version](https://badge.fury.io/rb/tiny_admin.svg)](https://badge.fury.io/rb/tiny_admin) [![Linters](https://github.com/blocknotes/tiny_admin/actions/workflows/linters.yml/badge.svg)](https://github.com/blocknotes/tiny_admin/actions/workflows/linters.yml) [![Specs Rails 7.0](https://github.com/blocknotes/tiny_admin/actions/workflows/specs_rails_70.yml/badge.svg)](https://github.com/blocknotes/tiny_admin/actions/workflows/specs_rails_70.yml)

A compact and composable dashboard component for Ruby.

Main features:
- a Rack app that can be mounted in any Rack-enabled framework or used standalone;
- structured with plugins also for main components that can be replaced with little effort;
- routing is provided by Roda which is small and performant;
- views are Phlex components, so plain Ruby objects for views, no assets are needed.

Please ⭐ if you like it.

![screenshot](extra/screenshot.png)

## Install

- Add to your Gemfile: `gem 'tiny_admin', '~> 0.5'`
- Mount the app in a route (check some examples with: Hanami, Rails, Roda and standalone in [extra](extra))
  + in Rails, update _config/routes.rb_: `mount TinyAdmin::Router => '/admin'`
- Configure the dashboard using `TinyAdmin.configure` and/or `TinyAdmin.configure_from_file` with a YAML config file (see [configuration](#configuration) below):

```rb
TinyAdmin.configure do |settings|
  settings.root = {
    title: 'Home',
    page: Admin::PageRoot
  }
end
```

## Plugins and components

### Authentication

Plugins available:

- **SimpleAuth**: a session authentication based on Warden (`warden` gem must be included in the Gemfile) using a password hash provided via config or via environment variable (`ADMIN_PASSWORD_HASH`). _Disclaimer: this plugin is provided as example, if you need a secure authentication I suggest to create your own._

- **NoAuth**: no authentication.

### Repository

Plugin available:

- **ActiveRecordRepository**: isolates the query layer to expose the resources in the admin interface.

### View pages

Pages available:

- **Root**: define how to present the content in the main page of the interface;
- **PageNotFound**: define how to present pages not found;
- **RecordNotFound**: define how to present record not found page;
- **SimpleAuthLogin**: define how to present the login form for SimpleAuth plugin;
- **Index**: define how to present a collection of items;
- **Show**: define how to present the details of an item.

### View components

Components available:

- **FiltersForm**: define how to present the filters form in the resource collection pages;
- **Flash**: define how to present the flash messages;
- **Head**: define how to present the Head tag;
- **Navbar**: define how to present the navbar (the default one uses the Bootstrap structure);
- **Pagination**: define how to present the pagination of a collection.

## Configuration

TinyAdmin can be configured using a YAML file and/or programmatically.
See [extra](extra) folder for some usage examples.

The following options are supported:

`root` (Hash): define the root section of the admin, properties:

- `title` (String): root section's title;
- `page` (String): a view object to render;
- `redirect` (String): alternative to _page_ option - redirects to a specific slug;

Example:

```yml
root:
  title: MyAdmin
  redirect: posts
```

`helper_class` (String): class or module with helper methods, used for attributes' formatters.

`page_not_found` (String): a view object to render when a missing page is requested.

`record_not_found` (String): a view object to render when a missing record is requested.

`style_links` (Array of hashes): list of styles files to include, properties:

- `href` (String): URL for the style file;
- `rel` (String): type of style file.

`scripts` (Array of hashes): list of scripts to include, properties:

- `src` (String): source URL for the script.

`extra_styles` (String): inline CSS styles.

`authentication` (Hash): define the authentication method, properties:

- `plugin` (String): a plugin class to use (ex. `TinyAdmin::Plugins::SimpleAuth`);
- `password` (String): a password hash used by _SimpleAuth_ plugin (generated with `Digest::SHA512.hexdigest("some password")`).

Example:

```yml
authentication:
  plugin: TinyAdmin::Plugins::SimpleAuth
  password: 'f1891cea80fc05e433c943254c6bdabc159577a02a7395dfebbfbc4f7661d4af56f2d372131a45936de40160007368a56ef216a30cb202c66d3145fd24380906'
```

`sections` (Array of hashes): define the admin sections, properties:

- `slug` (String): section reference identifier;
- `name` (String): section's title;
- `type` (String): the type of section: `url`, `page` or `resource`;
- other properties depends on the section's type.

For _url_ sections:

- `url` (String): the URL to load when clicking on the section's menu item;
- `options` (Hash): properties:
  + `target` (String): link _target_ attributes (ex. `_blank`).

Example:

```yml
slug: google
name: Google.it
type: url
url: https://www.google.it
options:
  target: '_blank'
```

For _page_ sections:

- `page` (String): a view object to render.

Example:

```yml
slug: stats
name: Stats
type: page
page: Admin::Stats
```

For _resource_ sections:

- `model` (String): the class to use to fetch the data on an item of a collection;
- `repository` (String): the class to get the properties related to the model;
- `index` (Hash): collection's action options (see below);
- `show` (Hash): detail's action options (see below);
- `collection_actions` (Array of hashes): custom collection's actions;
- `member_actions` (Array of hashes): custom details's actions;
- `only` (Array of strings): list of supported actions (ex. `index`);
- `options` (Array of strings): resource options (ex. `hidden`).

Example:

```yml
slug: posts
name: Posts
type: resource
model: Post
```

#### Resource index options

The Index hash supports the following options:

- `attributes` (Array): fields to expose in the resource list page;
- `filters` (Array): filter the current listing;
- `links` (Array): custom member actions to expose for each list's entry (defined in _member_actions_);
- `pagination` (Integer): max pages size;
- `sort` (Array): sort options to pass to the listing query.

Example:

```yml
    index:
      sort:
        - id DESC
      pagination: 10
      attributes:
        - id
        - author: call, name
        - position: round, 1
        - field: author_id
          header: The author
          link_to: authors
          call: author, name
      filters:
        - title
        - field: state
          type: select
          values:
            - published
            - draft
            - archived
      links:
        - show
        - author_posts
        - csv_export
```

#### Resource show options

The Show hash supports the following options:

- `attributes` (Array): fields to expose in the resource details page.

Example:

```yml
    show:
      attributes:
        # Expose the id column
        - id
        # Expose the title column, calling `downcase` support method
        - title: downcase
        # Expose the category column, calling `upcase` support method
        - category: upcase
        # Expose the position column, calling `format` support method with argument %f
        - position: format, %f
        # Expose the position created_at, calling `strftime` support method with argument %Y%m%d %H:%M
        - created_at: strftime, %Y%m%d %H:%M
        # Expose the author_id column, with a custom header label, linked to authors section and calling author.name to get the value
        - field: author_id
          header: The author
          link_to: authors
          call: author, name
```

### Sample

```rb
# config/initializers/tiny_admin.rb

config = Rails.root.join('config/tiny_admin.yml').to_s
TinyAdmin.configure_from_file(config)

# Change some settings programmatically
TinyAdmin.configure do |settings|
  settings.authentication[:password] = Digest::SHA512.hexdigest('changeme')
end
```

```yml
# config/tiny_admin.yml
---
authentication:
  plugin: TinyAdmin::Plugins::SimpleAuth
  # password: 'f1891cea80fc05e433c943254c6bdabc159577a02a7395dfebbfbc4f7661d4af56f2d372131a45936de40160007368a56ef216a30cb202c66d3145fd24380906'
root:
  title: Test Admin
  # page: RootPage
helper_class: AdminHelper
page_not_found: PageNotFound
record_not_found: RecordNotFound
sections:
  - slug: google
    name: Google.it
    type: url
    url: https://www.google.it
    options:
      target: _blank
  - slug: sample
    name: Sample page
    type: page
    page: SamplePage
  - slug: authors
    name: Authors
    type: resource
    model: Author
    collection_actions:
      - sample_col: SampleCollectionAction
    member_actions:
      - sample_mem: SampleMemberAction
  - slug: posts
    name: Posts
    type: resource
    model: Post
    index:
      pagination: 5
      attributes:
        - id
        - title
        - field: author_id
          link_to: authors
        - category: upcase
        - state: downcase
        - published
        - position: round, 1
        - dt: to_date
        - field: created_at
          converter: AdminUtils
          method: datetime_formatter
        - updated_at: strftime, %Y%m%d %H:%M
      filters:
        - title
        - author_id
        - field: category
          type: select
          values:
            - news
            - sport
            - tech
        - published
        - dt
        - created_at
    show:
      attributes:
        - id
        - title
        - description
        - field: author_id
          link_to: authors
        - category
        - published
        - position: format, %f
        - dt
        - created_at
style_links:
  - href: /bootstrap.min.css
    rel: stylesheet
scripts:
  - src: /bootstrap.bundle.min.js
extra_styles: >
  .navbar {
    background-color: var(--bs-cyan);
  }
  .main-content {
    background-color: var(--bs-gray-100);
  }
  .main-content a {
    text-decoration: none;
  }
```

## Do you like it? Star it!

If you use this component just star it. A developer is more motivated to improve a project when there is some interest.

Or consider offering me a coffee, it's a small thing but it is greatly appreciated: [about me](https://www.blocknot.es/about-me).

## Contributors

- [Mattia Roccoberton](https://blocknot.es/): author

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
