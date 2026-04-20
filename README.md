```markdown
<h1 align="center">
  📚 Portal do Colportor
</h1>

<p align="center">
  <i>Sistema web completo para gestão, engajamento e acompanhamento de colportores.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Riverpod-141114?style=for-the-badge&logo=dart&logoColor=white" alt="Riverpod" />
</p>

<br>

> 🌐 **Ambiente de Testes (Live Demo):** > Acesse o sistema em produção: **[https://colportor-portal.firebaseapp.com/](https://colportor-portal.firebaseapp.com/)**

---

## 📖 Sobre o Projeto

O **Portal do Colportor** é uma aplicação Flutter Web projetada para conectar administradores e colportores (estudantes e efetivos). O sistema foca em segurança, gestão em tempo real e motivação diária, fornecendo um painel interativo com estatísticas, rankings e recursos operacionais.

## ✨ Principais Funcionalidades

* **🔐 Autenticação Segura & RBAC:** Login integrado ao Firebase Auth com controle de acesso baseado em funções (Administradores vs. Colportores).
* **✉️ Recuperação de Senha Nativa:** Interceptação de `Action URLs` do Firebase (sem hashtag `#`) para redefinição de senha com interface 100% personalizada e dentro do app.
* **🔑 Sistema de Convites:** Tela oculta de painel Admin para geração de códigos de acesso únicos e dinâmicos armazenados no Firestore.
* **🔄 Sincronização em Tempo Real:** Uso de Streams (via Riverpod) para refletir instantaneamente na UI qualquer alteração de dados do perfil do usuário.
* **📸 Gestão de Perfil via ImgBB:** Upload de fotos de perfil otimizado utilizando a API do ImgBB, poupando custos de storage e entregando alta performance.
* **📖 Dashboard Motivacional Dinâmico:** Consumo assíncrono da *A Bíblia Digital API* para exibir um versículo (NVI) novo a cada acesso, com *fallback* offline garantido.

---

## 🛠️ Arquitetura e Tecnologias

O projeto adota uma arquitetura em camadas visando escalabilidade e manutenção clara:

* **Framework:** [Flutter](https://flutter.dev/) (Web)
* **Gerência de Estado:** [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
* **Backend as a Service:** [Firebase](https://firebase.google.com/) (Auth, Cloud Firestore, Hosting)
* **Roteamento:** `url_strategy` (Path URLs limpas)
* **Integrações Externas:** * API ImgBB (Armazenamento de Imagens)
  * A Bíblia Digital API (Versículos Dinâmicos)

### 📂 Estrutura de Pastas

```text
lib/
 ├── application/         # Lógica de Negócio e Gerenciamento de Estado (Providers)
 │    ├── auth/           # Controladores de Autenticação e Perfil
 │    └── providers/      # Providers externos (ex: API de Versículos)
 ├── infrastructure/      # Integrações de dados e serviços
 │    └── repositories/   # Comunicação com Firebase e APIs HTTP
 ├── presentation/        # Camada de Interface do Usuário (UI)
 │    ├── pages/          # Telas principais (Home, Login, Admin, Settings)
 │    └── widgets/        # Componentes reutilizáveis
 └── main.dart            # Ponto de entrada, Configurações de Rota e Firebase
```

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão mais recente recomendada)
* Conta configurada no Firebase
* Firebase CLI instalado (`npm install -g firebase-tools`)

### Instalação

1. **Clone o repositório:**
   ```bash
   git clone [https://github.com/seu-usuario/colportor-portal.git](https://github.com/seu-usuario/colportor-portal.git)
   ```

2. **Baixe as dependências:**
   ```bash
   cd colportor-portal
   flutter pub get
   ```

3. **Inicie o servidor de desenvolvimento:**
   ```bash
   flutter run -d chrome
   ```

### 📦 Fazendo o Deploy (Firebase Hosting)

Para compilar e enviar atualizações para a web:

```bash
# 1. Compile a versão otimizada para Web
flutter build web

# 2. Envie para o Firebase (certifique-se que o firebase.json aponta para "build/web")
firebase deploy --only hosting
```

---

## 👨‍💻 Autor

Desenvolvido com dedicação por **[Seu Nome/Robério Almeida]** *Desenvolvedor de Software & Entusiasta em Tecnologias Web/Mobile.*
```

**Dica de ouro para o GitHub:** Se você for subir esse projeto para o seu portfólio no GitHub, recomendo tirar 2 ou 3 "prints" (screenshots) da tela de Login, da Home e do Menu Lateral aberto e adicioná-los logo abaixo da seção "Sobre o Projeto". Isso faz toda a diferença para recrutadores!
