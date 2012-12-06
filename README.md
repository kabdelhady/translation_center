= TranslationCenter

This project rocks and uses MIT-LICENSE.

Translation admin must extend User model and implement a boolean method named can_admin_translations?


## Getting started

TranslationCenter works with Rails 3.2 onwards. You can add it to your Gemfile with:

```ruby
gem 'translation_center', :git => 'git@github.com:mahkhaled/translation_center.git'
```

Run bundle install command.

TranslationCenter depends on Devise, so make sure you installed it successfully https://github.com/plataformatec/devise#starting-with-rails

After you install TranslationCenter and add it to your Gemfile, you need to run the generator:

```ruby
rails generate translation_center:install
```

And run the migrations

```ruby
rake db:migrate
```

In your User model or any other model that should acts as a translator add the following line:

```ruby
acts_as_translator
```

In routes file add 

```ruby
mount TranslationCenter::Engine => "/translation_center"
```

You know need to define who is the translation center admin. Admin can accept translations, manage translation keys and do more things. To define your admin, you need to override User#can_admin_translations? method like the following....

```ruby
def can_admin_translations?
  self.email == 'admin@tc.com'
end
```


## How to use

To migrate translations from TranslationCenter database to yaml files

```ruby
rake translation_center:db2yaml
```

To migrate translations from yaml files to TranslationCenter database 

```ruby
rake translation_center:yaml2db
```