defmodule DetranCrawler do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://simulado.detran.rj.gov.br/simulados/iniciarProva/habilitacao"
  plug Tesla.Middleware.JSON

  def get_questions() do
    get_document()
    |> get_only_questions()
    |> clean_nil_values()
    |> add_question_id()
    |> save_questions()
    IO.puts("File questions.json saved!")
  end

  defp get_only_questions(body) do
    [_, inner] = Regex.run(~r/var questoes = {\"Questao\":(\[.*)};/, body)
    inner |> Jason.decode!()
  end

  defp add_question_id(questions) do
    Enum.map(
      questions,
      fn (question) ->
        id = :crypto.hash(:sha256, Map.get(question, "desc_questao")) |> Base.encode16
        Map.put(question, "id", id)
      end
    )
  end

  defp clean_nil_values(json) do
    Enum.filter(json, &(!is_nil(&1)))
  end

  defp save_questions(questions) do
    encoded_questions = Jason.encode!(questions)
    File.write("questions.json", encoded_questions)
  end

  defp get_document(), do: get("") |> handle_request()

  defp handle_request(result) do
    case result do
      {:ok, %Tesla.Env{status: 200, body: body}} ->  body
      {:error, _} = error -> error
    end
  end
end
