# Starting a Civitas Project

## Goal

This manual explains how an end user starts a new project with Civitas and how that project gets populated over time.

The focus here is not the internal implementation of the framework. The focus is:

- understanding the generated folder structure;
- knowing where user code belongs;
- knowing which directories belong to the local runtime;
- growing the project predictably, without mixing bootstrap, apps, assets, and data.

The contract described here follows the current canonical Civitas scaffold, introduced from the CLI phases onward and refined by the most recent canonical scaffold.

## Overview

When you create a project with Civitas, the initial tree already separates three different concerns:

- project bootstrap: lives in `project/`
- user domain code: lives in `apps/`
- local runtime and operational artifacts: live in `data/` and `.civitas/`

This separation exists to avoid the common problem where small projects grow and end up mixing:

- server entrypoint;
- root routing;
- business rules;
- tests;
- local database;
- cache;
- logs;
- generated files.

In Civitas, the idea is for the project to be born organized so it can grow.

## First Step

Create a new project with the CLI:

```bash
civitas new my_network --template web
```

Or, if you prefer the alias:

```bash
civitas init my_network --template web
```

The templates currently available are:

- `minimal`: the smallest possible tree for bootstrap and basic structure
- `web`: project oriented toward sites, HTML pages, templates, and static assets
- `api`: project oriented toward APIs, serializers, and a minimal admin surface

The scaffold styles currently available are:

- `starter`: the most direct starting point, with a single initial app in `apps/core`
- `layered`: adds folders for `services`, `queries`, `policies`, `jobs`, `contracts`, ADRs, and runbooks
- `domain`: starts the project with separate apps for `public`, `accounts`, `backoffice`, and `shared`

Example:

```bash
civitas new my_network --template web --style layered
```

## What the CLI Generates

Example base tree:

```text
my_network/
├── civitas.toml
├── README.md
├── .gitignore
├── project/
│   ├── main.cct
│   └── urls.cct
├── settings/
│   ├── base.toml
│   ├── dev.toml
│   └── prod.toml
├── apps/
│   └── core/
│       ├── urls.cct
│       ├── models/
│       │   └── index.cct
│       ├── views/
│       │   └── index.cct
│       ├── routes/
│       │   └── .keep
│       ├── admin/
│       │   └── index.cct
│       ├── serializers/
│       │   └── index.cct
│       └── tests/
│           └── test_core.cct
├── templates/
├── static/
├── migrations/
├── tests/
├── data/
│   ├── db/
│   ├── media/
│   ├── logs/
│   └── backups/
└── .civitas/
    ├── build/
    ├── cache/
    ├── reports/
    ├── profiles/
    ├── bench/
    └── mem/
```

Not every template creates exactly all the files above, but that is the structural idea.

When the style is `layered`, the tree also gains:

- `apps/core/services/`
- `apps/core/queries/`
- `apps/core/policies/`
- `apps/core/jobs/`
- `apps/core/contracts/`
- `docs/adr/`
- `docs/runbooks/`
- `ops/environments/`

When the style is `domain`, the tree starts with:

- `apps/public/`
- `apps/accounts/`
- `apps/backoffice/`
- `apps/shared/`

## How to Read the Tree

### `project/`

This is where the project bootstrap lives.

Main files:

- `project/main.cct`
- `project/urls.cct`

Think of `project/` as the layer that ties everything together:

- it configures the entrypoint;
- it aggregates the root URL tree;
- it wires the project to the apps.

Practical rule:

- if a file exists to start the entire project, it tends to live in `project/`
- if a file represents business functionality, it tends to live in `apps/`

### `apps/`

This is where user code lives.

The scaffold starts with `apps/core`, but the idea is that you can grow into new apps as the project matures.

Examples of future apps:

- `apps/accounts`
- `apps/feed`
- `apps/editorial`
- `apps/billing`
- `apps/community`

`apps/core` exists to avoid the initial void. It functions as the project’s first app.

If the project was created with `--style domain`, the growth already starts separated:

- `apps/public`: public surfaces, home, landing pages, open content
- `apps/accounts`: signup, authentication, profile, preferences
- `apps/backoffice`: internal operations, admin, and protected routes
- `apps/shared`: common code reused by more than one app

If the project was created with `--style layered`, the tendency is to keep the main app together for longer while disciplining the internal code with:

- `services/` for use cases;
- `queries/` for reads;
- `policies/` for access and decision rules;
- `jobs/` for asynchronous work;
- `contracts/` for internal app boundaries.

### `settings/`

