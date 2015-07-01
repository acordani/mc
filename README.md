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

```validates_uniqueness_of : cocktail, scope: :ingredient``` Permet de valider l'ingredient uniquement si il est unique dans le cocktail. On ne peut pas mettre 2 fois le même ingredient dans le cocktail.

###Routing###

Here is the list of features:
- A user can see the list of all cocktails. 
```
index de cocktail - GET "cocktails"
```
- A user can see the details of a given cocktail, with the ingredient list.
```
show de cocktail - GET "cocktails/42"
```
- A user can create a new cocktail. 
```
new et create cocktail - GET "cocktails/new" et POST "cocktails"
```

- A user can add a new dose (ingredient/description pair) on an existing cocktail.
```
new et create de dose - GET "cocktails/42/doses/new" et POST "cocktails/42/doses"
```
- A user can delete a dose on an existing cocktail.
```
destroy de dose - DELETE "doses/25"
```
-----------------------------------------------------
```ruby
Rails.application.routes.draw do
  resources :cocktails, only: [:index,:new, :show, :create] do
    resources :doses, only: [:new, :create]
  end
  resources :doses,only: [:destroy]
end
```
------------------------------------------------------
![rake routes](https://cloud.githubusercontent.com/assets/10654877/7611863/7d4ec9bc-f987-11e4-9bd6-5a72542cc266.jpg)


Création du controller Cocktail
```
rails g controller cocktails index show new create
```
### Controlleur(new dans cocktail) ###
```ruby
def new
 @cocktail = Cocktail.new
end
```
On crée un objet Cocktail qui va nous permettre de construire le formulaire

### View(new dans cocktail) ###
```ruby
<%= form_for @cocktail do |f| %>
  <%= f.text_field :name %>
  <%= f.submit %>
<% end %>
```
```
rails generate migration RemoveFieldNameFromTableName field_name:datatype
```
