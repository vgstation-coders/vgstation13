# Brazuca Station 
[![forinfinityandbyond](https://user-images.githubusercontent.com/5211576/29499758-4efff304-85e6-11e7-8267-62919c3688a9.gif)](https://www.reddit.com/r/SS13/comments/5oplxp/what_is_the_main_problem_with_byond_as_an_engine/dclbu1a) [![aqui tem tretas internas](http://svgur.com/i/_js.svg)](https://www.forthebadge.com) [![pelos melhores](https://svgur.com/i/_ij.svg)](https://www.forthebadge.com) [![huehueheurbrbrb](http://svgur.com/i/_kN.svg)](https://www.forthebadge.com) 

[Website](http://ss13.moe) - [Code](https://github.com/vgstation-coders/vgstation13)
---
### ADQUIRINDO O CODIGO
A maneira mais simples, porém menos útil de obter o código é usar a função .zip do Github. Você pode clicar aqui para obter o código mais recente e estável como um arquivo .zip e, em seguida, descompactá-lo onde desejar. Alternativamente, um método muito mais útil é usar um cliente git, o processo de obtenção e uso de um é descrito abaixo (para obter mais informações, nossos programadores no IRC podem explicar como usar um).

### Git client
A maneira mais complicada, mas infinitamente mais útil, é usar um cliente 'git'.

Recomendamos e apoiamos nossos usuários no uso do cliente SmartGit, disponível em smartgit. Após a instalação, crie uma nova pasta de arquivos onde deseja hospedar o código, clique com o botão direito nessa pasta e clique em "Abrir no Smartgit".

Quando isso abrir, clique em repositório no canto superior esquerdo e escolha 'clonar'. Você pode usar o link para o repositório principal https://github.com/vgstation-coders/vgstation13.git ou, para clonar seu próprio fork, o formato é https://github.com/USERNAME/REPONAME.git, basta copiar a URL do seu fork e adicionar .git.

#### Atualizando o Código
Após clonar, certifique-se de ter um remoto para o repositório principal e seu próprio repositório forkado, criando um remoto usando os links acima. Ao clicar com o botão direito em seu remoto para este repositório, você pode 'puxar' a versão mais recente do código do repositório principal.

Você pode então criar novos ramos de código diretamente a partir do nosso ramo Bleeding-Edge em seu computador.

Aviso: Se você verificar ramos diferentes ou atualizar o código enquanto o Dream Maker estiver aberto, isso pode causar problemas quando alguém adicionar/remover arquivos ou quando um dos arquivos alterados estiver atualmente aberto.

#### Branches
Lembre-se de que temos vários ramos para diversos fins.

* *master* - Código "estável" mas antigo, era usado no servidor principal até percebermos que gostamos de viver perigosamente 😎.
* *Bleeding-Edge* - O código mais recente, este código é executado no servidor principal. Por favor, faça qualquer desenvolvimento neste ramo!

### INSTALAÇÃO
A instalação pela primeira vez deve ser bastante direta. Primeiro, você precisará ter o BYOND instalado. Você pode obtê-lo aqui.

Este é um lançamento apenas de código-fonte, então o próximo passo é compilar os arquivos do servidor. Abra vgstation13.dme dando um duplo clique nele, abra o menu Compilar e clique em compilar. Isso levará um tempo, e se tudo for feito corretamente, você receberá uma mensagem como esta:

salvando vgstation13.dmb (modo DEBUG)

vgstation13.dmb - 0 erros, 0 avisos

Se você vir erros ou avisos, algo deu errado - possivelmente um download corrompido ou a extração dos arquivos de forma incorreta, ou um problema de código no repositório principal. Pergunte no IRC.

Para usar as preferências do SQLite, renomeie players2_empty.sqlite para players2.sqlite

Em seguida, copie tudo de config-example/ para config/ para ter alguma configuração padrão.

Depois de feito isso, abra a pasta config. Você vai querer editar o arquivo config.txt para definir as probabilidades de diferentes modos de jogo em Secret e para definir a localização do seu servidor para que todos os seus jogadores não sejam desconectados no final de cada rodada. É recomendável não ligar os modos de jogo com probabilidade 0, pois eles têm vários problemas e não estão atualmente sendo testados, então podem ter bugs desconhecidos e bizarros.

Você também vai querer editar o arquivo admins.txt para remover os administradores padrão e adicionar os seus próprios. "Host" é o nível mais alto de acesso, e os outros níveis de administração recomendados por enquanto são "Mestre de Jogo", "Administrador de Jogo" e "Moderador". O formato é:

byondkey - Cargo

onde a chave BYOND deve estar em minúsculas e o cargo de administração deve estar capitalizado corretamente. Existem muitos outros cargos de administração, mas esses dois devem ser suficientes para a maioria dos servidores, desde que você tenha administradores de confiança.

Finalmente, para iniciar o servidor, execute o Dream Daemon e insira o caminho para o seu arquivo compilado vgstation13.dmb. Certifique-se de definir a porta como a especificada no config.txt e defina a caixa de segurança como 'Confiável'. Em seguida, clique em INICIAR e o servidor deve iniciar e estar pronto para se juntar.

---

### Configuração
Para uma configuração básica, simplesmente copie todos os arquivos de config-example/ para config/ e depois adicione-se como administrador via admins.txt.

---

### Configuração SQL
O backend SQL para a biblioteca e rastreamento de estatísticas requer um servidor MySQL. (Servidores Linux precisarão colocar libmysql.so no mesmo diretório que vgstation13.dme.) Seus detalhes de servidor vão em /config/dbconfig.txt.

O banco de dados é instalado automaticamente durante a inicialização do servidor, mas você precisa garantir que o banco de dados e o usuário estejam presentes e tenham as permissões necessárias.

---

### Configuração do Bot IRC
Incluído no repositório está um bot IRC capaz de relatar pedidos de ajuda de administradores para um canal/servidor IRC especificado (substitui o antigo de Skibiliano). As instruções para configurar o bot estão incluídas na pasta /bot/ juntamente com o próprio script do bot/retransmissão.

