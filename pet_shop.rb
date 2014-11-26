require 'pg'
require 'rest-client'


class Petshop

  def initialize

    @conn = PG::Connection.open(:dbname => 'petshop_db')

  end

  def insert_dog(dog_name, image_url, happiness, id, shop_id, adopted) #NICK's, similar to above (get_input)
    sql = %q[
      INSERT INTO dogs (dog_name, image_url, happiness, id, shop_id, adopted)
      VALUES ($1, $2, $3, $4, $5, $6)
    ]
    @conn.exec_params(sql, [dog_name, image_url, happiness, id, shop_id, adopted])
  end

  def insert_cat(cat_name, image_url, id, shop_id, adopted) #NICK's, similar to above (get_input)
    sql = %q[
      INSERT INTO cats (cat_name, image_url, id, shop_id, adopted)
      VALUES ($1, $2, $3, $4, $5)
    ]
    @conn.exec_params(sql, [cat_name, image_url, id, shop_id, adopted])
  end

  def insert_shop(shop_name, shop_id)
    sql = %q[
      INSERT INTO shops (shop_name, shop_id)
      VALUES ($1, $2)
    ]
    @conn.exec_params(sql, [shop_name, shop_id])
  end

  def populate_petshop
    
    @conn.exec("CREATE TABLE shops(shop_name VARCHAR, shop_id INTEGER)")
    @conn.exec("CREATE TABLE dogs(dog_name VARCHAR, image_url VARCHAR, happiness INTEGER, id INTEGER, shop_id INTEGER, adopted VARCHAR)")
    @conn.exec("CREATE TABLE cats(cat_name VARCHAR, image_url VARCHAR, id INTEGER, shop_id INTEGER, adopted VARCHAR)")

    shops = RestClient.get "pet-shop.api.mks.io/shops"
    parsed = JSON.parse(shops)
    parsed.each {|x| insert_shop(x["name"], x["id"])}

    i = 1
    while i < parsed.length
      dogs = RestClient.get "pet-shop.api.mks.io/shops/#{i}/dogs"
      cats = RestClient.get "pet-shop.api.mks.io/shops/#{i}/cats"

      parsed_dogs = JSON.parse(dogs)
      parsed_cats = JSON.parse(cats)

      parsed_dogs.each {|x| insert_dog(x["name"], x["imageUrl"], x["happiness"], x["id"], x["shopId"], x["adopted"])}
      parsed_cats.each {|x| insert_cat(x["name"], x["imageUrl"], x["id"], x["shopId"], x["adopted"])}

      i += 1
    end
  end

  def print_pet_shops
    allshops = @conn.exec("SELECT * FROM shops")
    puts "ID | Name"
    puts "----------------------------"
    allshops.entries.each do |x|
      puts "#{x["shop_id"]} | #{x["shop_name"]}"
    end
  end

  def print_dogs(shop_number)
    doggies = @conn.exec("SELECT * FROM dogs WHERE shop_id=#{shop_number}")
    this_store = @conn.exec("SELECT * FROM shops WHERE shop_id=#{shop_number}")
    puts "Dogs in store #{this_store.entries[0]["shop_name"]}:"
    puts "-----------------------------------"
    doggies.entries.each do |x|
      puts "Name: #{x["dog_name"]}"
      puts "Happiness: #{x["happiness"]}"
      puts "Adopted: #{x["adopted"]}"
      puts "-----------------------------------"
    end
  end

  def print_top5_dogs
    happy_dogs = @conn.exec("SELECT * FROM dogs ORDER BY happiness DESC LIMIT 5")
    puts "Happiest doggies:"
    happy_dogs.each do |x|
      puts "#{x["dog_name"]} - #{x["happiness"]}"
    end
  end

  def print_all_pets
    all_dogs = @conn.exec("SELECT dog_name, shop_name FROM dogs JOIN shops ON dogs.shop_id = shops.shop_id")
    all_cats = @conn.exec("SELECT cat_name, shop_name FROM cats JOIN shops ON cats.shop_id = shops.shop_id")
  end

  
  def drop
     @conn.exec("DROP TABLE SHOPS, DOGS, CATS")
  end
  
end