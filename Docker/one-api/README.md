# one-api

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/one-api?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/one-api/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/one-api)](https://hub.docker.com/r/funnyzak/one-api/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/one-api.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/one-api/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/one-api.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/one-api/)

✨ Access all LLM through the standard OpenAI API format, easy to deploy & use ✨

This image is built with the `linux/amd64`, `linux/arm64` architectures.

## Docker Pull

```bash
docker pull funnyzak/one-api:latest
# GHCR 
docker pull ghcr.io/funnyzak/one-api:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/one-api:latest
```

## Deployment
### Docker Deployment
Deployment command: `docker run --name one-api -d --restart always -p 3000:3000 -e TZ=Asia/Shanghai -v /home/ubuntu/data/one-api:/data funnyzak/one-api`

Update command: `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower -cR`

The first `3000` in `-p 3000:3000` is the port of the host, which can be modified as needed.

Data will be saved in the `/home/ubuntu/data/one-api` directory on the host. Ensure that the directory exists and has write permissions, or change it to a suitable directory.

Nginx reference configuration:
```
server{
   server_name openai.justsong.cn;  # Modify your domain name accordingly

   location / {
          client_max_body_size  64m;
          proxy_http_version 1.1;
          proxy_pass http://localhost:3000;  # Modify your port accordingly
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_cache_bypass $http_upgrade;
          proxy_set_header Accept-Encoding gzip;
   }
}
```

Next, configure HTTPS with Let's Encrypt certbot:
```bash
# Install certbot on Ubuntu:
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
# Generate certificates & modify Nginx configuration
sudo certbot --nginx
# Follow the prompts
# Restart Nginx
sudo service nginx restart
```

The initial account username is `root` and password is `123456`.

## More

More information can be found in the [one-api GitHub repository](https://github.com/songquanpeng/one-api).