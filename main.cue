package main

import (
    "b.l/bl"
    "stackbrew.io/file"
    "stackbrew.io/aws"
    "stackbrew.io/aws/s3"
    "stackbrew.io/aws/ecr"
)

input: {
    awsAccessKey: bl.Secret
    awsSecretKey: bl.Secret
}

config: {

    // Generate a new directory from the HTML code
    htmlSource: file.Create & {
        filename: "index.html"
        contents: """
            <html>
            <head><title>Hello World!</title></head>
            <body><h1>Yoo</h1></body>
            </html>
            """
    }

    // Build a new docker container from the html source above
    dockerImage: bl.Build & {
        context: htmlSource.result
        dockerfile: """
            FROM nginx
            COPY . /usr/share/nginx/html
            """
    }

    imageTarget: "125635003186.dkr.ecr.us-east-2.amazonaws.com/docs-demo:nginx-static"

    awsCreds: {
        accessKey: input.awsAccessKey
        secretKey: input.awsSecretKey
    }

    // Login to AWS ECR
    ecrCredentials: ecr.Credentials & {
        config: aws.Config & {
            region: "us-east-2"
            awsCreds
        }
        target: imageTarget
    }

    // Push the docker image to AWS ECR
    imagePush: bl.Push & {
        source:      dockerImage.image
        target:      imageTarget
        credentials: ecrCredentials.credentials
    }

    // Deploy the static index.html to S3
    deployS3: s3.Put & {
        config: aws.Config & {
            region: "us-west-2"
            awsCreds
        }
        source: htmlSource.result
        target: "s3://hello-s3.infralabs.io/"
    }

    // Deploy resulted image to ECS
    deployECS: SimpleAppECS & {
        infra: awsConfig: awsCreds
        app: {
            hostname: "hello-ecs.infralabs.io"
            containerImage: imagePush.ref
        }
    }

    // Deploy resulted image to Kubernetes EKS
    deployEKS: SimpleAppEKS & {
        infra: awsConfig: awsCreds
        app: {
            hostname: "hello-kube.infralabs.io"
            containerImage: imagePush.ref
        }
    }

}

output: {
    urlS3: "http://hello-s3.infralabs.io/"
    urlEKS: "https://\(config.deployEKS.app.hostname)/"
    urlECS: "https://\(config.deployECS.app.hostname)/"
    imageRef: config.imagePush.ref
}
