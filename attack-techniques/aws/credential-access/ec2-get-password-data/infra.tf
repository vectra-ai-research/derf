# None required except random strings for random instances

resource "random_string" "random" {
  length = 16
  special = false
  upper   = false
}