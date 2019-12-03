defmodule Lotd do
  @moduledoc """
  Lotd keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Lotd.PubSub, topic)
  end

  def broadcast_change({:ok, result}, topic, event) do
    Phoenix.PubSub.broadcast(Lotd.PubSub, topic, {__MODULE__, event, result})
    {:ok, result}
  end

  def broadcast_change({:error, result}, _topic, _event) do
    {:error, result}
  end
end
