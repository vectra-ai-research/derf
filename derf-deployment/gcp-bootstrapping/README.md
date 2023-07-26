# DeRF Deployment

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.13.0 |



## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_derf_execution_users"></a> [aws\_derf\_execution\_users](#module\_aws\_derf\_execution\_users) | ../aws-derf-execution-users | n/a |
| <a name="module_aws_perpetual_range"></a> [aws\_derf\_perpetual\_range](#module\_aws\_derf\_execution\_users) | ../aws-perpetual-range | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |

## Resources

| Name | Type |
|------|------|


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [account\_id](#input\_account\_id) | Account ID of primary AWS Account targeted  | `string` | n/a | yes |
| <a name="input_aws_profile"></a> [profile\_name](#input\_profile\_name | The AWS Profile used to deploy the perpetual range in the Primary Account  | `string` | n/a | yes |
| <a name="input_aws_region"></a> [region\_name](#input\_region\_name | The region to deploy the AWS perpetual range  | `string` | n/a | yes |
| <a name="input_pathToAWSConfig"></a> [file\_path_](#input\_file\_path | Full local path to AWS .config file allowing terraform to file your profile configurations  | `string` | n/a | yes |

## Outputs

No outputs.