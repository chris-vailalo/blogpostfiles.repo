The following files are available:

- Dockerfile
- main.tf
- buildspec.yaml
- repository_file/main.tf

## Setup

1. Build the image using the Dockerfile by running this command in the directory with the Dockerfile:

```
docker build -t custom-pipeline-image .
```
2. Deploy the resources defined in the main.tf file
3. Push the image to the ECR repository. You can find instructions [here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)
4. Clone the CodeCommit repository
5. Add the main.tf file from the repository_file directory to the just cloned repository.
6. Commit and push the changes
7. Have the CodePipeline console present to see the pipeline in action

**NOTE** For the purpose of this demonstration, the IAM role for CodeBuild has the AdministratorAccess policy attached. In the real world it is best practice to use the principle of least privilege.