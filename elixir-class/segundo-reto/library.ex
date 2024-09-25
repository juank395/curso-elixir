defmodule LibraryManager do
  defstruct books: [], users: [], loans: []

  defmodule Book do
    defstruct id: 0, title: "", author: "", stock: 0
  end

  defmodule User do
    defstruct id: 0, name: "", email: ""
  end

  defmodule Loan do
    defstruct id: 0, user_id: 0, book_id: 0, quantity: 0
  end

  def add_book(%LibraryManager{books: books} = library_manager, title, author, stock) do
    book = %Book{id: Enum.count(books) + 1, title: title, author: author, stock: stock}
    %{library_manager | books: books ++ [book]}
    library_manager
  end

  def list_books(%LibraryManager{books: books} = library_manager) do
    IO.puts("\n|---Stock de Libros---|")
    for book <- books do
      IO.puts "Libro: ##{book.id} #{book.title} - Autor: #{book.author} - Stock: #{book.stock}"
    end
    library_manager
  end

  def validate_disponibility(%LibraryManager{books: books} = library_manager, book_id, quantity) do
    book = Enum.find(books, fn book -> book.id == book_id end)
    if book && book.stock >= quantity do
      true
    else
      false
    end
    library_manager
  end

  def add_user(%LibraryManager{users: users} = library_manager, name, email) do
    user = %User{id: Enum.count(users) + 1, name: name, email: email}
    %{library_manager | users: users ++ [user]}
    library_manager
  end

  def list_users(%LibraryManager{users: users} = library_manager) do
    IO.puts("\n|---Usuarios---|")
    for user <- users do
      IO.puts "Usuario: ##{user.id} Nombre: #{user.name} - Email: #{user.email}"
    end
    library_manager
  end

  def add_loan(%LibraryManager{loans: loans} = library_manager, user_id, book_id, quantity) do
    if validate_disponibility(library_manager, book_id, quantity) do
      loan = %Loan{id: Enum.count(loans) + 1, user_id: user_id, book_id: book_id, quantity: quantity}
      updated_books = Enum.map(library_manager.books, fn book ->
        if book.id == book_id do
          %Book{book | stock: book.stock - quantity}
        else
          book
        end
      end)
      %{library_manager | loans: loans ++ [loan], books: updated_books}
      library_manager
    else
      IO.puts("No hay suficiente stock para el libro solicitado.")
      library_manager
    end
  end

  def finish_loan(%LibraryManager{loans: loans} = library_manager, loan_id) do
    loan = Enum.find(loans, fn loan -> loan.id == loan_id end)

    if !loan do
      IO.puts("El prestamo no existe.")
      library_manager
    end

    updated_books = Enum.map(library_manager.books, fn book ->
      if book.id == loan.book_id do
        %Book{book | stock: book.stock + loan.quantity}
      else
        book
      end
    end)
    updated_loans = Enum.reject(loans, fn loan -> loan.id == loan_id end)
    %{library_manager | loans: updated_loans, books: updated_books}
    library_manager
  end

  def list_loans(%LibraryManager{loans: loans} = library_manager) do
    IO.puts("\n|---Prestamos---|")
    for loan <- loans do
      IO.puts "Prestamo: ##{loan.id} Usuario: #{loan.user_id} - Libro: #{loan.book_id} - Cantidad: #{loan.quantity}"
    end
    library_manager
  end

  def call_add_book(library_manager) do
    IO.puts("Ingrese el titulo del libro:")
    title = String.trim(IO.gets(""))

    IO.puts("Ingrese el autor del libro:")
    author = String.trim(IO.gets(""))

    IO.puts("Ingrese el stock del libro:")
    stock = String.trim(IO.gets(""))

    library_manager = add_book(library_manager, title, author, String.to_integer(stock))
    library_manager
  end

  def call_list_books(library_manager) do
    list_books(library_manager)
  end

  def call_add_user(library_manager) do
    IO.puts("Ingrese el nombre del usuario:")
    name = String.trim(IO.gets(""))

    IO.puts("Ingrese el email del usuario:")
    email = String.trim(IO.gets(""))

    library_manager = add_user(library_manager, name, email)
    library_manager
  end

  def call_list_users(library_manager) do
    list_users(library_manager)
  end

  def call_add_loan(library_manager) do
    IO.puts("Ingrese el ID del usuario:")
    user_id = String.trim(IO.gets(""))

    IO.puts("Ingrese el ID del libro:")
    book_id = String.trim(IO.gets(""))

    IO.puts("Ingrese la cantidad a prestar:")
    quantity = String.trim(IO.gets(""))

    library_manager = add_loan(library_manager, String.to_integer(user_id), String.to_integer(book_id), String.to_integer(quantity))
    library_manager
  end

  def call_finish_loan(library_manager) do

    if Enum.empty?(library_manager.loans) do
      IO.puts("\nNo hay prestamos registrados.\n")
      library_manager
    else
      IO.puts("Ingrese el ID del prestamo a finalizar:")
      loan_id = String.trim(IO.gets(""))
      library_manager = finish_loan(library_manager, String.to_integer(loan_id))
      library_manager
    end

  end

  def call_list_loans(library_manager) do
    list_loans(library_manager)
  end

  def main_menu(library_manager) do
    IO.puts("\n|---Menu Principal---|")
    IO.puts("1. Agregar Libro")
    IO.puts("2. Listar Libros")
    IO.puts("3. Agregar Usuario")
    IO.puts("4. Listar Usuarios")
    IO.puts("5. Prestar Libro")
    IO.puts("6. Listar Prestamos")
    IO.puts("7. Finalizar Prestamo")
    IO.puts("8. Salir")

    IO.puts("Ingrese una opcion:")
    option = String.trim(IO.gets(""))

    library_manager = case option do
      "1" -> call_add_book(library_manager)
      "2" -> call_list_books(library_manager)
      "3" -> call_add_user(library_manager)
      "4" -> call_list_users(library_manager)
      "5" -> call_add_loan(library_manager)
      "6" -> call_list_loans(library_manager)
      "7" -> call_finish_loan(library_manager)
      "8" -> IO.puts("Adios!"); library_manager
      _ -> IO.puts("Opcion no valida"); library_manager
    end

    if option != "8" do
      main_menu(library_manager)
    end
  end

  def run() do
    library_manager = %LibraryManager{}
    main_menu(library_manager)
  end
end
