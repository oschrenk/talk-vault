<!-- $theme: default -->
<!-- $size: 16:9 -->
<!-- page_number: true -->

# Secret Managment with [Vault](https://www.vaultproject.io/)

# ![center](images/vault.jpg)

###### Oliver Schrenk ( [@oschrenk](https://github.com/oschrenk) )

---

# What is a Secret?

* anything that is used for Authentication or Authorization (password, token, keys)

---

# What is Senstive Information?

* anything that you deem confidentiual (credit card number, email address, ...). 
* can't be used directly for authentication or authorization
* normally much higher in volume
---

# What is Secret Managment?

Proper secret managment answers these questions:

* How do your applications get secrets?
* How do humans aquire secrets?
* How are your secrets updated?
* How is a secret revoked?
* When were secrets used?
* What do we do in the event of compromise?

---

# Current State

* Secret Sprawl (github, wiki, email, ansible, ...)
	* Decentralized
	* Limited Visibility (where is that pasword)
	* Limited Visibility (who is using that password)
* No "Break Glass" procedures. What happens when compromised.

---

# What are the goals of Vault?

1. Be single source of secrets
2. Offer access for humans
3. Offer access for machines
4. Practical security primitives

---

# What is Vault?

1. Key/Value store for secrets
2. CLI interface for humans
3. REST API interface for machines
4. Strong defaults around lease, renewal, revocation
5. Access Control
6. Plugin Architecure

---

# Runing Vault

```
brew install vault
```

```
$ vim config.hcl
storage "file" {
  path = "/Users/oliver/vault"
}


listener "tcp" {
  address     = "127.0.0.1:8200"
    tls_disable = 1
}

default_lease_ttl: "240h"
max_lease_ttl:     "720h"

```

```
vault server --config config.hcl
```

---

# Usage demo

```
export VAULT_ADDR='http://127.0.0.1:8200'
```


---

# Key/Value store: Initialize


```
vault init 
Unseal Key 1: +pPxXCW+q9dDjjaYnSZAzBmFmXGahhSm9R2J1CH7TXKt
Unseal Key 2: bqgImd0wh2t2RvXYslXY6jK1Cy/0yOfXH+F5BVZESih1
Unseal Key 3: FmRNPhlgRbqJSkywiHdnrGa4gkroPix2JX4L33yrG+wj
Unseal Key 4: zppsVLvThYwr4mfJwz58LuJ585RLdpZDsHXgKVGC/u+x
Unseal Key 5: 7Sd3X+3n3ZxO5jwGDXahNQ/h5WBdo15vJ+Uh3Av2WGK+
Initial Root Token: 162ca96a-5522-803c-515d-df8ca188e8bd

Vault initialized with 5 keys and a key threshold of 3. Please
securely distribute the above keys. When the vault is re-sealed,
restarted, or stopped, you must provide at least 3 of these keys
to unseal it again.

Vault does not store the master key. Without at least 3 keys,
your vault will remain permanently sealed.
```

---

# Key/Value store: Unseal

```
vault unseal
Key (will be hidden):
Sealed: true
Key Shares: 5
Key Threshold: 3
Unseal Progress: 1
Unseal Nonce: 233e8946-40c7-24ad-9241-d49066b6b123
```

---

# Key/Value store: Writing/Reading secrets

```
vault write secret/ev/database password=mysecretpassword
Success! Data written to: secret/ev/database
vault write secret/test/app password=mypass
Success! Data written to: secret/test/app
```
```
vault read secret/ev/database
Key                     Value
---                     -----
refresh_interval        768h0m0s
password                mysecretpassword

```

---

# Access Control: Create a policy

```
vault policy-write ev-star-readonly - <<EOH
path "secret/ev/*" {
  capabilities = ["read"]
}
EOH
```

---

# Create a token 

```
vault token-create \
  --policy="ev-star-readonly" \
Key             Value
---             -----
token           dee81b65-23c3-4809-6f92-29f25d4d9231
token_accessor  cdae9db5-c952-a913-f3d2-407ed8be3d50
token_duration  240h0m0s
token_renewable true
token_policies  [default ev-star-readonly]
```
---

# Tokens should expire!

---

# Create a limited token 

