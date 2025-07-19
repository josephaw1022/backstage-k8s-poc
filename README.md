# Backstage Kubernetes PoC

This is a proof-of-concept setup demonstrating Backstage’s Kubernetes plugin integration using a local [Kind](https://kind.sigs.k8s.io/) cluster.

---

## Preconfigured Setup

The following configuration steps were already completed in this repo:

### Kubernetes Frontend Plugin

The Kubernetes frontend plugin is installed and wired into the entity pages.

- `@backstage/plugin-kubernetes` was added to the app.
- The `<EntityKubernetesContent />` tab was added to the catalog entity pages in `packages/app/src/components/catalog/EntityPage.tsx`:

```tsx
import { EntityKubernetesContent } from '@backstage/plugin-kubernetes';

<EntityLayout.Route path="/kubernetes" title="Kubernetes">
  <EntityKubernetesContent refreshIntervalMs={30000} />
</EntityLayout.Route>
````

### Kubernetes Backend Plugin

The backend plugin was also installed and initialized:

* `@backstage/plugin-kubernetes-backend` was added to the backend.
* Registered in `packages/backend/src/index.ts`:

```ts
backend.add(import('@backstage/plugin-kubernetes-backend'));
```

You don't need to repeat these steps — they’re already in place.

---

## Prerequisites

* [Node.js](https://nodejs.org/) (16+)
* [Yarn](https://classic.yarnpkg.com/en/docs/install/)
* [Docker](https://www.docker.com/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)

---

## Getting Started

### 1. Install dependencies

```bash
yarn
```

### 2. Set up the Kubernetes cluster and demo resources

```bash
bash ./quick-start-k8s.sh
```

This script will:

* Create a local Kind cluster
* Create 4 namespaces
* Deploy `nginx` in each namespace (5 replicas)
* Set up a `cluster-admin` ServiceAccount for Backstage access

### 3. Configure local Backstage to access the cluster

```bash
bash ./quick-start-local-app-config.sh
```

This script will:

* Locate the service account token
* Write `app-config.local.yaml` pointing Backstage to your Kind cluster

### 4. Start Backstage

```bash
yarn start
```

---

## Usage

1. Open Backstage at [http://localhost:3000](http://localhost:3000)
2. Navigate to the **example-website** entity
3. Click the **Kubernetes** tab to view live cluster info

---

## Cleanup

```bash
kind delete cluster --name backstage-demo
```

---

## Files of Interest

* `quick-start-k8s.sh` — creates Kind cluster and resources
* `quick-start-local-app-config.sh` — writes `app-config.local.yaml` with service account token
* `app-config.local.yaml` — Backstage config that connects to the Kind cluster