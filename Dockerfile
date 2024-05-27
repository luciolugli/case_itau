# Use uma imagem base oficial do Python
FROM python:3.9-slim

# Define o diretório de trabalho
WORKDIR /app

# Copie o arquivo de requisitos
COPY requirements.txt .

# Instale as dependências
RUN pip install --no-cache-dir -r requirements.txt

# Copie o restante da aplicação
COPY . .

# Defina a variável de ambiente para garantir que o stdout e stderr do Python não sejam bufferizados
ENV PYTHONUNBUFFERED=1

# Exponha a porta em que a aplicação vai rodar
EXPOSE 8080

# Comando para rodar a aplicação
CMD ["python", "app.py"]

