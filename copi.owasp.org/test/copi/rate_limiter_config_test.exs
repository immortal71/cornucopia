defmodule Copi.RateLimiterConfigTest do
  use ExUnit.Case, async: false

  alias Copi.RateLimiter

  setup do
    # Generate deterministic unique IP for each test to avoid collisions
    test_id = :erlang.unique_integer([:positive])
    ip = "10.#{rem(test_id, 256)}.#{div(test_id, 256) |> rem(256)}.#{div(test_id, 65536) |> rem(256)}"
    
    # Clear rate limiter state for this IP to ensure test isolation
    RateLimiter.clear_ip(ip)
    
    {:ok, ip: ip}
  end

  describe "test environment configuration" do
    test "rate limiter has high limits in test environment" do
      config = RateLimiter.get_config()
      
      # In test environment, we expect very high limits
      assert config.game_creation.max_requests == 100_000
      assert config.player_creation.max_requests == 100_000
      assert config.connection.max_requests == 100_000
    end

    test "allows many player creations without rate limiting", %{ip: ip} do
      # Should be able to create 50 players without being rate limited
      # (default limit is 20, but test config should be 100,000)
      for i <- 1..50 do
        assert {:ok, _remaining} = RateLimiter.check_and_record(ip, :player_creation),
          "Player creation #{i} should be allowed with test configuration"
      end
    end

    test "allows many game creations without rate limiting", %{ip: ip} do
      # Should be able to create 30 games without being rate limited
      # (default limit is 10, but test config should be 100,000)
      for i <- 1..30 do
        assert {:ok, _remaining} = RateLimiter.check_and_record(ip, :game_creation),
          "Game creation #{i} should be allowed with test configuration"
      end
    end
  end
end
