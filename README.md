Instalação e Execução
Para executar o projeto localmente, siga estas etapas:

1 - Clone o repositório:

git clone https://github.com/luciolugli/case_itau.git

2 - Navegue até o diretório do projeto:
cd case_itau

3 - Instale as dependências do projeto:
pip install -r requirements.txt

4 - Execute o aplicativo:
python app.py

🏢 Estrutura do Projeto

![image](https://github.com/luciolugli/case_itau/assets/170758476/deaec927-9b9d-45fc-aeb4-d8c0ff34fe8f)

Documentação da API: http://127.0.0.1:5000/.

Caso 1

![image](https://github.com/luciolugli/case_itau/assets/170758476/4faac685-68d1-4d75-b3d5-fe5212e9cad7)

Caso 2
![image](https://github.com/luciolugli/case_itau/assets/170758476/8610a4db-1a82-451f-93f2-e7f7c2e1e118)

Caso 3
![image](https://github.com/luciolugli/case_itau/assets/170758476/44655f9d-840b-4b0a-a251-50c051d1fd2a)

Caso 4
![image](https://github.com/luciolugli/case_itau/assets/170758476/794d80ce-e7b1-47ce-8242-16845a1d4496)



Descrição dos Métodos da API
Método POST /verify
Este endpoint verifica a validade de um token JWT.

Parâmetros da Solicitação:
token: (string) O token JWT a ser verificado.
Respostas:
200 OK:
Corpo: Retorna um JSON com a validade do token e informações adicionais, se aplicável.

400 Bad Request:
Corpo: Retorna um JSON com uma mensagem de erro caso o token seja inválido ou esteja ausente na solicitação.


- Testes
Para executar os testes de unidade e integração do projeto, você pode usar o seguinte comando:

python -m unittest discover tests
Isso executará todos os testes encontrados na pasta tests e suas subpastas.
