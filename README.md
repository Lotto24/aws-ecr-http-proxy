aws-ecr-http-proxy
===========

A very simple nginx proxy that forwards requests to AWS ECR and caches the responses locally.

Run it like this, replace UPSTREAM with your target address with following required params:
- `AWS_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

For example:

```sh
docker run --rm --name docker-registry-proxy --net=host \
  -v /local-storage/cache:/cache \
  -e PORT=5000 \
  -e RESOLVER=8.8.8.8 \
  -e UPSTREAM=https://XXXXXXXXXX.dkr.ecr.eu-central-1.amazonaws.com \
  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  -e AWS_REGION=${AWS_DEFAULT_REGION} \
  esailors/aws-ecr-http-proxy:latest
```

If you ran this command on "registry-proxy.example.com" you can now get your images using `docker pull registry-proxy.example.com:5000/repo/image`.

### Deploying the proxy
Modify the ansible role variables according to your need and run the playbook as follow:
```sh
ansible-playbook -i hosts playbook-docker-registry-proxy.yaml
```
The docker registry for project is available [here](https://hub.docker.com/r/esailors/aws-ecr-http-proxy)

### Note
The proxy has `HTTP` endpoint so in order to avoid docker client complaining about it either mark the registry host as insecure in your [deamon config](https://docs.docker.com/registry/insecure/) or add [SSL/TLS termination](https://docs.docker.com/registry/recipes/nginx)
