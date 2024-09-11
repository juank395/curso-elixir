defmodule InventoryManager do
  defstruct products: []

  defmodule Product do
    defstruct id: 0, name: "", price: 0.0, stock: 0
  end

  def add_product(%InventoryManager{products: products} = inventory_manager, name, price, stock) do
    product = %Product{id: Enum.count(products) + 1, name: name, price: price, stock: stock}
    %{inventory_manager | products: products ++ [product]}
  end

  def list_products(%InventoryManager{products: products}) do
    IO.puts("\n|---Stock---|")
    for product <- products do
      IO.puts "Producto: ##{product.id} #{product.name} - Precio: $#{product.price} - Stock: #{product.stock}"
    end
  end

  def increase_stock(%InventoryManager{products: products} = inventory_manager, product_id, quantity) do
    updated_products = Enum.map(products, fn product ->
      if product.id == product_id do
        %Product{product | stock: product.stock + quantity}
      else
        product
      end
    end)
    %{inventory_manager | products: updated_products}
  end

  def sell_product(%InventoryManager{products: products} = inventory_manager, product_id, quantity) do
    updated_products = Enum.map(products, fn product ->
      if product.id == product_id do
        %Product{product | stock: product.stock - quantity}
      else
        product
      end
    end)
    %{inventory_manager | products: updated_products}
  end

  def view_cart(%InventoryManager{products: products}) do

    IO.puts("\n|---Productos en el Carrito---|")
    for product <- products do
      IO.puts "#{product.id}. #{product.name} - $#{product.price} - Cant: #{product.stock} - Total: $#{product.price * product.stock}"
    end
  end

  def checkout(%InventoryManager{products: products} = inventory_manager, cart) do
    Enum.reduce(cart, inventory_manager, fn {product_id, quantity}, acc ->
      sell_product(acc, product_id, quantity)
    end)
  end




  def run() do
    inventory_manager = %InventoryManager{}
    inventory_manager = add_product(inventory_manager, "Leche", 1.5, 2)
    inventory_manager = add_product(inventory_manager, "Pan", 0.5, 4)
    inventory_manager = add_product(inventory_manager, "Huevos", 2.0, 6)


    IO.puts "Agregando 5 unidades de pan al stock..."
    inventory_manager = increase_stock(inventory_manager, 2, 5)


    IO.puts "Agregando 10 unidades de leche al stock..."
    inventory_manager = increase_stock(inventory_manager, 1, 10)

    IO.puts "Agregando 4 unidades de huevos al stock..."
    inventory_manager = increase_stock(inventory_manager, 1, 10)

    list_products(inventory_manager)


    IO.puts "Vendiendo 3 unidades de huevos..."
    inventory_manager = sell_product(inventory_manager, 3, 3)



    IO.puts "\nViendo el carrito..."
    view_cart(inventory_manager)

    IO.puts "\nRealizando el checkout..."
    inventory_manager = checkout(inventory_manager, [{1, 2}, {2, 3}, {3, 1}])

    IO.puts "\nListando productos despues del checkout..."
    list_products(inventory_manager)

  end



end
