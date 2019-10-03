# Get your API Key from: https://www.namesilo.com/account_api.php
export NAMESILO_API='your namesilo api' && \
certbot certonly --manual --email youremail@example.com \
        --agree-tos --manual-public-ip-logging-ok \
        --preferred-challenges=dns \
        --manual-auth-hook /path/to/auth-release \
        --manual-cleanup-hook /path/to/clean-release \
        -d *.example.com -d example.com