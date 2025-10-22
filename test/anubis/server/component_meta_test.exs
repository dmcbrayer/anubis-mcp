defmodule Anubis.Server.ComponentMetaTest do
  use ExUnit.Case, async: true

  alias Anubis.Server.Component.Tool
  alias Anubis.Server.Component.Resource
  alias Anubis.Server.Component.Prompt

  describe "Tool with _meta" do
    defmodule MetaTool do
      @moduledoc "Tool with _meta"

      use Anubis.Server.Component,
        type: :tool,
        meta: %{"version" => "2.0", "vendor/custom" => "value"}

      alias Anubis.Server.Response

      schema do
        field :name, {:required, :string}
      end

      @impl true
      def execute(_params, frame) do
        {:reply, Response.tool() |> Response.text("test"), frame}
      end
    end

    test "includes _meta in Tool struct" do
      tool = %Tool{
        name: "test",
        description: "test",
        input_schema: %{},
        meta: %{"key" => "value"}
      }

      assert tool.meta == %{"key" => "value"}
    end

    test "encodes _meta in JSON" do
      tool = %Tool{
        name: "test",
        description: "test",
        input_schema: %{},
        meta: %{"key" => "value"}
      }

      encoded = JSON.encode!(tool)
      decoded = JSON.decode!(encoded)

      assert decoded["_meta"] == %{"key" => "value"}
    end

    test "does not include empty _meta in JSON" do
      tool = %Tool{
        name: "test",
        description: "test",
        input_schema: %{}
      }

      encoded = JSON.encode!(tool)
      decoded = JSON.decode!(encoded)

      refute Map.has_key?(decoded, "_meta")
    end

    test "component is parsed with _meta from use macro" do
      # Parse the component module like the server does
      [tool] = Anubis.Server.parse_components({:tool, "meta_tool", MetaTool})

      assert tool.meta == %{"version" => "2.0", "vendor/custom" => "value"}
    end
  end

  describe "Resource with _meta" do
    defmodule MetaResource do
      @moduledoc "Resource with _meta"

      use Anubis.Server.Component,
        type: :resource,
        uri: "file://test.txt",
        meta: %{"cached" => true}

      alias Anubis.Server.Response

      @impl true
      def read(_params, frame) do
        {:reply, Response.resource() |> Response.text("content"), frame}
      end
    end

    test "includes _meta in Resource struct" do
      resource = %Resource{
        uri: "file://test.txt",
        name: "test",
        meta: %{"cached" => true}
      }

      assert resource.meta == %{"cached" => true}
    end

    test "encodes _meta in JSON" do
      resource = %Resource{
        uri: "file://test.txt",
        name: "test",
        mime_type: "text/plain",
        meta: %{"cached" => true}
      }

      encoded = JSON.encode!(resource)
      decoded = JSON.decode!(encoded)

      assert decoded["_meta"] == %{"cached" => true}
    end

    test "component is parsed with _meta from use macro" do
      # Parse the component module like the server does
      [resource] = Anubis.Server.parse_components({:resource, "meta_resource", MetaResource})

      assert resource.meta == %{"cached" => true}
    end
  end

  describe "Prompt with _meta" do
    defmodule MetaPrompt do
      @moduledoc "Prompt with _meta"

      use Anubis.Server.Component,
        type: :prompt,
        meta: %{"category" => "chat"}

      alias Anubis.Server.Response

      schema do
        field :message, {:required, :string}
      end

      @impl true
      def execute(_params, frame) do
        {:reply, Response.prompt() |> Response.user_message("test"), frame}
      end
    end

    test "includes _meta in Prompt struct" do
      prompt = %Prompt{
        name: "test",
        meta: %{"category" => "chat"}
      }

      assert prompt.meta == %{"category" => "chat"}
    end

    test "encodes _meta in JSON" do
      prompt = %Prompt{
        name: "test",
        arguments: [],
        meta: %{"category" => "chat"}
      }

      encoded = JSON.encode!(prompt)
      decoded = JSON.decode!(encoded)

      assert decoded["_meta"] == %{"category" => "chat"}
    end

    test "component is parsed with _meta from use macro" do
      # Parse the component module like the server does
      [prompt] = Anubis.Server.parse_components({:prompt, "meta_prompt", MetaPrompt})

      assert prompt.meta == %{"category" => "chat"}
    end
  end
end
