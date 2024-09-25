defmodule CryptoBank do
  # Alias modules for easier access
  # This line imports multiple modules from the CryptoBank namespace.
  # It allows us to use Wallet, Transaction, Product, and User
  # without prefixing them with CryptoBank each time.
  # For example, we can now write Wallet.new() instead of CryptoBank.Wallet.new().
  alias CryptoBank.{Wallet, Transaction, Product, User}



  @doc """
  Initializes the CryptoBank application.
  Returns a map representing the initial state.
  """
  def start do
    IO.puts "Welcome to CryptoBank!"
    %{users: %{}, products: []}
  end

  @doc """
  Creates a new user.

  Parameters:
  - state: Current application state
  - name: String, name of the new user

  Returns:
  - {:ok, message, new_state} on success
  - {:error, message, state} if user already exists
  """
  def create_user(state, name) do
    case state.users |> Map.has_key?(name) do
      true ->
        {:error, "User already exists", state}
      false ->
        user = User.new(name)
        {:ok, "User #{name} created successfully!",
         %{state | users: Map.put(state.users, name, user)}}
    end
  end

  @doc """
  Retrieves a user by name.

  Parameters:
  - state: Current application state
  - name: String, name of the user to retrieve

  Returns: User struct or nil if not found
  """
  def get_user(state, name) do
    Map.get(state.users, name)
  end

  @doc """
  Executes a transaction between two users.

  Parameters:
  - state: Current application state
  - from: String, name of the sender
  - to: String, name of the recipient
  - amount: Number, amount to transfer
  - currency: Atom, currency of the transaction (:btc, :eth, or :usd)

  Returns:
  - {:ok, message, new_state} on success
  - {:error, reason, state} on failure
  """
  def transact(state, from, to, amount, currency) do
    with {:ok, from_user} <- fetch_user(state, from),
         {:ok, to_user} <- fetch_user(state, to),
         {:ok, updated_from, updated_to} <- Transaction.execute(from_user, to_user, amount, currency) do
      new_state = %{state | users: state.users
                    |> Map.put(from, updated_from)
                    |> Map.put(to, updated_to)}
      {:ok, "Transaction completed successfully", new_state}
    else
      {:error, reason} -> {:error, reason, state}
    end
  end

  @doc """
  Creates a new product.

  Parameters:
  - state: Current application state
  - name: String, name of the product
  - price: Number, price of the product
  - currency: Atom, currency of the price (:btc, :eth, or :usd)

  Returns: {:ok, message, new_state}
  """
  def create_product(state, name, price, currency) do
    product = Product.new(name, price, currency)
    {:ok, "Product #{name} created successfully!",
     %{state | products: [product | state.products]}}
  end

  @doc """
  Lists all available products.

  Parameters:
  - state: Current application state

  Returns: List of product structs
  """
  def list_products(state) do
    state.products
  end

  @doc """
  Allows a user to buy a product.

  Parameters:
  - state: Current application state
  - user_name: String, name of the user making the purchase
  - product_name: String, name of the product to buy

  Returns:
  - {:ok, message, new_state} on success
  - {:error, reason, state} on failure
  """
  def buy_product(state, user_name, product_name) do
    with {:ok, user} <- fetch_user(state, user_name),
         {:ok, product} <- fetch_product(state, product_name),
         {:ok, updated_user} <- User.buy_product(user, product) do
      new_state = %{state | users: Map.put(state.users, user_name, updated_user)}
      {:ok, "Product purchased successfully", new_state}
    else
      {:error, reason} -> {:error, reason, state}
    end
  end

  # Private helper function to fetch a user
  defp fetch_user(state, name) do
    case Map.fetch(state.users, name) do
      {:ok, user} -> {:ok, user}
      :error -> {:error, "User #{name} not found"}
    end
  end

  # Private helper function to fetch a product
  defp fetch_product(state, name) do
    case Enum.find(state.products, &(&1.name == name)) do
      nil -> {:error, "Product #{name} not found"}
      product -> {:ok, product}
    end
  end

  @doc """
  Converts currency for a user.

  Parameters:
  - state: Current application state
  - user_name: String, name of the user
  - amount: Number, amount to convert
  - from_currency: Atom, source currency (:btc, :eth, or :usd)
  - to_currency: Atom, target currency (:btc, :eth, or :usd)

  Returns:
  - {:ok, message, new_state} on success
  - {:error, reason, state} on failure
  """
  def convert_currency(state, user_name, amount, from_currency, to_currency) do
    with {:ok, user} <- fetch_user(state, user_name),
         {:ok, conversion_rate} <- get_conversion_rate(from_currency, to_currency),
         {:ok, updated_from_wallet} <- Wallet.remove_funds(user.wallet, amount, from_currency) do
      converted_amount = Decimal.mult(Decimal.new("#{amount}"), conversion_rate)
      updated_to_wallet = Wallet.add_funds(updated_from_wallet, converted_amount, to_currency)
      updated_user = %{user | wallet: updated_to_wallet}
      new_state = %{state | users: Map.put(state.users, user_name, updated_user)}
      {:ok, "Currency converted successfully", new_state}
    else
      {:error, reason} -> {:error, reason, state}
    end
  end

  # Private helper function to get conversion rate
  defp get_conversion_rate(from_currency, to_currency) do
    # In a real application, you would fetch these rates from an API
    # For this example, we'll use hardcoded rates
    rates = %{
      btc_to_usd: Decimal.new("30000"),
      eth_to_usd: Decimal.new("2000"),
      btc_to_eth: Decimal.new("15"),
      usd_to_btc: Decimal.new("0.000033"),
      usd_to_eth: Decimal.new("0.0005"),
      eth_to_btc: Decimal.new("0.066667")
    }

    case {from_currency, to_currency} do
      {same, same} -> {:ok, Decimal.new(1)}
      {:btc, :usd} -> {:ok, rates.btc_to_usd}
      {:eth, :usd} -> {:ok, rates.eth_to_usd}
      {:btc, :eth} -> {:ok, rates.btc_to_eth}
      {:usd, :btc} -> {:ok, rates.usd_to_btc}
      {:usd, :eth} -> {:ok, rates.usd_to_eth}
      {:eth, :btc} -> {:ok, rates.eth_to_btc}
      _ -> {:error, "Unsupported currency conversion"}
    end
  end

  #Adicion de nuevas funcionalidades by @JuanCamiloGerena

  @doc """
  Allows a user to sell a product.

  Parameters:
  - state: Current application state
  - user_name: String, name of the user selling the product
  - product_name: String, name of the product to sell

  Returns:
  - {:ok, message, new_state} on success
  - {:error, reason, state} on failure
  """
  def sell_product(state, user_name, product_name) do
    with {:ok, user} <- fetch_user(state, user_name),
         {:ok, product} <- fetch_product(state, product_name),
         {:ok, updated_user} <- User.sell_product(user, product) do
      new_state = %{state | users: Map.put(state.users, user_name, updated_user)}
      {:ok, "Product sold successfully", new_state}
    else
      {:error, reason} -> {:error, reason, state}
    end
  end

  @doc """
  Lists all products sold by a user.

  Parameters:
  - state: Current application state
  - user_name: String, name of the user

  Returns:
  - List of product structs
  """
  def list_sold_products(state, user_name) do
    case fetch_user(state, user_name) do
      {:ok, user} -> user.sold_products
      {:error, _} -> []
    end
  end

  @doc """
  Lists all products bought by a user.

  Parameters:
  - state: Current application state
  - user_name: String, name of the user

  Returns:
  - List of product structs
  """
  def list_bought_products(state, user_name) do
    case fetch_user(state, user_name) do
      {:ok, user} -> user.bought_products
      {:error, _} -> []
    end
  end




end
