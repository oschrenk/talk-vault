
storage "file" {
  path = "/Users/oliver/vault"
}


listener "tcp" {
  address     = "127.0.0.1:8200"
    tls_disable = 1
}

default_lease_ttl = "240h"
max_lease_ttl =     "720h"
