Part 2-1: Taxonomies
--------------------

We will add the ability to categorize our blog posts using the Sylius taxonomy
system. This one is easy!

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
