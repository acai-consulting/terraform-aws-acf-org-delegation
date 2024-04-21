package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestExampleComplete(t *testing.T) {
	// retryable errors in terraform testing.
	t.Log("Starting Sample Module test")

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/complete",
		NoColor:      false,
		Lock:         true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Retrieve the 'test_success' outputs
	testSuccessOutput := terraform.Output(t, terraformOptions, "test_success")
	t.Logf("testSuccessOutput: %s", testSuccessOutput)

	// Assert that 'test_success' equals "true"
	assert.Equal(t, "true", testSuccessOutput, "The test_success output is not true")
}
