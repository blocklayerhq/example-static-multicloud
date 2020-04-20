package main

import (
    "b.l/bl"
    "stackbrew.io/file"
    "stackbrew.io/aws"
    "stackbrew.io/aws/ecr"
)

input: {
    awsAccessKey: bl.Secret
    awsSecretKey: bl.Secret
}

config: {

    htmlSource: file.Create & {
        filename: "index.html"
        contents: """
            <html>
            <head><title>Hello World!</title></head>
            <body><h1>Yoo</h1></body>
            </html>
            """
    }

    dockerImage: bl.Build & {
        context: htmlSource.result
        dockerfile: """
            FROM nginx
            COPY . /usr/share/nginx/html
            """
    }

    imageTarget: "125635003186.dkr.ecr.us-east-2.amazonaws.com/docs-demo:nginx-static"

    ecrCredentials: ecr.Credentials & {
        config: aws.Config & {
            region:    "us-east-2"
            accessKey: input.awsAccessKey
            secretKey: input.awsSecretKey
        }
        target: imageTarget
    }

    imagePush: bl.Push & {
        source:      dockerImage.image
        target:      imageTarget
        credentials: ecrCredentials.credentials
    }

    // Deploy resulted image to ECS
    deployECS: SimpleAppECS & {
        infra: awsConfig: {
            accessKey: input.awsAccessKey
            secretKey: input.awsSecretKey
        }
        app: {
            hostname: "hello-ecs.infralabs.io"
            containerImage: imagePush.ref
        }
    }

    // Deploy resulted image to Kubernetes EKS
    deployEKS: SimpleAppEKS & {
        infra: awsConfig: {
            accessKey: input.awsAccessKey
            secretKey: input.awsSecretKey
        }
        app: {
            hostname: "hello-kube.infralabs.io"
            containerImage: imagePush.ref
        }
    }

}

output: {
    urlEKS: "https://\(config.deployEKS.app.hostname)/"
    urlECS: "https://\(config.deployECS.app.hostname)/"
    imageRef: config.imagePush.ref
}
