# Burp Suite Enterprise Edition CircleCI Orb

[![CircleCI Build Status](https://circleci.com/gh/portSwigger-integrations/burp-suite-enterprise-circleci-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/portSwigger-integrations/burp-suite-enterprise-circleci-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/portswigger/burp-suite-enterprise.svg)](https://circleci.com/developer/orbs/orb/portswigger/burp-suite-enterprise) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

This orb enables you to easily integrate Burp Suite Enterprise Edition into your CircleCI pipeline. The orb runs Burp Scanner from a Docker container on the executor.
On completion of the scan, it generates a JUnit XML report about any vulnerabilities that it found. 

For full documentation about CI-driven scans, see [Integrating CI-driven scans](https://portswigger.net/burp/documentation/enterprise/integrate-ci-cd-platforms/ci-driven-scans).

## Inputs

To provide values to the container, you can input them directly, or provide values in a configuration file. A configuration file gives you more options.

If you use a configuration file, the values in that file have priority over the input values.

### `enterprise_server_url`

*This field must be specified, either as an input or in a configuration file.* 

The URL linked to your PortSwigger account.

### `enterprise_api_key`

*This field must be specified, either as an input or in a configuration file.* 

The API key linked to your PortSwigger account.

### `start_url`

*This field must be specified, either as an input or in a configuration file.* 

The URL of the website you want Burp Scanner to start scans from.

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
Save the file as `burp_config.yml` in the root of your repository. These values will override any that were input as parameters. To learn more, see either [Creating a configuration file for a CI-driven scan](https://portswigger.net/burp/documentation/enterprise/integrate-ci-cd-platforms/ci-driven-scans/create-config) or [Creating a configuration file for a CI-driven scan with no dashboard](https://portswigger.net/burp/documentation/enterprise/integrate-ci-cd-platforms/ci-driven-nodash/create-config).
Make sure you include:
* The URL
* The API key for your license
* At least one start URL

## Results
The scan container produces a JUnit XML report when the scan completes. This report includes:
* The locations of the vulnerabilities.
* Additional information about each vulnerability.
* Links to our learning resources, with remediation advice.

This report only includes vulnerability details if vulnerabilities are found by Burp Scanner. The reporting results example below shows how to save the report.

## Example usages

Below are some examples of how to use the orb to run a Burp scan against our [Gin and Juice Shop](https://ginandjuice.shop) site. This is a deliberately vulnerable web application. It's designed for testing web vulnerability scanners.

### Basic Usage


```
usage:
  version: 2.1
  orbs:
    enterprise: portswigger/enterprise-test@1.0.0
  jobs:
    basic-scan:
      machine:
        image: ubuntu-2204:current
      resource_class: medium
      steps:
        - checkout
        - enterprise/scan:
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
The example below shows how to display the vulnerability report in the **Tests** tab using [`store_test_results`](https://circleci.com/docs/configuration-reference/#storetestresults), or to store the raw .xml report as an [artifact](https://circleci.com/docs/artifacts/). Learn more about [how CircleCI collects test data](https://circleci.com/docs/collect-test-data/).

```
usage:
  version: 2.1
  orbs:
    enterprise: portswigger/enterprise-test@1.0.0
  jobs:
    # Displays the vulnerability report in the Tests tab.
    scan-with-test-results:
      machine:
        image: ubuntu-2204:current
      resource_class: medium
      steps:
        - checkout
        - enterprise/scan:
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
        - enterprise/scan:
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
    enterprise: portswigger/enterprise-test@1.0.0
  jobs:
    scan-using-config:
      machine:
        image: ubuntu-2204:current
      resource_class: medium
      steps:
        - checkout
        - enterprise/scan:
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

To help keep your application secure, if the scanner finds any issue with a severity level of `LOW` or above, it fails the workflow build (the scan container exits with a non-zero exit code).

You can edit your configuration file to change the threshold for exiting with a non-zero exit code.
