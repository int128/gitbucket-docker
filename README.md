# GitBucket Docker Image [![CircleCI](https://circleci.com/gh/int128/gitbucket-docker.svg?style=shield)](https://circleci.com/gh/int128/gitbucket-docker)

Yet another [GitBucket](https://github.com/gitbucket/gitbucket) Docker image and Kubernetes Helm chart, continuously updated and tested by [CircleCI](https://circleci.com/gh/int128/gitbucket-docker).


## Docker

```sh
docker run -p 8080:8080 -p 29418:29418 int128/gitbucket
```

You can save your GitBucket data to `./gitbucket` persistently as follows:

```sh
mkdir -p /data/gitbucket
chown -R 1000:1000 /data/gitbucket
docker run -p 8080:8080 -p 29418:29418 -v /data/gitbucket:/var/gitbucket int128/gitbucket
```

This image runs as `gitbucket` user (uid=1000, gid=1000), not `root` for security reason.

This image exposes the following ports:

- `8080` - Web service
- `29418` - SSH access to git repository

### Configuration

You can set the following environment variables:

| Name | Value
|------|------
| `GITBUCKET_HOME`      | Directory to store data. Defaults to `/var/gitbucket`.
| `GITBUCKET_BASE_URL`  | Base URL. This may be required if container is behind a reverse proxy.
| `GITBUCKET_DB_URL`    | [External database](https://github.com/gitbucket/gitbucket/wiki/External-database-configuration) URL. Defaults to H2.
| `GITBUCKET_DB_USER`   | External database user.
| `GITBUCKET_DB_USER`   | External database password.
| `GITBUCKET_OPTS`      | GitBucket command line options.
| `JAVA_OPTS`           | JVM options. Defaults to options setting JVM heap by container memory limit. See [`Dockerfile`](Dockerfile) for more.


## Kubernetes Helm

```sh
helm repo add int128.github.io https://int128.github.io/helm-charts
helm repo update
helm install int128.github.io/gitbucket
```

The Helm chart considers the followings:

- Mount the persistent volume to `/var/gitbucket`.
- Fix owner of `/var/gitbucket` by the init container.
- Set readiness probe and liveness probe with access to `:8080/signin`. It should return 200.

### Configuration

You can set the following values:

| Name | Value
|------|------
| `gitbucket.options`           | GitBucket command line options.
| `javavm.options`              | JVM options. Defaults to setting JVM heap by the memory limit. See [`Dockerfile`](Dockerfile) for more.
| `externalDatabase.url`        | The [external database](https://github.com/gitbucket/gitbucket/wiki/External-database-configuration) URL. Defaults to H2.
| `externalDatabase.user`       | The external database user.
| `externalDatabase.password`   | The external database password.
| `externalDatabase.existingSecret`     | Name of an existing secret to be used for the database password.
| `externalDatabase.existingSecretKey`  | The key for the database password in the existing secret.
| `persistentVolume.existingClaim`  | Name of an existing Persistent Volume Claim.
| `persistentVolume.size`           | Size of a Persistent Volume Claim for dynamic provisioning. Defaults to `10Gi`.
| `resources.limits.memory`         | Memory limit. Defaults to `1Gi`.
| `resources.requests.memory`       | Memory request. Defaults to `1Gi`.
| `ingress.enabled`                 | If true, an ingress is be created.
| `ingress.hosts`                   | A list of hosts for the ingress.


## Contributions

This is an open source software licensed under Apache License 2.0.
Feel free to open issues and pull requests.
