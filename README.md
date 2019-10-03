# NameSilo Let's Encrypt

Automate obtaining [Let's Encrypt](https://letsencrypt.org/) certificates,
using [Certbot](https://certbot.eff.org/) DNS-01 challenge validation for domains DNS hosted on
[NameSilo](https://www.namesilo.com/).

Inspired by [namesilo-letsencrypt](https://github.com/ethauvin/namesilo-letsencrypt)

## Setup

### Build from source

Make sure you have installed [Go](https://golang.org), then

```bash
git clone https://github.com/countstarlight/namesilo-letsencrypt-go.git
cd namesilo-letsencrypt-go
make release
```


## Configuration

Add your [NameSilo API key](https://www.namesilo.com/account_api.php)
to the top of the `cert_example.sh` file and set your email and domains:

```bash
# Get your API Key from: https://www.namesilo.com/account_api.php
export NAMESILO_API='your namesilo api' && \
certbot certonly --manual --email youremail@example.com \
        --agree-tos --manual-public-ip-logging-ok \
        --preferred-challenges=dns \
        --manual-auth-hook /path/to/auth-release \
        --manual-cleanup-hook /path/to/clean-release \
        -d *.example.com -d example.com
```

then

```bash
sudo ./cert_example.sh
```

Please note that NameSilo DNS propagation takes up to **15 minutes**,
so the tools will wait 16 minutes before completing.

# License

[MIT](https://github.com/countstarlight/namesilo-letsencrypt-go/blob/master/LICENSE)

Copyright (c) 2019-present Codist