This is where auxiliary per-environment configuration files live.

They do not replace `civitas.toml`. The primary manifest remains `civitas.toml`.

Use `settings/` to organize:

- base configuration;
- development differences;
- production differences.

### `templates/` and `static/`

This is where the user-facing web surface lives.

Use:

- `templates/` for HTML
- `static/` for CSS, JS, and project images

### `migrations/`

This is where the project SQL migrations go.

They are part of the versioned code, not of runtime state.

### `tests/`

This is where project tests live.

The scaffold already separates:

- `apps/core/tests/` for tests close to the app
- `tests/` for broader project tests

### `data/`

This is where local runtime data lives.

Examples:

- local SQLite database
- uploads
- logs
- backups

Practical rule:

- `data/` is not a place for code
- `data/` is not a place for templates
- `data/` is not a place for user CCT modules

### `.civitas/`

This is where internal framework artifacts live.

Examples:

- build
- cache
- reports
- profiles
- auxiliary memory

Practical rule:

- the user normally should not place their own code inside `.civitas/`

## The Role of Each Initial File

### `civitas.toml`

It is the main project manifest.

In the current scaffold, it already points to the canonical layout:

- `project.entry = "project/main.cct"`
- `dev.src_dir = "."`
- `database.url = "data/db/<app>.db"`
- `dirs.models = "apps/core/models"`
- `dirs.handlers = "apps/core/views"`
- `dirs.routes = "apps/core/routes"`

That means the project is born already aligned with the real Civitas tree.

### `project/main.cct`

It is the canonical entrypoint.

In the zero state, it intentionally starts simple and commented. Its function is to be the place where the user wires:

- configuration;
- app;
- router;
- server;
- middleware;
- any additional project bootstrap.

It is not a business file. It is a composition file.

### `project/urls.cct`

It is the root URL tree.

Think of it as the central point that decides:

- which apps enter the project;
- under which prefixes they enter;
- how the route hierarchy grows.

Example of growth:

```text
project/urls.cct
  ├── apps/core/urls.cct
  ├── apps/accounts/urls.cct
  ├── apps/feed/urls.cct
  └── apps/admin_panel/urls.cct
```

### `apps/core/urls.cct`

It is the route tree of the base app.

If the project is small, you can stay with only `apps/core` for quite a long time.

When the project grows, `apps/core` stops being “the whole project” and becomes only one app among several.

### `apps/core/views/index.cct`

It is an initial point for handlers/views.

Use this file for the zero state, but do not be afraid to split it into more files as the project grows:

- `views/home.cct`
- `views/account_login.cct`
- `views/account_register.cct`
- `views/feed_list.cct`

### `apps/core/models/index.cct`

It is the initial point for domain models.

If the project grows, the normal path is to split it into:

- `models/user.cct`
- `models/post.cct`
- `models/comment.cct`

### `apps/core/routes/`

This is where generated or hand-written route modules live.

The API generator writes here.

### `apps/core/admin/`

This is where registrations and extensions of the administrative surface live.

### `apps/core/serializers/`

This is where serializers for API and export live.

## How the User Populates the Project

The best way to grow a Civitas project is to follow a simple order:

1. minimal bootstrap
2. first functional app
3. models
4. views and routes
5. templates or serializers
6. migrations
7. tests
8. split into new apps when the domain grows

## Step 1: Minimal Bootstrap

Start by keeping `project/main.cct` and `project/urls.cct` consistent.

The first goal is not to have everything ready. It is to have a clear entrypoint.

Initial checklist:

- `project/main.cct` compiles
- `project/urls.cct` imports `apps/core/urls.cct`
- `apps/core/views/index.cct` can answer something simple

## Step 2: First Feature in `apps/core`

Before creating several apps, deliver one simple feature in `apps/core`.

Examples:

- institutional homepage
- health/status page
- first public listing
- simple internal dashboard

This helps consolidate:

- route flow;
- view flow;
- template or JSON usage;
- test structure.

## Step 3: Create Models

When the project needs persistence, you can create models manually or with the generator.

Example:

```bash
civitas generate model Post title:VERBUM body:VERBUM published:VERUM
```

That writes to:

- `apps/core/models/post.cct`
- `migrations/NNNN_create_post.sql`

Practical rule:

- models live in `apps/<app>/models/`
- migrations live in `migrations/`

## Step 4: Create API or Routes

If you want to generate a base for listing/CRUD/API:

```bash
civitas generate api Post
```

That writes to:

- `apps/core/views/post.cct`
- `apps/core/routes/post.cct`
- updates `apps/core/urls.cct`

The generator helps, but it does not replace project design. It delivers a starting point.

## Step 5: Wire Routes in a Hierarchical Tree

The canonical URL growth model in Civitas is hierarchical.

Example:

```text
project/urls.cct
  ├── /                 -> apps/core
  ├── /conta            -> apps/accounts
  ├── /feed             -> apps/feed
  ├── /admin            -> apps/backoffice
  └── /api              -> apps/api_public
```

That is:

- `project/urls.cct` organizes the global map
- each app owns its own subtree

This model prevents one single route file from growing without control.

## Step 6: Create New Apps

When `apps/core` starts concentrating too many responsibilities, create new apps.

A simple criterion:

- if an area has its own model, view, rules, and routes, it probably deserves its own app

Example of organization:

```text
apps/
├── core/
├── accounts/
├── feed/
├── editorial/
└── community/
```

For each new app, repeat the pattern:

- `models/`
- `views/`
- `routes/`
- `admin/`
- `serializers/`
- `tests/`
- `urls.cct`

## Step 7: Templates, Static, and Visual Layout

If the project is web-oriented, use:

- `templates/base.html` as the base layout
- `templates/<app>/...` for per-app screens
- `static/css/`, `static/js/`, and `static/img/` for assets

Recommended organization:

```text
templates/
├── base.html
├── core/
├── accounts/
└── feed/
```

And:

```text
static/
├── css/
├── js/
└── img/
```

Practical rule:

- template follows the HTML surface
- model follows the domain
- route follows endpoint composition

## Step 8: Database, Migrations, and Local Data

Use the management commands to evolve schema and data:

```bash
civitas migrate
civitas rollback 1
civitas seed
```

The scaffold’s default local database lives at:

```text
data/db/<project_name>.db
```

Do not mix database, uploads, and cache with application code.

## Step 9: Diagnostics and Local Operation

Useful commands in the early lifecycle:

```bash
civitas doctor
civitas test
civitas collect_static
civitas create_superuser
```

Practical use:

- `doctor`: checks whether the project is minimally healthy
- `test`: runs the project suite
- `collect_static`: prepares static assets for publication
- `create_superuser`: initializes administrative access

## Example of Real Growth

Imagine a local social-network project called `bairro_vivo`.

Initial state:

- `apps/core` answers the homepage and an “about” page

First evolution:

- create `Post` model
- generate API for `Post`
- create listing template

Second evolution:

- create `accounts` app
- move login, signup, and profile there

Third evolution:

- create `community` app
- move comments, reactions, and follows there

Fourth evolution:

- create `editorial` app
- move pages, feed, and sitemap there

The result is a project that remains predictable:

- `project/` composes
- `apps/` implements
- `settings/` organizes configuration
- `data/` stores runtime
- `.civitas/` stores internal artifacts

## What Goes Where

Quick summary:

- `project/`: project entrypoint and root URL tree
- `apps/<app>/models/`: domain entities and schema
- `apps/<app>/views/`: handlers and HTTP behavior
- `apps/<app>/routes/`: route modules
- `apps/<app>/urls.cct`: internal aggregation of the app
- `apps/<app>/admin/`: administrative surface
- `apps/<app>/serializers/`: API and export
- `apps/<app>/tests/`: tests close to the app
- `templates/`: user HTML
- `static/`: user CSS, JS, and images
- `migrations/`: versioned SQL
- `tests/`: broader project tests
- `data/`: local database, media, logs, backups
- `.civitas/`: cache, build, and framework artifacts

## Anti-Patterns to Avoid

- putting user code inside `.civitas/`
- using `data/` as a code folder
- letting the whole application grow inside `project/main.cct`
- using `apps/core` as an infinite dumping ground
- mixing routes from every area in a single file with no per-app subtrees
- treating generators as a substitute for architecture

## Recommended Sequence for a New Project

```bash
civitas new my_network --template web
cd my_network
civitas doctor
civitas generate model Post title:VERBUM body:VERBUM published:VERUM
civitas generate api Post
civitas migrate
civitas test
```

After that, the natural path is:

1. adjust `project/main.cct`
2. consolidate `project/urls.cct`
3. implement `apps/core`
4. split the domain into new apps as the project grows

## Closing

The current Civitas scaffold does not try to hide the project architecture. It does the opposite: from the first minute, it makes explicit what is:

- project structure;
- user code;
- local runtime;
- internal framework artifact.

If you follow this separation from the beginning, the project grows with less friction, less mixing of responsibilities, and less late structural refactoring.
