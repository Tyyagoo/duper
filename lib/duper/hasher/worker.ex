defmodule Duper.Hasher.Worker do
  @type successful :: {:ok, {String.t(), String.t()}}
  @type failed :: {:error, Exception.t()}

  @spec run(String.t()) :: successful() | failed()
  def run(path) do
    IO.inspect(path, label: "Hashing")

    try do
      {:ok, {path, hash(path)}}
    rescue
      e ->
        IO.inspect(path, label: "Hash failed")
        {:error, e}
    end
  end

  defp hash(path) do
    File.stream!(path, [], 1024 * 1024)
    |> Enum.reduce(
      :crypto.hash_init(:md5),
      fn block, hash ->
        :crypto.hash_update(hash, block)
      end
    )
    |> :crypto.hash_final()
  end
end
