defmodule DetranCrawler do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://simulado.detran.rj.gov.br/simulados/iniciarProva/habilitacao"
  plug Tesla.Middleware.JSON

  def get_questions() do
    get_document() |> get_only_questions()
  end

  defp get_document(), do: get("") |> handle_request()

  defp get_only_questions({_, body}) do
    [_, inner] = Regex.run(~r/var questoes = {\"Questao\":\[(.*);/, body)
    inner
  end

  defp handle_request(result) do
    case result do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      {:error, _} = error -> error
    end
  end
end
