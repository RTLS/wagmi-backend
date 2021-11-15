defmodule SharedUtils.HTTP do
  @moduledoc """
  Utility functions to deal with HTTP responses

  To use this we must first stick this into our application.ex
  if we want to use the default pooling setup

  ```elixir
  children = [SharedUtils.HTTP]
  ```

  The other way to use this is to create a child_spec on another module and use
  this to setup your own module

  ### Example

  ```elixir
  defmodule MyThingHttp do
    @app_name :my_thing_http

    # Pool settings are https://hexdocs.pm/finch/0.7.0/Finch.html#child_spec/1
    # size - Number of connections per pool (think http connections)
    # count - Number of pools
    @default_opts [
      name: @app_name,
      atomize_keys?: true,
      pools: [
        "google.ca": [size: 10, count: 20],

        default: [
          size: 10,
          count: 10,
          max_idle_time: 500,
          conn_opts: [transport_opts: [timeout: :timer.seconds(5)]]
        ]
      ]
    ]

    def child_spec(opts), do: SharedUtils.HTTP.child_spec({@app_name, opts})

    def get(url, headers \\ [], opts \\ []) do
      SharedUtils.HTTP.get(url, headers, Keyword.merge(opts, @default_opts))
    end
  end
  ```

  Then in your code you can use

  ```elixir
  {:ok, %SharedUtils.HTTP.Response{body: body}} = MyThingHttp.get("google.ca")
  ```
  """

  require Logger

  alias SharedUtils.ConfigEnforcer

  @default_name :http_shared
  @default_options [
    name: @default_name,
    atomize_keys?: false,
    http: [get: nil, post: nil, sandbox: Mix.env() === :test],
    pools: [default: [size: 10]]
  ]

  defmodule Options do
    @moduledoc false
    @enforce_keys [:name, :pools]
    defstruct [:atomize_keys?, :http, :receive_timeout, :params | @enforce_keys]
  end

  defmodule Response do
    @moduledoc false
    defstruct [
      :status,
      body: "",
      headers: [],
      request: %Finch.Request{
        host: "",
        body: "",
        query: "",
        path: "/",
        port: 80,
        method: "",
        scheme: nil,
        headers: []
      }
    ]
  end

  @type t_res :: {:ok, {map | Enum.t(), %Response{}}} | {:error, SharedUtils.Error.t()}

  @spec start_link() :: GenServer.on_start()
  @spec start_link(atom) :: GenServer.on_start()
  @spec start_link(atom, Keyword.t()) :: GenServer.on_start()
  def start_link(name \\ @default_name, opts \\ []) do
    @default_options
    |> Keyword.merge(opts)
    |> ConfigEnforcer.validate!(Options)
    |> Keyword.put(:name, name)
    |> Keyword.update!(:pools, &ensure_default_pool_exists/1)
    |> Finch.start_link()
  end

  defp ensure_default_pool_exists(pool_configs) when is_list(pool_configs) do
    pool_configs |> Map.new() |> ensure_default_pool_exists
  end

  defp ensure_default_pool_exists(%{default: _} = pool_config), do: pool_config

  defp ensure_default_pool_exists(pool_config) do
    Map.put(pool_config, :default, @default_options[:pools][:default])
  end

  def child_spec(name) when is_atom(name) do
    %{
      id: name,
      start: {SharedUtils.HTTP, :start_link, [name]}
    }
  end

  def child_spec({name, opts}) do
    %{
      id: name,
      start: {SharedUtils.HTTP, :start_link, [name, opts]}
    }
  end

  def child_spec(opts) do
    opts = Keyword.put_new(opts, :name, @default_name)

    %{
      id: opts[:name],
      start: {SharedUtils.HTTP, :start_link, [opts[:name], opts]}
    }
  end

  def make_get_request(url, headers, options) do
    request = Finch.build(:get, url, headers)

    make_request(request, options)
  end

  def make_post_request(url, body, headers, options) do
    request = Finch.build(:post, url, headers, body)

    make_request(request, options)
  end

  defp make_request(request, options) do
    with {:ok, response} <- Finch.request(request, options[:name], options) do
      {:ok,
       %Response{
         request: request,
         body: response.body,
         status: response.status,
         headers: response.headers
       }}
    end
  end

  defp append_query_params(url, nil), do: url

  defp append_query_params(url, params) do
    "#{url}?#{params |> encode_query_params |> Enum.join("&")}"
  end

  defp encode_query_params(params) do
    Enum.flat_map(params, fn
      {k, v} when is_list(v) -> Enum.map(v, &encode_key_value(k, &1))
      {k, v} -> [encode_key_value(k, v)]
    end)
  end

  defp encode_key_value(key, value), do: URI.encode_query(%{key => value})

  @spec post(String.t(), map) :: t_res
  @spec post(String.t(), map, Keyword.t()) :: t_res
  @spec post(String.t(), map, Keyword.t(), Keyword.t()) :: t_res
  def post(url, body, headers \\ [], options \\ []) do
    options = Keyword.merge(@default_options, options)
    http_post = options[:http][:post] || (&make_post_request/4)
    sandbox? = options[:http][:sandbox]

    if sandbox? do
      sandbox_post_response(url, headers, options)
    else
      url
      |> append_query_params(options[:params])
      |> http_post.(serialize_body(body), headers, options)
      |> handle_response(options)
    end
  end

  defp serialize_body(params) when is_list(params) or is_map(params), do: Jason.encode!(params)
  defp serialize_body(params), do: params

  @spec get(String.t()) :: t_res
  @spec get(String.t(), Keyword.t()) :: t_res
  @spec get(String.t(), Keyword.t(), Keyword.t()) :: t_res
  def get(url, headers \\ [], options \\ []) do
    options = Keyword.merge(@default_options, options)
    http_get = options[:http][:get] || (&make_get_request/3)
    sandbox? = options[:http][:sandbox]

    if sandbox? && !sandbox_disabled?() do
      sandbox_get_response(url, headers, options)
    else
      fn ->
        url
        |> append_query_params(options[:params])
        |> http_get.(headers, options)
      end
      |> run_and_measure(headers, options)
      |> handle_response(options)
    end
  end

  if Mix.env() === :test do
    defdelegate sandbox_get_response(url, headers, options),
      to: SharedUtils.Support.HTTPSandbox,
      as: :get_response

    defdelegate sandbox_post_response(url, headers, options),
      to: SharedUtils.Support.HTTPSandbox,
      as: :post_response

    defdelegate sandbox_disabled?, to: SharedUtils.Support.HTTPSandbox
  else
    defp sandbox_get_response(url, _, _) do
      raise """
      Cannot use HTTPSandbox outside of test
      url requested: #{inspect(url)}
      """
    end

    defp sandbox_post_response(url, _, _) do
      raise """
      Cannot use HTTPSandbox outside of test
      url requested: #{inspect(url)}
      """
    end

    defp sandbox_disabled?, do: true
  end

  defp run_and_measure(fnc, headers, options) do
    start_time = System.monotonic_time()

    response = fnc.()

    metadata = %{
      start_time: System.system_time(),
      request: %{
        method: "GET",
        headers: headers
      },
      response: response,
      options: options
    }

    end_time = System.monotonic_time()
    measurements = %{elapsed_time: end_time - start_time}
    :telemetry.execute([:http, Keyword.get(options, :name)], measurements, metadata)

    response
  end

  defp handle_response({:ok, %Response{status: 200, body: body} = raw_data}, opts) do
    res =
      body
      |> Jason.decode!()
      |> ProperCase.to_snake_case()

    res = if opts[:atomize_keys?], do: SharedUtils.Enum.atomize_keys(res), else: res

    {:ok, {res, raw_data}}
  end

  defp handle_response({:ok, %Response{status: 204} = raw_data}, _opts) do
    {:ok, raw_data}
  end

  defp handle_response({:ok, %{status: code} = res}, opts) do
    api_name = opts[:name]
    details = %{response: res, http_code: code, api_name: api_name}
    error_code_map = error_code_map(api_name)

    if Map.has_key?(error_code_map, code) do
      {error, message} = Map.get(error_code_map, code)

      {:error, apply(SharedUtils.Error, error, [message, details])}
    else
      message = unknown_error_message(api_name)
      {:error, SharedUtils.Error.internal_server_error(message, details)}
    end
  end

  defp handle_response({:error, e}, opts) when is_binary(e) or is_atom(e) do
    message = "#{opts[:name]}: #{e}"
    {:error, SharedUtils.Error.internal_server_error(message, %{error: e})}
  end

  defp handle_response({:error, e}, opts) do
    message = unknown_error_message(opts[:name])
    {:error, SharedUtils.Error.internal_server_error(message, %{error: e})}
  end

  defp handle_response(e, opts) do
    message = unknown_error_message(opts[:name])
    {:error, SharedUtils.Error.internal_server_error(message, %{error: e})}
  end

  def unknown_error_message(api_name) do
    "#{api_name}: unknown error occurred"
  end

  def error_code_map(api_name) do
    %{
      400 => {:bad_request, "#{api_name}: bad request"},
      401 => {:unauthorized, "#{api_name}: unauthorized request"},
      403 => {:forbidden, "#{api_name}: forbidden"},
      404 => {:not_found, "#{api_name}: there's nothing to see here :("},
      405 => {:method_not_allowed, "#{api_name}: method not allowed"},
      415 => {:unsupported_media_type, "#{api_name}: unsupported media type in request"},
      429 => {:too_many_requests, "#{api_name}: exceeded rate limit"},
      500 => {:internal_server_error, "#{api_name}: internal server error during request"},
      502 => {:bad_gateway, "#{api_name}: bad gateway"},
      503 => {:service_unavailable, "#{api_name}: service unavailable"},
      504 => {:gateway_timeout, "#{api_name}: gateway timeout"}
    }
  end
end
