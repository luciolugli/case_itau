# Use a imagem base do Python
FROM python:3.8-slim

# Defina o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copie o conteúdo do diretório atual para o diretório de trabalho no contêiner
COPY . .

# Instale as dependências do Flask
RUN pip install --no-cache-dir -r requirements.txt

# Exponha a porta em que o aplicativo Flask está sendo executado
EXPOSE 8080

# Comando para executar o aplicativo Flask quando o contêiner for iniciado
CMD ["python", "app.py"]

