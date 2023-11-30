FROM --platform=linux/amd64 public.ecr.aws/ubuntu/ubuntu:22.04

USER root

# Update and install necessary packages
RUN apt-get update -y && \
    apt-get install -y \
    unzip wget vim git curl jq python3 python3-pip

# Update Python3
RUN python3 -m pip install --upgrade pip

# Install Terraform 1.6.4
RUN wget https://releases.hashicorp.com/terraform/1.6.4/terraform_1.6.4_linux_amd64.zip && \
    unzip terraform_1.6.4_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_1.6.4_linux_amd64.zip

# Install TFLINT
RUN curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && \
    unzip tflint.zip && \
    rm tflint.zip && \
    mv tflint /usr/bin/

# Install Checkov
RUN pip3 install --no-cache-dir checkov

# Install TFSEC
RUN curl -L "$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep -o -E -m 1 "https://.+?tfsec-linux-amd64")" > tfsec && \
    chmod +x tfsec && \
    mv tfsec /usr/bin/
