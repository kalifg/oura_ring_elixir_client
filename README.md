# Oura Ring Elixir Client

An Elixir client library for interacting with the Oura Ring API v2. This library provides a simple, idiomatic Elixir interface for accessing your Oura Ring health and sleep data.

## Features

- Retrieve personal information from your Oura Ring account
- Built using Test-Driven Development (TDD) principles
- Comprehensive error handling
- Clean, functional API design

## Installation

Add `oura_ring_elixir_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:oura_ring_elixir_client, "~> 0.1.0"}
  ]
end
```

Then run:

```bash
mix deps.get
```

### Note on Dependencies

The current implementation uses Erlang's built-in `:httpc` and custom JSON parsing due to development environment constraints. For production use, it's recommended to update the dependencies to use:

```elixir
def deps do
  [
    {:httpoison, "~> 2.0"},
    {:jason, "~> 1.4"}
  ]
end
```

## Configuration

### API Key

This library requires an Oura API access token. You can obtain one from the [Oura Cloud API Portal](https://cloud.ouraring.com/personal-access-tokens).

Set your API key as an environment variable:

```bash
export API_KEY="your_oura_api_token_here"
```

**Important**: Never commit your API key to version control. Always use environment variables or a secure secrets management system.

## Usage

### Get Personal Information

Retrieve your personal information from the Oura API:

```elixir
# Ensure your API_KEY environment variable is set
case Oura.Client.get_personal_info() do
  {:ok, data} ->
    IO.puts("Personal Info:")
    IO.inspect(data)

  {:error, :no_api_key} ->
    IO.puts("Error: API_KEY environment variable is not set")

  {:error, reason} ->
    IO.puts("Error retrieving personal info: #{inspect(reason)}")
end
```

### Response Format

Successful API calls return `{:ok, data}` where `data` is a map containing the response from the Oura API.

Error responses return `{:error, reason}` where `reason` can be:
- `:no_api_key` - API_KEY environment variable is not set
- `{:http_error, status_code, body}` - HTTP error from the API
- `{:json_parse_error, reason}` - Failed to parse JSON response
- `{:request_failed, reason}` - Network or connection error

### Example Response

```elixir
{:ok,
 %{
   "age" => 30,
   "weight" => 70.5,
   "height" => 1.75,
   "biological_sex" => "male",
   "email" => "user@example.com"
 }}
```

## Running Tests

Run the test suite:

```bash
# Run all tests except integration tests (which require a valid API key)
mix test --exclude integration

# Run all tests including integration tests (requires valid API_KEY)
mix test
```

## Development

This project follows Test-Driven Development (TDD) principles. When adding new features:

1. Write tests first that describe the expected behavior
2. Run tests to see them fail (Red phase)
3. Implement the minimum code to make tests pass (Green phase)
4. Refactor while keeping tests passing (Refactor phase)

## API Coverage

Currently implemented endpoints:

- [x] Personal Info (`/v2/usercollection/personal_info`)

Planned endpoints:

- [ ] Daily Sleep
- [ ] Daily Activity
- [ ] Daily Readiness
- [ ] Heart Rate
- [ ] Workouts
- [ ] Sessions
- [ ] Tags

## Security

- Never expose your API key in code, logs, or version control
- Use environment variables or secure secret management
- Be mindful of rate limits imposed by the Oura API
- Review the [Oura API documentation](https://cloud.ouraring.com/v2/docs) for data privacy and usage guidelines

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

See LICENSE file for details.

## Resources

- [Oura API Documentation](https://cloud.ouraring.com/v2/docs)
- [Oura Cloud Portal](https://cloud.ouraring.com/)
- [Elixir Documentation](https://elixir-lang.org/docs.html)

