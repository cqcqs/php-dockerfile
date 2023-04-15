## cqcqs/php-dockerfile
PHP官方源镜像支持的扩展有限，自己基于原官方扩展之上，再做了一层包装，包含 `composer`、`PDO`、 `GD`、 `redis`、`mongo`、`swoole`、`Imagick` 等扩展

## 构建镜像

### 本地构建
```bash
docker build -t php-fpm:8.2 .
```

### 阿里云镜像（推荐）
```bash
# 8.2
docker pull registry.cn-hangzhou.aliyuncs.com/cqcqs/php-fpm:8.2

# 7.4
docker pull registry.cn-hangzhou.aliyuncs.com/cqcqs/php-fpm:7.4

# 7.4 历史版本，未安装Imagick扩展
docker pull registry.cn-hangzhou.aliyuncs.com/cqcqs/php74-fpm
```

## 使用

结合 `nginx` ，用 `docker-compose` 搭建一个 `php web` 项目

```yml
version: '1.0'
services:
  php8:
    image: registry.cn-hangzhou.aliyuncs.com/cqcqs/php-fpm:8.2
    container_name: php8
    restart: always
    ports:
      - 9000:9000
    volumes:
      - /data/www:/var/www/html
    networks:
      net:
        ipv4_address: 172.18.0.11

  nginx:
    image: nginx
    container_name: nginx
    restart: always
    ports:
      - 80:80
    volumes:
      - /data/www:/usr/share/nginx/html
      - /usr/local/nginx/conf.d:/etc/nginx/conf.d
    working_dir: /usr/share/nginx/html
    links:
      - php7
    networks:
      net:
        ipv4_address: 172.18.0.12

networks:
  net: 
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.18.0.0/24
```
