<h1 align="center">
  📚 Portal do Colportor
</h1>

<p align="center">
  <i>Sistema web completo para gestão, engajamento e acompanhamento de colportores.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Riverpod-141114?style=for-the-badge&logo=dart&logoColor=white" />
</p>

---

## 🌐 Demo Online

🚀 Acesse o sistema em produção:  
👉 https://colportor-portal.firebaseapp.com/



## 📸 Preview do Sistema

<p align="center">
  <img src="https://i.ibb.co/23CfzBsf/1.png" width="45%" />
  <img src="https://i.ibb.co/dsWQYNRw/2.png" width="45%" />
</p>

<p align="center">
  <img src="https://i.ibb.co/vCyNXYMY/3.png" width="45%" />
  <img src="https://i.ibb.co/fdHRmk2n/4.png" width="45%" />
</p>

<p align="center">
  <img src="https://i.ibb.co/Zpn9dhvY/5.png" width="45%" />
  <img src="https://i.ibb.co/KxN3NWdr/6.png" width="45%" />
</p>

<p align="center">
  <img src="https://i.ibb.co/7t5phj7h/7.png" width="45%" />
  <img src="https://i.ibb.co/hRBmmy55/8.png" width="45%" />
</p>

<p align="center">
  <img src="https://i.ibb.co/3m9fd03p/9.png" width="45%" />
  <img src="https://i.ibb.co/CKN5VRvk/10.png" width="45%" />
</p>

<p align="center">
  <i>Algumas telas do sistema em funcionamento (Dashboard, autenticação, perfil e gestão).</i>
</p>

---

## 📖 Sobre o Projeto

O **Portal do Colportor** é uma aplicação **Flutter Web** desenvolvida para facilitar a gestão e o acompanhamento de colportores (estudantes e efetivos).

O sistema conecta administradores e usuários em um ambiente seguro e dinâmico, com foco em:

- 📊 Monitoramento em tempo real  
- 🧑‍💼 Gestão de usuários  
- 🔥 Engajamento diário  
- 📈 Performance e rankings  

---

## ✨ Funcionalidades

### 🔐 Autenticação & Segurança
- Login com Firebase Authentication  
- Controle de acesso por função (**RBAC**)  
- Sessão persistente  

### 🔑 Sistema de Convites
- Geração de códigos únicos pelo admin  
- Controle de novos acessos ao sistema  

### 🔄 Tempo Real
- Atualizações instantâneas com **Streams + Riverpod**  
- UI sempre sincronizada com o banco  

### 📸 Perfil do Usuário
- Upload de imagem via **ImgBB API**  
- Otimização de custos (sem Firebase Storage)  

### ✉️ Recuperação de Senha Customizada
- Interceptação de links do Firebase  
- Tela interna personalizada (sem sair do app)  

### 📖 Dashboard Motivacional
- Versículos dinâmicos via API  
- Sistema de fallback offline  

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Função |
|----------|--------|
| Flutter Web | Frontend |
| Riverpod | Gerência de estado |
| Firebase Auth | Autenticação |
| Cloud Firestore | Banco de dados |
| Firebase Hosting | Deploy |
| ImgBB API | Upload de imagens |
| Bíblia Digital API | Conteúdo dinâmico |

---

## 🧱 Arquitetura do Projeto

O projeto segue uma arquitetura organizada em camadas:
