# Mister Cocktail du wagon

## Go to db.lewagon.org and draw the schema with your buddy. The tables we need are cocktails, ingredients and doses.

### Attributes ###
- A **cocktail** has a name (e.g. "Mint Julep", "Whiskey Sour", "Mojito").
- An **ingredient** has a name (e.g. "lemon", "ice", "mint leaves").
- A **dose** references a cocktail, an ingredient and has a description. (e.g. the Mojito cocktail needs 6cl of lemon).

![mc3](https://cloud.githubusercontent.com/assets/10654877/7607993/4df78990-f966-11e4-9f91-818f2dfcd07e.jpg)

Pour bien démarrer, nous allons rajouter les 2 gems dans la partie dev: la gem 'better_errors' et la gem 'binding_of_caller'.
et la gem 'bootstrap-sass' dans la partie prod.

Puis on fait un bundle install ;-)

On va d'abord génerer les migrations:
- Model Coctail:
```sh 
 rails g model Cocktail name:string
```
- Model Ingredient: 
```sh
rails g model Ingredient name:string
```
- Model Dose: 
```sh
rails g model Dose description:string ingredient:references cocktail:references
```

Puis on fait un 
```sh
rake db:migrate
```
### Associations ###
- A cocktail has many doses
- A cocktail has many ingredients through doses
- An ingredient has many doses
- A dose belongs to an ingredient
- A dose belongs to a cocktail
- You can't delete an ingredient if it used by at least one cocktail.
- When you delete a cocktail, you should delete associated doses (but not the ingredients as they can be linked to other cocktails).

Pour créer les associations, nous allons aller dans les fichiers des modeles.

####cocktail.rb####
----------
```ruby
class Cocktail < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :doses, dependent: :destroy
  has_many :ingredients, through: :doses

end
```

####ingredient.rb####
---------------------
```ruby
class Ingredient < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :doses
end
```
####dose.rb####
---------------------
```ruby
class Dose < ActiveRecord::Base
  belongs_to :ingredient
  belongs_to :cocktail

  validates :description, presence: true
  validates :cocktail, presence: true
  validates :ingredient, presence: true
  validates_uniqueness_of :cocktail, scope: :ingredient
end
```

