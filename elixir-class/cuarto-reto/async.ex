defmodule AsyncRSSApp do
  @moduledoc """
  Este módulo simula una aplicación que maneja un feed RSS de manera asíncrona,
  permitiendo agregar nuevas noticias y procesarlas después de un período de tiempo.
  """

  # Simulamos una lista de noticias que pueden llegar en distintos momentos
  @doc """
  Simula un conjunto de noticias iniciales que forman parte del feed RSS.
  """
  defp simulated_feed do
    [
      %{title: "Noticia 1", description: "Descripción de la noticia 1"},
      %{title: "Noticia 2", description: "Descripción de la noticia 2"},
      %{title: "Noticia 3", description: "Descripción de la noticia 3"}
    ]
  end

  @doc """
  Inicia el proceso asíncrono que manejará el feed RSS simulado y las nuevas noticias.
  Retorna el PID del proceso.
  """
  def start do
    pid = spawn(fn -> process_feed([]) end)
    pid
  end

  @doc """
  Función principal que maneja el proceso del feed, esperando mensajes y actualizando el estado
  de las noticias. Los mensajes esperados son:

    * `{:get_feed, caller_pid}` - Para obtener las noticias actuales.
    * `{:new_news, %{title: title, description: description}}` - Para agregar una nueva noticia.
  """
  defp process_feed(news) do
    receive do
      {:get_feed, caller_pid} ->
        # Procesa las noticias actuales del feed simulado
        IO.puts("Obteniendo el feed RSS simulado...")

        feed = simulated_feed()
        updated_news = news ++ feed

        Enum.each(updated_news, fn entry ->
          IO.puts("Título: #{entry.title} - Descripción: #{entry.description}")
        end)

        send(caller_pid, :done)
        process_feed(updated_news)

      {:new_news, new_entry} ->
        # Recibe una nueva noticia y la agrega al feed actual
        IO.puts("Nueva noticia recibida: #{new_entry.title} - #{new_entry.description}")
        process_feed(news ++ [new_entry])

      after
        6000 ->  # Esperar 6 segundos antes de recibir el próximo mensaje
          IO.puts("No hay mensajes, verificando el feed RSS...")

          feed = simulated_feed()
          updated_news = news ++ feed

          Enum.each(updated_news, fn entry ->
            IO.puts("Título: #{entry.title} - Descripción: #{entry.description}")
          end)

          process_feed(updated_news)
    end
  end

  @doc """
  Ejecuta la aplicación simulado la recepción del feed y la llegada de nuevas noticias.
  Además, permite al usuario agregar noticias de manera interactiva.
  """
  def run do
    pid = start()

    # Simular la recepción del feed inicial
    :timer.sleep(6000)
    send(pid, {:get_feed, self()})

    # Recibir el mensaje de confirmación de que las noticias fueron procesadas
    receive do
      :done ->
        IO.puts("El feed RSS simulado fue procesado correctamente.")
    after
      7000 ->
        IO.puts("Timeout: No se recibió respuesta del proceso.")
    end

    # Simular la llegada de nuevas noticias automáticamente
    :timer.sleep(10000)
    send(pid, {:new_news, %{title: "Noticia 4", description: "Descripción de la noticia 4"}})

    # Simular la llegada de más noticias después de 12 segundos
    :timer.sleep(12000)
    send(pid, {:new_news, %{title: "Noticia 5", description: "Descripción de la noticia 5"}})

    # Permitir al usuario agregar nuevas noticias manualmente
    user_add_news(pid)
  end

  @doc """
  Permite al usuario agregar nuevas noticias de manera interactiva desde la consola.
  El usuario puede ingresar el título y la descripción de la noticia.
  """
  defp user_add_news(pid) do
    IO.puts("\n¿Deseas agregar una nueva noticia? (sí/no)")
    case String.trim(IO.gets("")) do
      "sí" ->
        IO.puts("Introduce el título de la noticia:")
        title = String.trim(IO.gets(""))

        IO.puts("Introduce la descripción de la noticia:")
        description = String.trim(IO.gets(""))

        # Enviar la nueva noticia al proceso asíncrono
        send(pid, {:new_news, %{title: title, description: description}})

        IO.puts("Noticia agregada exitosamente.")

        # Preguntar si quiere agregar otra noticia
        user_add_news(pid)

      "no" ->
        IO.puts("Terminando la aplicación. Gracias.")
        :ok

      _ ->
        IO.puts("Opción no válida, intenta nuevamente.")
        user_add_news(pid)
    end
  end
end
