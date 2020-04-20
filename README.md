# Deploy static website to EKS + ECS + S3

This examples does the following:

- Generates a webpage from an inlined string
- Pushes the result to S3
- Build a container Image and push it to AWS ECR
- Deploys the container to AWS Container Service ECS
- Deploys the container to AWS Kubernetes Service EKS

```sh
DOMAIN=my.domain
AWS_ACCESS_KEY=<my-access-key>
AWS_SECRET_KEY=<my-secret-key>
bl draft init app
bl push $DOMAIN --draft app
bl push $DOMAIN --draft app -k text input.awsAccessKey.value \"$(echo -n $AWS_ACCESS_KEY | base64)\"
bl push $DOMAIN --draft app -k text input.awsSecretKey.value \"$(echo -n $AWS_SECRET_KEY | base64)\"
bl draft apply app
```

At the end of the push, fetch the URLs:

```sh
bl get $DOMAIN output
```
