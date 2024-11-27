# LibreOffice-Server

LibreOffice Service 服务，用于在线编辑文档和通过Web API转换Word为PDF。Web API基于 [LibreOffice service App](https://github.com/funnyzak/libreoffice-server)。

Docker Pull Command: `docker pull funnyzak/libreoffice-server`


---


## Usage

可以通过以下Compose启动服务。
### Compose 

```yml
version: "3.1"
services:
  libreoffice:
    image: funnyzak/libreoffice-server
    container_name: libreoffice
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
    # volumes:
    #   - ./media/fonts:/usr/share/fonts/custom # 自定义字体
    ports:
      - 3000:3000 # libreoffice web editor
      - 3001:8038 # web api
    restart: unless-stopped
```
