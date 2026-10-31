# FinPay Frontend GitOps

Este repositório contém apenas o estado desejado do frontend FinPay. A imagem Angular + Nginx é produzida no repositório `finpay-frontweb`; este repositório não compila código nem aplica recursos diretamente no cluster. Depois que um Pull Request é aprovado e incorporado em `main`, o Argo CD pode observar essa revisão e reconciliá-la.

## Estrutura

```text
charts/finpay-frontweb/                 Helm Chart reutilizável
environments/development/values.yaml   Estado desejado de development
environments/production/values.yaml    Estado desejado de production
.github/workflows/deploy.yml           CD manual que propõe um Pull Request
```

O Chart cria um Deployment com uma réplica e um Service `ClusterIP` chamado exatamente `finpay-frontweb`, na porta 80. As probes de readiness e liveness consultam `/` na porta 80.

A imagem original usa `nginx-unprivileged` na porta 8080. Para atender ao contrato Kubernetes de container port 80 sem alterar o projeto de código, o Chart monta um `default.conf` e adiciona somente a capability `NET_BIND_SERVICE` ao processo não-root. A configuração faz `proxy_pass http://finpay-backend:3000` no bloco `location /api/`; como não há barra final no `proxy_pass`, o URI original, inclusive o prefixo `/api`, é preservado.

## Versões e imagem imutável

- `Chart.yaml: version` versiona a estrutura e os templates do Chart, independentemente da aplicação.
- `Chart.yaml: appVersion` é apenas a versão padrão/documental da aplicação.
- `appVersion` nos values do ambiente registra a release promovida.
- `image.digest` fixa exatamente o artefato executado. Se preenchido, a imagem renderizada é `repository@sha256:digest`; a tag nunca é combinada com o digest.
- `image.tag` é um fallback útil para desenvolvimento do Chart. O estado promovido deve usar digest.

Os digests vazios nos values iniciais são placeholders explícitos. Eles não representam um digest inventado e serão preenchidos pelo workflow após consulta ao GHCR público.

## CD manual

Em **Actions > Propose deployment > Run workflow**, informe:

- `environment`: `development` ou `production`;
- `release`: uma tag existente em `ghcr.io/vitorbalconi/finpay-frontweb`, como `v1.0.0`.

O workflow valida os inputs, resolve o digest imutável no GHCR, altera somente `environments/<environment>/values.yaml`, executa `helm lint` e `helm template` e abre um PR contra a `main` protegida. Se versão e digest já forem os desejados, ele valida o Chart, mas não cria commit nem PR. Não há acesso a Kubernetes ou Argo CD.

O pacote GHCR é público, portanto nenhuma credencial de leitura é necessária. No repositório OPS, habilite **Settings > Actions > General > Workflow permissions > Allow GitHub Actions to create and approve pull requests**. O workflow concede ao `GITHUB_TOKEN` apenas `contents: write` e `pull-requests: write`; as regras de proteção e aprovação da `main` continuam valendo.

## Validação local

Com Helm 3 instalado:

```bash
helm lint charts/finpay-frontweb -f environments/production/values.yaml
helm template finpay-frontweb charts/finpay-frontweb -f environments/production/values.yaml
```
