# Burp Suite Enterprise Edition CircleCI Orb

[![CircleCI Build Status](https://circleci.com/gh/portSwigger-integrations/burp-suite-enterprise-circleci-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/portSwigger-integrations/burp-suite-enterprise-circleci-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/portswigger/burp-suite-enterprise.svg)](https://circleci.com/developer/orbs/orb/portswigger/burp-suite-enterprise) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

This orb enables you to easily integrate Burp Suite Enterprise Edition into your CircleCI pipeline. The orb runs Burp Scanner from a Docker container on the executor.
On completion, it generates a JUnit XML report about any vulnerabilities that it found. 

For full documentation about CI-driven scans, see [Integrating CI-driven scans](https://portswigger.net/burp/documentation/enterprise/integrate-ci-cd-platforms/ci-driven-scans).

## Inputs

To provide values to the container, you can specify inputs.

Alternatively, you can provide values in a configuration file. If you use a configuration file, the values in that file have priority over the input values.

### `enterprise_server_url`

The URL supplied with your PortSwigger account.

### `enterprise_api_key`

The API key supplied with your PortSwigger account.

### `start_url`

The URL of the website you want Burp Scanner to start scans from.

*You must specify the above values, either as inputs or in a configuration file.*

### `report_file_path`

(Optional) The output path for the scan report. This is relative to the working directory of the container.

The default value is `burp_junit_report.xml`

### `config_file_path`

(Optional) The path to the configuration file. This path must be an absolute path.

The default value is `burp_config.yml` in the container's working directory.

### `fail_on_failure`

(Optional) Fails the workflow if the scanner finds any vulnerability above the threshold specified in the config file.

The default value is `true`

*You can only specify `fail_on_failure` as an input and not in the config file.*

### Using a configuration file

To set more advanced options you can use a configuration file.
Save the file as `burp_config.yml` in the root of your repository. Values in the config file override parameters passed. To learn more, see [Creating a configuration file for a CI-driven scan](https://portswigger.net/burp/documentation/enterprise/integrate-ci-cd-platforms/ci-driven-scans/create-config)

Make sure you include:
* The URL
* The API key for your license
* At least one start URL.

## Results
The scan container produces a JUnit XML report when the scan completes. This report includes:
* The locations of the vulnerabilities
* Additional information about each vulnerability
* Links to our learning resources, with remediation advice.

This report only includes vulnerability details if vulnerabilities are found by Burp Scanner. The reporting results [example below](#reporting-results) shows how to save the report.

## Example usages

Below are some examples of how to use the orb to run a Burp scan against our [Gin and Juice Shop](https://ginandjuice.shop) site. This is a deliberately vulnerable web application. It's designed for testing web vulnerability scanners.

### Basic Usage


```
usage:
  version: 2.1
  orbs:
    burp-suite-enterprise: portswigger/burp-suite-enterprise-test@<version_number>
  jobs:
    basic-scan:
      machine:
        image: ubuntu-2204:current
      resource_class: medium
      steps:
        - checkout
        - burp-suite-enterprise/scan:
            start_url: "https://ginandjuice.shop"
            enterprise_server_url: <your-enterprise-server-url>
            # To use an environment variable for the API key 
            # pass the variable name as a parameter (as shown below).
            enterprise_api_key: ${YOUR_API_KEY_ENV_VAR_NAME}

  workflows:
    use-my-orb:
      jobs:
        - basic-scan
```

### Reporting Results
The examples below show how to display the vulnerability report in the **Tests** tab using [`store_test_results`](https://circleci.com/docs/configuration-reference/#storetestresults), or to store the raw .xml report as an [artifact](https://circleci.com/docs/artifacts/). CircleCI documentation for collecting test data can be found [here](https://circleci.com/docs/collect-test-data/).

```
usage:
  version: 2.1
  orbs:
    burp-suite-enterprise: portswigger/burp-suite-enterprise@<version_number>
  jobs:
    # Displays the vulnerability report in the Tests tab.
    scan-with-test-results:
      machine:
        image: ubuntu-2204:current
      resource_class: medium
      steps:
        - checkout
        - burp-suite-enterprise/scan:
            start_url: "https://ginandjuice.shop"
            report_file_path: <your-report-file-path>
            enterprise_server_url: <your-enterprise-server-url>
            enterprise_api_key: ${YOUR_API_KEY_ENV_VAR_NAME}
        - store_test_results:
            path: <your-report-file-path>
    # Stores the raw .xml report as an artifact.
    scan-store-artifact:
      machine:
        image: ubuntu-2204:current
      resource_class: medium
      steps:
        - checkout
        - burp-suite-enterprise/scan:
            start_url: "https://ginandjuice.shop"
            report_file_path: <your-report-file-path>
            enterprise_server_url: <your-enterprise-server-url>
            enterprise_api_key: ${YOUR_API_KEY_ENV_VAR_NAME}
        - store_artifacts:
            path: <your-report-file-path>

  workflows:
    use-my-orb:
      jobs:
        - scan-with-test-results
        - scan-store-artifact
```

### Usage with a configuration file

The example below shows how to use a configuration file for the inputs. To use an environment variable for the API key, pass the variable name as a parameter and leave the field in the config file blank. An example is shown below:

```
usage:
  version: 2.1
  orbs:
    burp-suite-enterprise: portswigger/burp-suite-enterprise-test@<version_number>
  jobs:
    scan-using-config:
      machine:
        image: ubuntu-2204:current
      resource_class: medium
      steps:
        - checkout
        - burp-suite-enterprise/scan:
            # To use an environment variable for the API key pass the variable name as a
            # parameter (as shown below) and leave the field in the config file blank.
            enterprise_api_key: ${YOUR_API_KEY_ENV_VAR_NAME}
            # To use a config file not in the root of your repository and/or not called
            # burp_config.yml use the config_file_path parameter as shown below.
            config_file_path: ./path/config_name.yml

  workflows:
    use-my-orb:
      jobs:
        - scan-using-config
```

By default, if the scanner finds any issue with a severity level of `LOW` or above, it fails the workflow build (the scan container exits with a non-zero exit code).

You can edit your configuration file to change the threshold for exiting with a non-zero exit code.
