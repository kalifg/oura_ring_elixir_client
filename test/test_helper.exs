ExUnit.start()

# Define a mock for Req (HTTP client)
Mox.defmock(OuraRing.HTTPClientMock, for: OuraRing.HTTPClientBehaviour)
