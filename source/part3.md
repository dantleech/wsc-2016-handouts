Part 3 Customer Karama Discount System
--------------------------------------

We want to be able to be able to give customers discount based on how much
"karma" they have. How Customers earn karma is not part of this tutorial.

### Override customer object and add Karma field

Override the customer object add an integer field for Karma with a getter and
setter.

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

### Override customer form and edit template

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

### Create a promotion rule checker

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
