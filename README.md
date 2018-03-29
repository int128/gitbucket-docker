# GitBucket Docker image

Yet another GitBucket Docker image.

[GitBucket](https://github.com/gitbucket/gitbucket) is a Git platform powered by Scala with easy installation, high extensibility and GitHub API compatibility.


## Getting Started

```sh
docker run -p 8080:8080 -p 29418:29418 int128/gitbucket
```

You can save your GitBucket data to `./gitbucket` persistently as follows:

```sh
docker run -p 8080:8080 -p 29418:29418 -v ./gitbucket:/var/gitbucket int128/gitbucket
```

This image runs as `gitbucket` user (uid=1000, gid=1000), not `root` for security reason.

This image exposes the following ports:

- `8080` - Web service
- `29418` - SSH access to git repository


## Kubernetes

Consider the followings:

- Create a persistent volume claim and mount to `/var/gitbucket`.
- Set readiness probe and liveness probe with access to `pod:8080/signin`. It always return 200.


## Configuration

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


## Contributions

This is an open source software licensed under Apache License 2.0.
Feel free to open issues and pull requests.
