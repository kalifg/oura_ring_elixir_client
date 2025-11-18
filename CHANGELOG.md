# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-18

### Added

- Initial release of the Oura Ring Elixir client library
- Complete support for Oura API v2 endpoints:
  - Daily Sleep data with comprehensive sleep analysis
  - Daily Activity metrics including steps, calories, and MET minutes
  - Daily Readiness scores with contributor breakdown
  - Daily Stress data (compatible ring generations)
  - Daily SpO2 blood oxygen data (Gen 3+ only)
  - Heart Rate intraday data (5-minute intervals)
  - Workout tracking and analysis
  - Session data (meditation, breathing exercises)
  - Enhanced Tags and legacy Tags support
  - Personal Information retrieval
  - Sleep Time recommendations
  - Rest Mode Period tracking
  - Ring Configuration details
- Automatic pagination handling for large datasets
- Clean, idiomatic Elixir API with pattern matching
- Comprehensive documentation with examples
- Full type specifications for all public functions
- Test fixtures for offline development and testing
- HealthWatch example application demonstrating real-world usage
- Support for both Date and DateTime filtering
- Configurable access token via application config or direct passing
- Error handling with descriptive error tuples

### Documentation

- Comprehensive README.md with installation, configuration, and usage examples
- Detailed moduledocs for all modules
- HealthWatch example showing how to poll and display Oura data
- Integration checklist for manual testing
- Complete API reference documentation

### Developer Experience

- Mix project configuration ready for Hex publication
- Test suite with fixtures
- Code formatting with `mix format`
- Support for Credo and Dialyzer
- Continuous integration friendly

### Known Limitations

- Personal Access Token authentication only (OAuth2 support planned)
- No automatic rate limiting (users should implement backoff strategies)
- Requires Elixir 1.14 or later
- Personal Access Tokens will be deprecated by Oura at end of 2025

### Dependencies

- `req` ~> 0.4.0 - HTTP client
- `jason` ~> 1.4 - JSON encoding/decoding
- `mox` ~> 1.1 - Testing mocks (test only)
- `excoveralls` ~> 0.18 - Test coverage (test only)
- `ex_doc` ~> 0.31 - Documentation generation (dev only)
- `credo` ~> 1.7 - Code quality (dev/test only)
- `dialyxir` ~> 1.4 - Static analysis (dev/test only)

## [Unreleased]

### Planned Features

- OAuth2 authentication support (to replace Personal Access Tokens before EOY 2025)
- Webhook support for real-time data updates
- Rate limiting with automatic backoff and retry
- Batch request support
- Data caching layer
- StreamData-based property testing
- More comprehensive integration tests
- TypedStruct for response data structures
- GenServer-based client for connection pooling
- Telemetry events for monitoring and observability

### Under Consideration

- Support for Oura API v1 (if needed for backward compatibility)
- Custom data transformers and processors
- Built-in data visualization helpers
- Export to common formats (CSV, JSON, etc.)
- Integration with Phoenix LiveView for dashboards
- Ecto schemas for Oura data persistence

---

## Version History

- **0.1.0** (2025-01-18) - Initial release

For upgrade instructions and migration guides, see the [README.md](README.md).

## Links

- [Oura API Documentation](https://cloud.ouraring.com/v2/docs)
- [GitHub Repository](https://github.com/kalifg/oura_ring_elixir_client)
- [Hex Package](https://hex.pm/packages/oura_ring)
- [HexDocs](https://hexdocs.pm/oura_ring)
