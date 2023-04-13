# Performance Testing with Locust

This script uses the [Locust](https://docs.locust.io/en/stable/index.html) performance testing library to simulate concurrent 
users hitting the Lazarus quiz server. For my initial tests, I was pointing to the 
https://sntxrr.org server.

Most of the work here is taken directly from the [Locust Quickstart guide](https://docs.locust.io/en/stable/quickstart.html#quickstart). 
Undoubtedly, there's lots more interesting explorations to do.

## Prerequisites

You'll need to have Python3 and pip installed for the basic set up. Beyond that, you can
follow the instructions on the Locust website to [set up Locust on your machine](https://docs.locust.io/en/stable/installation.html).

## Usage

### Headless

You can run the following command to simulate 100 users simultaneously hitting the "/submit"
endpoint at the sntxrr.org host.

```bash
locust --headless --users 100 --spawn-rate 100 -t 10s -H https://sntxrr.org --csv lazarus
```

### Web UI

Per the instructions, if you run `locust` in this directory, you can access the tool via
Web UI at [https://localhost:8089](https://localhost:8089). Try running 100 users with
roughly 3 users spawned per second to see interesting results.
