#!/bin/bash
# Install Docker
yum install -y docker

service docker start

cat << EOF >> /etc/fstab
/dev/xvdg   /webroot          ext4 defaults             1 2
EOF

mkdir /webroot
chmod 777 /webroot
sleep 300
mount /webroot

cat << EOF > /webroot/index.html
<h1>Hello AWS World</h1>
<a href="https://github.com/c4po/aws-fundamentals">source code</a>
EOF

docker run -d --name awsdemo -v /webroot:/usr/share/nginx/html:ro -p 80:80 --restart always nginx
