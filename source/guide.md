Worksheet
=========

### Before starting:

```
$ php app/console server:run
```

### Other useful information

Reset the database:

```
$ ./installation/reset.sh
```

Shop login:

```
u: shop@example.com
p: sylius
```

Admin login:

```
u: admin@example.com
p: sylius
```

---

Blog
----

As a way of exploring the Sylius Resource and Grid bundles we will create a
simple blogging system.

---

### [`initial`] Create Post entity

Create a Doctrine ORM entity to represent a blog post.

1. Create a `Post` entity in `src/AppBundle/Entity/Post.php`.
2. Map the fields `$title`, `$body` and `$publishedAt`.
3. Verify that the entity has been created.

Hints:

- `use Doctrine\ORM\Mapping as ORM`
- `@ORM\Id()`
- `@ORM\GeneratedValue()`
- `@ORM\Column(type="integer")`
- `@ORM\Column(type="string")`
- `@ORM\Column(type="date", nullable=true)`

```bash
$ php app/console doctrine:mapping:info | grep App
```

---

### [`post_entity`] Resource configuration 

Register our Post entity with the resource bundle.

1. The Post entity must implement the ResourceInterface
2. Place file in `app/config/wsc/resources.yml`
3. Configure the model class to be that of the previously created `Post`
  entity.
4. Include it from `app/config.yml`
5. Verify that the resource is registered.

Hints:

- `php app/console config:dump-reference sylius_resource`
- `imports: [ { resource: "wsc/resources.yml" } ]`
- `use Sylius\Component\Resource\Model\ResourceInterface`
- `php app/console sylius:debug:resource`
- `php app/console sylius:debug:resource <your resource name>`


---

### [`resource_configuration`] REST CRUD configuration

Add route configuration which enables a REST API.

