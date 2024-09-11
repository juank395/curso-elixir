defmodule TaskManager do
  defstruct tasks: []

  defmodule Task do
    defstruct id: 0, description: "", completed: false
  end

  def add_task(%TaskManager{tasks: tasks} = task_manager, description) do
    task = %Task{id: Enum.count(tasks) + 1, description: description, completed: false}
    %{task_manager | tasks: tasks ++ [task]}
  end

  def list_tasks(%TaskManager{tasks: tasks}) do
    for task <- tasks do
      IO.puts "#{task.id}. #{task.description} [#{if task.completed, do: "x", else: " "}]"
    end
  end

  def complete_task(%TaskManager{tasks: tasks} = task_manager, task_id) do
    updated_tasks = Enum.map(tasks, fn task ->
      if task.id == task_id do
        %Task{task | completed: true}
      else
        task
      end
    end)
    %{task_manager | tasks: updated_tasks}
  end

  def run() do
    task_manager = %TaskManager{}
    task_manager = add_task(task_manager, "Comprar leche")
    task_manager = add_task(task_manager, "Comprar pan")
    task_manager = add_task(task_manager, "Comprar huevos")

    list_tasks(task_manager)

    IO.puts "Completando tarea 2..."

    task_manager = complete_task(task_manager, 2)
    list_tasks(task_manager)
  end
end
