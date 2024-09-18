# aws-ecr-http-proxy

A very simple nginx push/pull proxy that forwards requests to AWS ECR and caches the responses locally.

### Differences Between Fork and Upstream Repository

- Added support for AWS WebIdentity Token
- Added support for AWS EC2 metadata
- Added log of the AWS identity used
- Added support to set custom renewal interval
- Fallback to AWS_REGION, AWS_DEFAULT_REGION and region in ECR URL
- Upgraded to OpenResty 1.21.4.1
- Upgraded AWS CLI to 1.34.21
- Environment variables names simplified
- Cleaned up the repository structure

### Configuration:
The proxy is packaged in a docker container and can be configured with following environment variables:

| Environment Variable                | Description                                    | Status                            | Default    |
| :---------------------------------: | :--------------------------------------------: | :-------------------------------: | :--------: |
| `ECR`                               | URL for AWS ECR                                | Required                          |            |
| `RESOLVER`                          | DNS server to be used by proxy                 | Required                          |            |
| `PORT`                              | Port on which proxy listens                    | Required                          |            |
| `CACHE_MAX_SIZE`                    | Maximum size for cache volume                  | Optional                          |    `75g`   |
| `CACHE_KEY`                         | Cache key used for the content by nginx        | Optional                          |   `$uri`   |
| `RENEW_INTERVAL_HOURS`              | Interval for renewing the AWS credentials      | Optional                          |     `6`    |
| `ENABLE_SSL`                        | Used to enable SSL/TLS for proxy               | Optional                          |  `false`   |
| `SSL_KEY`                           | Path to TLS key in the container               | Required with SSL                 |            |
| `SSL_CERTIFICATE`                   | Path to TLS cert in the container              | Required with SSL                 |            |


AWS identity can be passed:
- using environment variables
- using AWS credentials file (mounted in the container)
- using WebIdentity Token (mounted in the container)
- on AWS EC2 via metadata

If `AWS_REGION` is not set, it will be deduced from ECR URL.

| Environment Variable                | Description                                    | Status                            | Default    |
| :---------------------------------: | :--------------------------------------------: | :-------------------------------: | :--------: |
| `AWS_REGION`                        | Region                                         | Optional                          |            |
| `AWS_ACCESS_KEY_ID`                 | Access key                                     | Optional                          |            |
| `AWS_SECRET_ACCESS_KEY`             | Secret key                                     | Optional                          |            |


### Example:

```sh
docker run -d --name docker-registry-proxy --net=host \
  -v /registry/local-storage/cache:/cache \
  -v /registry/certificate.pem:/opt/ssl/certificate.pem \
  -v /registry/key.pem:/opt/ssl/key.pem \
  -e PORT=5000 \
  -e RESOLVER=8.8.8.8 \
  -e ECR=https://XXXXXXXXXX.dkr.ecr.eu-central-1.amazonaws.com \
  -e CACHE_MAX_SIZE=100g \
  -e ENABLE_SSL=true \
  -e SSL_KEY=/opt/ssl/key.pem \
  -e SSL_CERTIFICATE=/opt/ssl/certificate.pem \
 ghcr.io/dreamlab/aws-ecr-http-proxy:master
```

If you ran this command on "registry-proxy.example.com" you can now get your images using `docker pull registry-proxy.example.com:5000/repo/image`.

### Note on SSL/TLS
The proxy is using `HTTP` (plain text) as default protocol for now. So in order to avoid docker client complaining either:
 - (**Recommended**) Enable SSL/TLS using `ENABLE_SSL` configuration. For that you will have to mount your **valid** certificate/key in the container and pass the paths using  `SSL_*` variables.
 - Mark the registry host as insecure in your client [deamon config](https://docs.docker.com/registry/insecure/).