1. Create the routing configuration file in `app/config/wsc/routing_api.yml`.
   DO NOT use `/admin` as a prefix here (we don't want security).
2. Import the new routing file from the main `app/config/routing.yml`
3. Configure the FOS REST bundle
4. Create a new resource with the `curl` command.
5. View the resource with the `curl` command.

Hints:

```yaml
app_admin_post_api:
    resource: |
        alias: <resource name>
        except: [ "index" ] # do not generate these routes
        <something here>
    type: sylius.resource_api
    prefix: <route prefix, e.g. admin-api (do not use admin!)>
```

```bash
$ curl -i -X POST -H "Content-Type: application/json" -d '{"title": "...", ...}' http://127.0.0.1:8000/<your prefix>/posts/
```

```bash
$ curl -i -X GET -H "Content-Type: application/json" http://127.0.0.1:8000/app-api/posts/1
```

```yaml
section: api
```

```yaml
fos_rest:
    # ...
    format_listener:
        rules:
            # ...
            - 
                path: '^/<route containing your API>'
                priorities: ['json', 'xml'] # enable JSON and XML
                fallback_format: json       # default to JSON
                prefer_extension: true
```

---

### [`rest_crud`] HTML CRUD configuration

Create the routing for the HTML rest interface.

1. Create the routing configuration for the resource in
   `app/config/wsc/routing.yml`
2. Include the routing from `app/config/routing.yml`
3. Create a new post 
4. Verify the new routes with the console.
5. Try creating a new resource (and expect an exception thereafter).

Hints:

```yaml
<route name>: # include "admin" to avoid conflicts later
    resource: |
        alias: <resource name>
        except: [ "show" ] # do not generate this route
        templates: <template set to use>
    type: sylius.resource
    prefix: <route prefix, e.g. admin>
```

```
SyliusAdminBundle:Crud
```

```bash
$ php app/console debug:router # grep is your friend
```

### [`html_crud`] Grid Configuration

Configure a grid for listing posts (the posts index page).

1. Create the grid configuration file in `app/config/wsc/grids.yml`
2. Add fields for the `title` and `publishedAt` properties of the `Post`
   entity.
3. Enable actions for creating, updating and deleting entries.
4. Associate the grid with the resource in `app/config/wsc/routing.yml`
5. Import the file from the main `app/config/config.yml` file.
6. Navigate to `http://127.0.0.1:8000/admin/posts`
7. Create, update and delete blog posts!

Hints:

```
$ php app/console config:dump-reference sylius_grid
```

```yaml
sylius_grid:
    grids:
        <grid name, e.g. app_post>:
            driver:
                options:
                    class: <class name of the post entity>
            fields:
                <property name for title>:
                    type: string
                <property name for published date>:
                    type: datetime
                    options:
                        format: Y-m-d
```

```yaml
            actions:
                main:
                    create:
                        type: create
                item:
                    update:
                        type: update
                    delete:
                        type: delete
```

```yaml
# routing.yml
<...>:
     resource: |
         # ...
+        grid: app_post
         # ...
     # ...
```

### [`grid_configuration`] Backend Menu

Create a menu item in the admin interface.

1. Create the menu listener.
2. Add the menu listener to the DI configuration (`src/AppBundle/Resources/config/services.yml`)

Hints:

```php
<?php

// ... don't forget the namespace!

use Sylius\Bundle\UiBundle\Menu\Event\MenuBuilderEvent;

class <for example, AdminMenuListener>
{
    public function <method name>(MenuBuilderEvent $event)
    {
        $menu = $event->getMenu();

        $blogMenu = $menu
            ->addChild('blog')
            ->setLabel('Blog');
        $blogMenu
            ->addChild('posts', [ 'route' => '<name of the index route for the
            posts>' ])
            ->setLabel('Posts');
    }
}
```

```
services:
    <name of menu listener service, not important>:
        class: <full class name of your listener>
        tags:
            - 
                name: kernel.event_listener
                event: sylius.menu.admin.main
                method: <your method name>
```

### [`admin_menu`] Create a frontend controller

Create a controller and template for listing the blog posts on the front end.

1. Create the controller.
2. Create the DI configuration for the controller (`src/AppBunde/Resources/config/services.yml`)
3. Create the template
4. Add routing for the controller (actually, this must be prefixed with *something* to avoid conflicts with Sylius).
5. Copy the shop layout and override it, adding a link to your blog post list.

```php
<?php

namespace AppBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Templating\EngineInterface;
use Doctrine\ORM\EntityManagerInterface;
use AppBundle\Entity\Post;
use Symfony\Component\HttpFoundation\Request;

class PostController
{
    private $entityManager;
    private $templating;

    public function __construct(
        EntityManagerInterface $entityManager,
        EngineInterface $templating
    )
    {
        $this->entityManager = $entityManager;
        $this->templating = $templating;

    }

    public function indexAction(Request $request)
    {
        $repository = $this->entityManager->getRepository(Post::class);
        $posts = $repository->findAll();

        return $this->templating->render(
            '@App/Post/index.html.twig',
            [
                'posts' => $posts
            ]
        );
    }
}
```

```jinja
{% extends "SyliusShopBundle::layout.html.twig" %}

{% block content %}

    {% for post in posts %}
        {# display your post here. be creative. #}
    {% endfor %}

{% endblock %}
```

```
SyliusShopBundle/views/layout.html.twig
```

```yaml
app.controller.admin_post:
    class: <full class name for your controller>
    arguments:
        - @doctrine.orm.default_entity_manager
        - @templating
```

Multilingual blog
-----------------

Sylius is fully internationalized at the core. But creating translatable
entities is not trivial. In this exercise we will add translations to our
blog post.

### [`frontend_controller`] Create translation entity.

Create a new entity which will contain the translations for the existing
`Post` entity and update the post entity to use it.

1. Create the translation entity (e.g. `PostTranslation`) extending `AbstractTranslation` and
   implementing `ResourceInterface`. It should have ``$id``,  `$title` and `$body` fields.
2. Modify the Post enity to make use of the translation entity. 
    - It must use the `TranslatableTrait` and implement the `TranslatableInterface`. 
    - It should get and set values using the traits `translate()` method.
    - It should initialize `$this->translations` (imported with the trait) with a new `ArrayCollection`.
>
Hints:

```php
$this->translate()->getTitle();
```

```php
$this->translate()->setTitle($title);
```

- `Sylius\Component\Resource\Model\TranslatableTrait`
- `Doctrine\Common\Collections\ArrayCollection`
- `Sylius\Component\Resource\Model\TranslatableInterface`
- `@ORM\Id()`
- `@ORM\GeneratedValue()`
- `@ORM\Column(type="string")`

### Form types (translation continued)

In order to allow the user to translate fields we need to create a new form
type for the `Post` entity (it will no longer be dynamically created) and
create a form type for the `PostTranslation`.

1. Create the `PostTranslationType` class. It should extend
   `AbstractResourceType` and override the constructor to pass the full class
   name of your post translation class to the parent. It should add `title`
   and `body` fields.
2. Create a `PostType` class, also extending `AbstractResourceType` and
   passing the class name to the parent in the constructor. It should add the
   `publishedAt` field and a `translations` field (see hints).
3. Configure the translation class in the Post's resource configuration.
4. Configure the post's admin routing to use the new Post form type.
5. Using the admin interface, add locales to the shop.
6. Enable locales for the shop channel.
7. Translate your blog post!
8. View it on the frontend and change the locale!

Hints:

```php
<?php

namespace AppBundle\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Sylius\Bundle\ResourceBundle\Form\Type\AbstractResourceType;
use AppBundle\Entity\PostTranslation;

class PostTranslationType extends ...
{
    public function __construct()
    {
        parent::__construct(PostTranslation::class);
    }

    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        // $builder->add(<field name>, <field type>);
    }
}
```

```php
    $builder->add('translations', 'sylius_translations', [
        'type' => PostTranslationType::class
    ]);
```


```php
<?php

namespace AppBundle\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use AppBundle\Entity\Post;
use Sylius\Bundle\ResourceBundle\Form\Type\AbstractResourceType;

class PostType extends ...
{
    public function __construct()
    {
        parent::__construct(Post::class);
    }

    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        // $builder->add(<field name>, <field type>, <field options>);
    }
}
```

- Translation form type `sylius_translations` with option `type` and value `PostTranslationType::class`

```
# resources.yml
sylius_resource:
    resources:
        app.post:
            # ...
            translation:
                classes:
                    model: AppBundle\Entity\PostTranslation
```

```yaml
# resource routing
    grid: app_post
    except: [ "show" ]
    templates: SyliusAdminBundle:Crud
    form: AppBundle\Form\PostType     # add this line
```

```
Configuration > Locales
```

```
Configuration > Channels
```
Taxonomies
----------

We will add the ability to categorize our blog posts using the Sylius taxonomy
system. This one is easy!

### [`translations`] Add Taxonomy to Post

1. Create a new taxon in the admin interface called "blog" and add some
   children (e.g. `symfony`, `sylius`, `croatia`).
2. Add a new property to the `Post` entity `$categories` and map it as
   `ManyToMany` with `TaxonInterface`.
3. Add the `categories` field to the `PostType` form type class.
4. Display the tags in the frontend.

Hints:

- `@ORM\ManyToMany(targetEntity="Sylius\Component\Taxonomy\Model\TaxonInterface")`

```php
$builder->add('categories', 'sylius_taxon_choice', [
    'root' => <name of the taxon you created>,
    'multiple' => true,
    'expanded' => true,
]);
```

Customer Karama Discount System
================================

We want to be able to be able to give customers discount based on how much
"karma" they have. How Customers earn karma is not part of this tutorial.

## Customer Karma Rule Checker

In order to trigger a promotion action when a customers Karma exceeds a given
amount we need to create a rule checker.

### [`taxonomy`] Override customer object and add Karma field

Override the customer object add an integer field for Karma with a getter and
setter.

1. Create a new `AppBundle\Entity\Customer` entity, extending from the default
   Sylius customer (see `debug:config sylius_customer` below).
2. Add the `$karama` property and map as an integer. Default to `0`!
3. Configure the `sylius_customer` bundle to use your customer object instead
   of the default one (see `debug:config sylius_customer`)
4. Verify with `debug:config sylius_customer`

Hints:

```bash
$ php app/console debug:config sylius_customer
```

```
use Doctrine\ORM\Mapping as ORM
```

```php
@ORM\Entity()
@ORM\Column(type="integer")
```

```bash
$ php app/console doctrine:schema:update --force
```

```bash
$ php app/console sylius:fixtures:load
```

### [`karma_customer_entity`] Override customer form and edit template

1. Override the customer form, adding the `karma` field.
2. Configure the customer bundle to use the form
3. Override the customer `_form.html.twig` template

Hints:

```bash
$ php app/console debug:config sylius_customer
```

```
use Sylius\Bundle\CoreBundle\Form\Type\CustomerType as BaseCustomerType;
```

```
app/Resources/SyliusAdminBundle/views/Customer/_form.html.twig
```

### [`karma_customer_form'] Create a promotion rule checker

The rule checker will allow us to use the Karma of a customer as a trigger to
apply a discount.

1. Create the `KarmaRuleChecker` in `AppBundle\Promotion`.
2. Create the corresponding `KarmaRuleCheckerType` form type.
3. Add the rule checker to the DI configuration.
4. Create a rule in the backoffice and enable the channel (i.e. "US Web
   Store")
5. Give yourself some Karma and checkout!

Hints:

- Look at `CustomerLoyaltyChecker` and `RuleCheckerInterface`
- You can use the FQN of your form type as the return value for
  `getConfigurationFormType`
- The fields you add to the form type are the array keys of `$configuration`
  in the rule checker.

```
    name: sylius.promotion_rule_checker
    type: karma
    label: Customer Karma
```

## [`karma_multiplier`] Karma Multiplier

When the rule is met the customers karma should be multiplied.

NOTE that actions are applied at each stage of the checkout -- not upon
completion. Do not use this strategy at home!

1. Create the class `AppBundle\Promotion\KarmaMultiplierAction` implementing
   `PromotionActionInterface`
2. Fill in the `execute` action, multiply the customers karma.
2.1. Optionally implement the `revert` action.
3. Create the `AppBundle\Form\KarmaMultiplierType` (add a single field "multiplier" as "numeric")
4. Add the action to the DI configuration.
5. Add the action to your promotion in the admin interface.
6. Checkout and watch your Karma grow!

```
    name: sylius.promotion_action
    type: karma_multiplier
    label: Karma Multiplier
```
