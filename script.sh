#!/bin/bash

# Autor
echo "Script para criação de container"
echo "Autor: JULIO CESAR AGRIPINO"
echo "================================="
echo "Sistemas Operacionais - Prof. Jadilson Paiva"
echo "================================="

# Nome do container
container_name="meu-container-jadilson-novo"

# Nome da nova imagem
new_image_name="jc-imagem"

# Nome do arquivo customizado
custom_file_name="index.html"

# Nome dos integrantes do grupo
integrantes=("JULIO CESAR AGRIPINO" "THALYS HENRIQUE" "LEVI VIEIRA" "VINICIUS AUGUSTO")

# Remover o container existente, se necessário.
if [ "$(docker ps -aq -f name=$container_name)" ]; then
    echo "Removendo o container existente..."
    docker stop $container_name > /dev/null
    docker rm $container_name > /dev/null
fi

# Levantar um container a partir da imagem
echo "Iniciando o container $container_name..."
docker run -d -p 80:80 --name $container_name nginx

# Aguardar alguns segundos para o servidor Nginx iniciar
echo "Aguardando o servidor Nginx iniciar..."
sleep 5

# Remover o arquivo index.html existente no container
echo "Removendo o arquivo index.html existente..."
docker exec $container_name rm /usr/share/nginx/html/index.html > /dev/null

# Criar arquivo index.html customizado
echo "Gerando arquivo $custom_file_name..."
echo "<h1>Integrantes do Grupo:</h1>" > $custom_file_name
for integrante in "${integrantes[@]}"; do
    echo "<p>$integrante</p>" >> $custom_file_name
done

# Copiar o arquivo customizado para o container
echo "Copiando o arquivo customizado para o container..."
docker cp $custom_file_name $container_name:/usr/share/nginx/html/index.html > /dev/null

# Alterar as configurações do Nginx
echo "Alterando as configurações do Nginx..."
docker exec $container_name bash -c 'cat > /etc/nginx/nginx.conf <<EOF
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\''$remote_addr - $remote_user [$time_local] "$request" '\''$status $body_bytes_sent "$http_referer" '\''"$http_user_agent" "$http_x_forwarded_for"'\'';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
EOF' > /dev/null

# Criar uma nova imagem atualizada a partir do container
echo "Criando uma nova imagem atualizada..."
docker commit $container_name $new_image_name > /dev/null

# Excluir o container antigo
echo "Excluindo o container antigo..."
docker stop $container_name > /dev/null
docker rm $container_name > /dev/null

# Excluir a imagem antiga
echo "Excluindo a imagem antiga..."
docker rmi --force jadilsonpaiva/provaso1 > /dev/null

# Iniciar um novo container a partir da nova imagem
echo "Iniciando um novo container a partir da nova imagem..."
docker run -d -p 80:80 --name $container_name $new_image_name

echo "O novo servidor WEB está em execução com a página padrão modificada."
