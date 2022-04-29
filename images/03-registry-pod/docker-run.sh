docker run -it \
  --name registry \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/k8sdemo-registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/k8sdemo-registry.key \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/certs/htpasswd \
  -p 443:443 \
  --rm \
  uchimata/k8sdemo-registry


  -v registry:/var/lib/registry \


testuser testpassword

curl -k --user testuser:testpassword https://localhost:443/v2/_catalog