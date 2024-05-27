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

O aplicativo estará em execução em http://127.0.0.1:5000/.

🏢 Estrutura do Projeto

/projeto validador jwt
├── app.py
├── static
│   └── swagger.yaml
├── tests
│   └── test_app.py
├── requirements.txt
├── .gitignore
└── README.md
![image](https://github.com/luciolugli/case_itau/assets/170758476/deaec927-9b9d-45fc-aeb4-d8c0ff34fe8f)


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
Testes
Para executar os testes de unidade e integração do projeto, você pode usar o seguinte comando:

bash
Copiar código
python -m unittest discover tests
Isso executará todos os testes encontrados na pasta tests e suas subpastas.
