# Secret managment with Vault

I had troubles getting the official image to work. This should work but doesn't
```
docker run --cap-add=IPC_LOCK -e 'VAULT_LOCAL_CONFIG={"backend": {"file": {"path": "/vault/file"}}, "default_lease_ttl": "168h", "max_lease_ttl": "720h"}' vault server
```

So I opted for my own image
```
docker run -v ~/Docker/vault/:/conf -p 8200:8200 oschrenk/vault:file
```

