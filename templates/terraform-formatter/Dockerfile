# Terraform Formatter Container
# Used by Lefthook to format .tf files without local Terraform install

FROM hashicorp/terraform:1.14

WORKDIR /workspace

# Default command: format all Terraform files recursively
ENTRYPOINT ["terraform"]
CMD ["fmt", "-recursive", "-write=true"]
