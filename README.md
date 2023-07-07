# Moneta

This is a coding test for a job.

In this assignment, you are tasked with building an API that computes a moving average across
OHLC data.

### Requirements

1. POST /api/insert - adds data to the application
2. GET /api/average?window=last_10_items - should return the moving
   average of the last 10 items
3. GET /api/average?window=last_1_hour - should return the moving average
   of all items that were inserted to the data store in the past hour

##### Note: 

The moving average is of the closing price only.

### Data

You should create a mock dataset that you can work with for development and testing.
Sample Record

```json
{
  "timestamp": "2021-09-01T08:00:00Z",
  "open": 16.83,
  "high": 19.13,
  "low": 15.49,
  "close": 16.04
}
```

### Guidelines

1. You can implement the assignment using any language/ framework you find to suitable
for the task but using the Phoenix Framework is preferred.
2. While the guidelines for this assignment are very loose, you should assume that API will
be deployed to a production environment

### Extra 

It wasn't too much extra trouble so I also implemented `last_xx_minutes`/`last_xx_hours`/`last_xx_days`

### Livebook

There's also a Livebook for ease of external testing. Maybe you don't trust my tests. :) Try your own.

### Set up 

```bash
mix deps.get
mix ecto.setup
```

### Run

```bash
iex -S mix phx.server
```

### Tests

```bash
mix test
```