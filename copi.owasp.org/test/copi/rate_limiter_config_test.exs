defmodule Copi.RateLimiterConfigTest do
  use ExUnit.Case, async: false

  alias Copi.RateLimiter

  describe "test environment configuration" do
    test "rate limiter has high limits in test environment" do
      config = RateLimiter.get_config()
      
      # In test environment, we expect very high limits
      assert config.game_creation.max_requests == 100_000
      assert config.player_creation.max_requests == 100_000
      assert config.connection.max_requests == 100_000
    end

    test "allows many player creations without rate limiting" do
      # Use a unique IP for this test
      ip = "10.100.100.#{:rand.uniform(255)}"
      
      # Should be able to create 50 players without being rate limited
      # (default limit is 20, but test config should be 100,000)
      for i <- 1..50 do
        assert {:ok, _remaining} = RateLimiter.check_and_record(ip, :player_creation),
          "Player creation #{i} should be allowed with test configuration"
      end
    end

    test "allows many game creations without rate limiting" do
      # Use a unique IP for this test
      ip = "10.101.101.#{:rand.uniform(255)}"
      
      # Should be able to create 30 games without being rate limited
      # (default limit is 10, but test config should be 100,000)
      for i <- 1..30 do
        assert {:ok, _remaining} = RateLimiter.check_and_record(ip, :game_creation),
          "Game creation #{i} should be allowed with test configuration"
      end
    end
  end
end
