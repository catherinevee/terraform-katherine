package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../eu-west-2/network/vpc",
		Vars: map[string]interface{}{
			"environment": "test",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "eu-west-2",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcId, "VPC ID should not be empty")
}

func TestRDSModule(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../eu-west-2/database/rds",
		Vars: map[string]interface{}{
			"environment": "test",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "eu-west-2",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	endpoint := terraform.Output(t, terraformOptions, "db_endpoint")
	assert.NotEmpty(t, endpoint, "DB endpoint should not be empty")
}

func TestSecurityGroups(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../eu-west-2/network/security_groups",
		Vars: map[string]interface{}{
			"environment": "test",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "eu-west-2",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	sgId := terraform.Output(t, terraformOptions, "security_group_id")
	assert.NotEmpty(t, sgId, "Security Group ID should not be empty")
}
