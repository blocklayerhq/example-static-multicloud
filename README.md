# Deploy static app to EKS + ECS

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