```
vault token-create \
  --policy="ev-star-readonly" \
  --ttl="1h" \
  --use-limit=5
Key             Value
---             -----
token           dee81b65-23c3-4809-6f92-29f25d4d9231
token_accessor  cdae9db5-c952-a913-f3d2-407ed8be3d50
token_duration  240h0m0s
token_renewable true
token_policies  [default ev-star-readonly]

```

---

# Lookup


```
vault token-lookup 928dfdd8-b60d-dbd7-2cf7-7414cb41927b
Key                     Value
---                     -----
creation_time           1510139915
creation_ttl            604800
expire_time             2017-11-15T11:18:35.5829493Z
explicit_max_ttl        0
issue_time              2017-11-08T11:18:35.5829439Z
num_uses                0
ttl                     604690
...
```

---

# Token hierarchy

* You can create tokens with other tokens 
* if you revoke a token all child tokens will be revoked

---

# REST API interface for machines

```
$ curl --fail \
    -H "Content-Type: application/json" \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -X GET \
    http://127.0.0.1:8200/v1/vdb/database
```
```
$ curl --fail \
    -H "Content-Type: application/json" \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -X POST \
    -d '{"password":"abc123"}' \
    http://127.0.0.1:8200/v1/secret/foo
```

---

# Takeaways

That was very basic usage and ideas.

Big takeaways: 

* don't expose static secrets
* give access to secrets via token
* use tokens with expiration
* token access can be audited/revoked
* **Limit exposure of secrets**

---

# How do you use it?


Deployment secrecy

Runtime secrecy

Cubbyholing

Future: Dynamic secrets

Future: Encryption service

---

# Deployment secrecy

* Push model
* Your CI/CD system has access to Vault
* Pushes secrets via ENV to app

---

# Problems?

---

# Problems with Deployment Secrecy

* env variables are logged
* CI/CD needs to know which variables are used. Dev depends on Op.

---

# Runtime secrecy

* Pull Model
* Your application has access to Vault
* Pulls secret from Vault as needed. Dev independent.

---

# Problems?

* Your app needs a token
* How do get that token to the app?

---

# ![center 150% ](images/turtles.png)

---

# Cubbyholing

Scenario: 

* Jenkins (a trusted entity) 
* An app that wants access
* Jenkins is deploying that app
* Vault has the secrets

Hoe do we solve the issue of the initial token?
Or MITM attacks for that matter?

---


# Cubbyholing

1. Jenkins has DEPLOYER token with root access.
2. Jenkins creates TEMP token with short ttl:60s and num_use:2
3. Jenkins create PERM token with access to `secret/app`

---

# Cubbyholing

4. Jenkins puts PERM token into  `cubbyhole/app` using TEMP token
5. Jenkins propagates TEMP token to app
6. App uses TEMP token to get PERM token
7. App uses PERM token to access `secret/app`

---

# Cubbyholing

* You can't prevent those attacks
* But you can detect them

---

# Ehm? How does Jenkins get it's token?

---


# ![center 150% ](images/turtles.png)

---

# Future: Dynamic secrets

Problem: Databases have very static paswords

---

# Future: Dynamic secrets

Idea: 

* Vault (and Vault only) has master access to your database
* App asks for Vault for database access 
* Vault can create credentials
* Vault creates a temporary user
* Vault gives credentials to app

---

# Future: Encryption as a service

Problem: As a developer I don't want to think about encryption

---

# Future: Encryption as a service

Idea: Move encryption to Vault. Pass it data, get it back encrypted.

---

# Other Vault features

* Vault can act as CA and distribute certificates and keys
* SSH Key signing to log into hosts
* ...

---

# Unexplored

* How to properly setup Vault inside your infrastructure?
	* Snowflake machine
	* SSL
	* Policies
	* Authentication Providers
* Token renewal/refresh

---

## Learned

* **Limit exposure of secrets** 
* Static secrets are bad, tokens with lease are good.
* Build systems that withstand leaks
* Build "break glass" procedure in mind
* Using Vault will expose infrastructure weakness
* Secret introduction is hard

---

# To learn

* Defining you break glass procedures
	* What are your secrets?
	* What is the worst case?
	* How can I detect worst case?
	* What is the procedure to to turn off the leak?

---

# Questions?