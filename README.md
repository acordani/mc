# Mister Cocktail du wagon

## REMEMBER THE CONVENTION:

- Table name: lower_snake_case, plural form (store several rows).
- Model class name: UpperCamelCase, singular form (mapped to 1 row)
- Rails is full of Convention over Configuration.

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
(Un cocktail a plusieurs ingredients au travers de doses, comme on peut le voir sur le schema:
![mc3](https://cloud.githubusercontent.com/assets/10654877/7607993/4df78990-f966-11e4-9f91-818f2dfcd07e.jpg)
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
  has_many :cocktails, through: :doses
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
L'ordre n'a pas d'importance. on peut remplacer cocktail par ingredient.
C'est une syntaxe particulière mais c'est comme ça ;-)

###Routing###

Here is the list of features:
- A user can see the list of all cocktails. 
```
index de cocktail - GET "cocktails"
get 'cocktails' => "cocktails#index"
```
- A user can see the details of a given cocktail, with the ingredient list.
```
show de cocktail - GET "cocktails/42"
get 'cocktails/:id' => "cocktails#show"
```
- A user can create a new cocktail. 
```
new et create cocktail - GET "cocktails/new" et POST "cocktails"
get 'cocktails/new' => "cocktails#new"
post 'cocktails' => "cocktail#create"
```

- A user can add a new dose (ingredient/description pair) on an existing cocktail.
```
new et create de dose - GET "cocktails/42/doses/new" et POST "cocktails/42/doses"
get 'cocktails/:cocktail_id/doses/new' =>"doses/new"
post '
```
- A user can delete a dose on an existing cocktail.
```
destroy de dose - DELETE "doses/25"
```
-----------------------------------------------------
```ruby
Rails.application.routes.draw do
  root_to: 'cocktails#index'
  resources :cocktails, only: [:index,:new, :show, :create] do
    resources :doses, only: [:new, :create]
  end
  resources :doses,only: [:destroy]
end
```
------------------------------------------------------
![rake routes](https://cloud.githubusercontent.com/assets/10654877/7611863/7d4ec9bc-f987-11e4-9bd6-5a72542cc266.jpg)

root_to: 'cocktails#index' va permettre à la root / de renvoyer à l'action index du controller cocktail

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
On crée un objet Cocktail(une instance de la class cocktail avec aucune information) vide (sans information (sans id, sans name) qui va nous permettre de construire le formulaire

### View(new dans cocktail) ###
```ruby
<%= form_for @cocktail do |f| %>
  <%= f.text_field :name %>
  <%= f.submit %>
<% end %>
```
```ruby
<%= simple_form_for @cocktail do |f| %>
  <%= f.text_field :name %>
  <%= f.submit %>
<% end %>
```

la ligne: <%= simple_form_for @cocktail do |f| %> va servir a génerer la balise form
les lignes qu'on écrit apres, vont generer les input qu'on met dedans

Il va en plus grace à @cocktail mettre la bonne URL
Comment le fait il?
En 2 étapes:
- il voit qu'on a @cocktail. Et @cocktail contient Cocktail.new. Qui elle meme est une instance de la class Cocktail
- Et donc il fait @cocktail.class => Qui retourne la chaine de caractère "Cocktail"
- Ensuite, il fait @cocktail.class.downcase => Ce qui fait "cocktail"
- Puis il fait @cocktail.class.downcase.pluralize => Il se retrouve donc avec "cocktails"
- Dc il a maintenant "cocktails" et il rajoute la chaine de caractere "_path"

![cocktails_path](https://cloud.githubusercontent.com/assets/10654877/8779309/155beafe-2f03-11e5-8962-211150642b47.jpg)

Ensuite on doit se demander si il doit faire un get ou un post?

Il regarde si il y a un id. Si il ya un id, cela veut dire qu'on recupere quelquechose qui existe dejà.
Si il n'ya pas d'id, cela veut dire qu'on veux créer quelquechose, et dc il fait un Post

Les champs qui viennent en input proviennent forcement du schema de la bdd.

Lorsqu'on va appuyer sur le bouton submit, cela va renvoyer à l'action create du Controller Cocktail
```ruby
def create
    @cocktail = Cocktail.create(cocktail_params)

    redirect_to cocktail_path(@cocktail)
  end
```
Je redirige vers cocktail_path qui est la route pour acceder à la show view.
L'argument @cocktail qui veint apres le cocktail_path est remplacé par un id.
Il y a une autre synthaxe qui est : ``` redirect_to cocktail_path({id: @cocktail.id})  ```
On lui dit vraiment dans cocktail_path, je veux que tu remplaces la partie id par cocktail.id

Cocktail_params Kesako ??

```ruby
  def cocktail_params
    params.require(:cocktail).permit(:name)
  end
```
si on met un raise dans le create pour créer une erreur, on se rend compte en écrivant params ds la console, que ca va afficher plein de trucs:

![params](https://cloud.githubusercontent.com/assets/10654877/8779243/b57b3fd6-2f02-11e5-9602-209dec35f7a7.jpg)

Ce qui nous interesse c'est cocktail avec la clé name.
Tout le reste, UTF8, authenticity token,... ne nous interesse pas

require cocktail, veux dire que ds le grand hash, on ne veut que la partie avec la clé cocktail
Et à l'interieur de la clé cocktail, il autorise les champs (.permit(:name) name.

### Controlleur(show dans cocktail) ###
```ruby
def show
    @cocktail = Cocktail.find(params[:id])
end
```
pourquoi params[:id] car ds la route, il y a bien un param qui s'appelle id
```
show de cocktail -  cocktail/:id -- GET "cocktails/42"
```

### View(index dans cocktail) ###
```ruby
<h2><%= @cocktail.name %></h2>

<ul>
<% @cocktail.doses.each do |dose| %>
  <li>
    <%= dose.description %> - <%= dose.ingredient.name %> - <%= link_to '(delete)', cocktail_dose_path(@cocktail, dose), method: :delete %>
  </li>
<% end %>
</ul>
<p>
  <%= link_to "Ajouter une dose", new_cocktail_dose_path(@cocktail) %>
</p>
```
pour le link_to, on ajoute ) new_cocktail_dose_path un arguement qui est (@cocktail).
@cocktail correspond à l'id du cocktail.
On pourrait l'écrire comme ca: 
```new_cocktail_dose_path({ cocktail_id:@cocktail.id})```

Maintenant on va créer le controller dose
```rails g controller Doses new```
On ajoute le create a la main dans le controller car sinon, rails va créer le fichier de view de create et on n'en ne veut pas!!

### Controlleur(new dans dose) ###
```ruby
def new
 @doses = Dose.new
 @ingredienst = Ingredient.all
end
```

### View(new dans dose) ###
```ruby
<h1>Ajouter une dose</h1>

<%= simple_form_for [@cocktail, @dose] do |f| %>
  <%= f.input :description %>
  <%= f.input :ingredient_id, as: :select, collection: @ingredients %>
  <%= f.submit %>
<% end %>

```
on a besoin des 2 arguments dans le simple_form car on veut comme url cocktail_doses_path

![routes](https://cloud.githubusercontent.com/assets/10654877/8869516/d125b718-31e4-11e5-82c2-8fc71e2d8bf4.jpg)

On va donc lui passer un tableau avec @cocktail et @dose.

Ensuite dans input, on mettra description et ingredient_id car ds le schéma dose, c'est ce qu'on a . Ca doit absolument correspondre au schéma.

![ingredient_id](https://cloud.githubusercontent.com/assets/10654877/8869537/2bd6a9ec-31e5-11e5-8fd5-35f2276d7151.jpg)

Le probleme est que cela ns donne un input avec un choix en chiffre et il faut mettre l'id de l'ingredient et ns on veut qu'il nous propose les differents ingredients.
D'abord, on veut un dropdown donc pour avoir un dropdown, on va mettee as: :select
Pour avoir la liste des ingredients, il faut qu'on lui passe une collection, collection: Ingredient.all

Attention: ca fonctionnne car on avait un .name, simple_form utilise les .name pour générer ses selects
Et la plupart du temps, au lieu de mettre Ingredient.all, on met @ingredients
et ds le controller, on met : @ingredients = Ingredient.all

Pourquoi ? Car il faut eviter de faire des requetes SQL ds les views. On les fait ds les controllers


### Controlleur(create dans dose) ###
```ruby
def create
    @cocktail = Cocktail.find(params[:cocktail_id])
    @dose = @cocktail.doses.new(doses_params)
    if @dose.save
      redirect_to cocktail_path(@cocktail)
    else
      render :new
    end
  end
```
la fonction ```.build``` n'a aucune difference avec la fonction ```.new```
C'est un mot different pour signifier la meme chose.
On fait ```@cocktail.doses``` car dans le model cocktail, on a ```has_many :doses```

![model cocktail](https://cloud.githubusercontent.com/assets/10654877/8869567/8ac67d7e-31e5-11e5-8262-8652d322efa8.jpg)


C'est ce ```has_many :doses``` qui nous permet de faire un ```cocktail.doses```

### View(show dans cocktail) ###
```ruby
<<h2><%= @cocktail.name %></h2>

<ul>
<% @cocktail.doses.each do |dose| %>
  <li>
    <%= dose.description %> - <%= dose.ingredient.name %> - <%= link_to '(delete)', cocktail_dose_path(@cocktail, dose), method: :delete %>
  </li>
<% end %>
</ul>
<p>
  <%= link_to "Ajouter une dose", new_cocktail_dose_path(@cocktail) %>
</p>

```
On peut faire un dose.ingredient.name car dans le model dose, il y a un belongs_to :ingredient
C'est uniquement pour ca. Si on retire la ligne belongs_to :ingredient dans le model, la methode .ingredient ne fonctionnera plus

### Controlleur(destroy dans dose) ###
```ruby
def destroy
    @dose = Dose.find(params[:id])
    @dose.destroy

    redirect_to :back
  end
```
redirect_to :back, permet de revenir à la page d'avant.


```
rails generate migration RemoveFieldNameFromTableName field_name:datatype
```
### Seed
```ruby
Ingredient.create(name:'lemon')
Ingredient.create(name:'salt')
Ingredient.create(name:'ice')
Ingredient.create(name:'sugar')
Ingredient.create(name:'mint')
Ingredient.create(name:'vodka')
Ingredient.create(name:'rhum')
```

```
rake db:seed
```
Pour verifier si les ingredients sont bien ds la base de donnée, on fait dans la console:
```
Ingredient.all
```
Il faut maintenant faire les controllers et les actions au fur et à mesure
Créer un cocktail et afficher la liste des cocktails

rails g controller Cocktails index new create

On va dans rails console et on crée un nouveau cocktail

Cocktail.create( name:"Mojito" )
Cocktail.create( name:"Blody Mary" )

Cocktail.all => nous affiche les instances des 2 cocktails


### Controlleur(index dans cocktail) ###
```ruby
def new
 @cocktails = Cocktail.all
end
```

### View(index dans cocktail) ###
```ruby
<h1>Voici la liste des cocktails</h1>

<ul class="list">
  <% @cocktails.each do |cocktail| %>
    <li><%= cocktail.name %></li>
  <% end %>
</ul>
<%= link_to "Ajoutez un cocktail" , new_cocktail_path %>
```

@cocktails est un tableau et donc each va me permettrede parcourir le tableau et pour chaque cocktail d'afficher son nom.
le link_to va me permettre de créer un lien qui m'amenera à la page de création d'un nouveau cocktail.
