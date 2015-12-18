cat > ~/.ssh/id_rsa <<EOF
-----BEGIN RSA PRIVATE KEY-----
xxx
-----END RSA PRIVATE KEY-----
EOF

cat > ~/.ssh/id_rsa.pub <<EOF
ssh-rsa xxx xxx@ischool.berkeley.edu
EOF


eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa